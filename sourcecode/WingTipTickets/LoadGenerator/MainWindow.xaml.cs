using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using Microsoft.Practices.EnterpriseLibrary.TransientFaultHandling;

namespace LoadGenerator
{
    public partial class MainWindow : Window
    {
        #region Private Variables
        string DatabaseUserName = ConfigurationManager.AppSettings["DatabaseUserName"].Trim();
        string DatabaseUserPassword = ConfigurationManager.AppSettings["DatabaseUserPassword"].Trim();
        string TenantDbName = ConfigurationManager.AppSettings["TenantDbName"].Trim();                                             
        BackgroundWorker concertWorker = new BackgroundWorker { WorkerReportsProgress = true };
        BackgroundWorker levelWorker = new BackgroundWorker { WorkerReportsProgress = true };
        BackgroundWorker customerWorker = new BackgroundWorker { WorkerReportsProgress = true };
        BackgroundWorker purchaseWorker = new BackgroundWorker { WorkerReportsProgress = true, WorkerSupportsCancellation = true };
        DateTime OverallTimer = DateTime.MinValue;
        ExponentialBackoff exponentialBackoffStrategy =
        new ExponentialBackoff("exponentialBackoffStrategy",
        Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingRetryCount"].Trim()),
        TimeSpan.FromSeconds(Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingMinBackoffDelaySeconds"].Trim())),
        TimeSpan.FromSeconds(Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingMaxBackoffDelaySeconds"].Trim())),
        TimeSpan.FromSeconds(Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingDeltaBackoffSeconds"].Trim())));        
        TicketsPurchasedCounter ticketsPurchasedCounter;
        #endregion Private Variables

        public MainWindow()
        {
            InitializeComponent();
            concertWorker.DoWork += concertWorker_DoWork;
            concertWorker.RunWorkerCompleted += concertWorker_RunWorkerCompleted;
            concertWorker.ProgressChanged += worker_ProgressChanged;
            levelWorker.DoWork += levelWorker_DoWork;
            levelWorker.RunWorkerCompleted += levelWorker_RunWorkerCompleted;
            levelWorker.ProgressChanged += worker_ProgressChanged;
            customerWorker.DoWork += customerWorker_DoWork;
            customerWorker.RunWorkerCompleted += customerWorker_RunWorkerCompleted;
            customerWorker.ProgressChanged += worker_ProgressChanged;
            purchaseWorker.DoWork += purchaseWorker_DoWork;
            purchaseWorker.RunWorkerCompleted += purchaseWorker_RunWorkerCompleted;
            purchaseWorker.ProgressChanged += worker_ProgressChanged;
            RetryManager manager = new RetryManager(new List<RetryStrategy> { exponentialBackoffStrategy }, "exponentialBackoffStrategy");
            RetryManager.SetDefault(manager);
            ticketsPurchasedCounter = new TicketsPurchasedCounter(0);            
        }

        #region UI Data Refresh
        private void cmbConcert_DropDownOpened(object sender, EventArgs e)
        {
            try { concertWorker.RunWorkerAsync(new object[] { txtPrimary.Text, DatabaseUserName, DatabaseUserPassword }); }
            catch (InvalidOperationException) { }
        }
        private void cmbConcert_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            try { levelWorker.RunWorkerAsync(new object[] { txtPrimary.Text, DatabaseUserName, DatabaseUserPassword, cmbConcert.SelectedValue }); }
            catch (InvalidOperationException) { }
        }
        private void cmbLevel_DropDownOpened(object sender, EventArgs e)
        {
            try { levelWorker.RunWorkerAsync(new object[] { txtPrimary.Text, DatabaseUserName, DatabaseUserPassword, cmbConcert.SelectedValue }); }
            catch (InvalidOperationException) { }
        }
        private void cmbCustomer_DropDownOpened(object sender, EventArgs e)
        {
            try { customerWorker.RunWorkerAsync(new object[] { txtPrimary.Text, DatabaseUserName, DatabaseUserPassword }); }
            catch (InvalidOperationException) { }
        }
        #endregion UI Data Refresh

        #region Background Data Refresh
        void concertWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            try
            {
                object[] args = e.Argument as object[];
                string conn = ConstructConn(args[0].ToString(), TenantDbName, args[1].ToString(), args[2].ToString());
                using (SqlDataAdapter sdAdapter = new SqlDataAdapter(new SqlCommand("Select ConcertId, SaveToDbServerType, ConcertName From Concerts", new SqlConnection(conn))))
                using (DataSet tempDS = new DataSet())
                {
                    sdAdapter.Fill(tempDS);
                    if (tempDS.Tables.Count > 0 && tempDS.Tables[0].Rows.Count > 0)
                    {
                        List<Tuple<int, bool, string>> tempConcerts = new List<Tuple<int, bool, string>>();
                        int rowCount = tempDS.Tables[0].Rows.Count;
                        for (int i = 0; i < tempDS.Tables[0].Rows.Count; i++)
                        {
                            if (!tempConcerts.Any(a => a.Item1 == Convert.ToInt32(tempDS.Tables[0].Rows[i]["ConcertId"])))
                                tempConcerts.Add(new Tuple<int, bool, string>(Convert.ToInt32(tempDS.Tables[0].Rows[i]["ConcertId"]), Convert.ToBoolean(tempDS.Tables[0].Rows[i]["SaveToDbServerType"]), tempDS.Tables[0].Rows[i]["ConcertName"].ToString()));
                            concertWorker.ReportProgress(Convert.ToInt32(rowCount / (i + 1)));
                        }
                        concertWorker.ReportProgress(100);
                        e.Result = tempConcerts;
                    }
                }
            }
            catch (Exception ex) { e.Result = ex.Message; }
        }
        void concertWorker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            if (e.Result is List<Tuple<int, bool, string>>)
                cmbConcert.ItemsSource = e.Result as List<Tuple<int, bool, string>>;
            else if (!string.IsNullOrEmpty(e.Result.ToString()))
                MessageBox.Show(e.Result.ToString());
            prgPurchases.Value = 0;
        }
        void levelWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            try
            {
                object[] args = e.Argument as object[];
                if (!(args[3] is Tuple<int, bool, string>) || (args[3] as Tuple<int, bool, string>).Item1 <= 0)
                {
                    Dictionary<int, string> tempReturn = new Dictionary<int, string>();
                    tempReturn.Add(0, "<Please Select Concert>");
                    e.Result = tempReturn;
                    return;
                }
                string conn = ConstructConn(args[0].ToString(), TenantDbName, args[1].ToString(), args[2].ToString());
                using (SqlDataAdapter sdAdapter = new SqlDataAdapter(new SqlCommand("Select TicketLevelId, TicketPrice From TicketLevels Where ConcertId=" + (args[3] as Tuple<int, bool, string>).Item1, new SqlConnection(conn))))
                using (DataSet tempDS = new DataSet())
                {
                    sdAdapter.Fill(tempDS);
                    if (tempDS.Tables.Count > 0 && tempDS.Tables[0].Rows.Count > 0)
                    {
                        Dictionary<int, string> tempLevels = new Dictionary<int, string>();
                        string tempDisplayValue = string.Empty;
                        int rowCount = tempDS.Tables[0].Rows.Count;
                        for (int i = 0; i < tempDS.Tables[0].Rows.Count; i++)
                        {
                            if (!tempLevels.ContainsKey(Convert.ToInt32(tempDS.Tables[0].Rows[i]["TicketLevelId"])))
                            {
                                switch (Convert.ToInt32(Convert.ToDecimal(tempDS.Tables[0].Rows[i]["TicketPrice"])))
                                {
                                    case 55: tempDisplayValue = "Sections 219-221 ($55)"; break;
                                    case 60: tempDisplayValue = "Sections 218-214 ($60)"; break;
                                    case 65: tempDisplayValue = "Sections 222-226 ($65)"; break;
                                    case 70: tempDisplayValue = "Sections 210-213 ($70)"; break;
                                    case 75: tempDisplayValue = "Sections 201-204 ($75)"; break;
                                    case 80: tempDisplayValue = "Sections 114-119 ($80)"; break;
                                    case 85: tempDisplayValue = "Sections 120-126 ($85)"; break;
                                    case 90: tempDisplayValue = "Sections 104-110 ($90)"; break;
                                    case 95: tempDisplayValue = "Sections 111-113 ($95)"; break;
                                    case 100: tempDisplayValue = "Sections 101-103 ($100)"; break;
                                }
                                tempLevels.Add(Convert.ToInt32(tempDS.Tables[0].Rows[i]["TicketLevelId"]), tempDisplayValue);
                            }
                            levelWorker.ReportProgress(Convert.ToInt32(rowCount / (i + 1)));
                        }
                        levelWorker.ReportProgress(100);
                        e.Result = tempLevels;
                    }
                }
            }
            catch (Exception ex) { e.Result = ex.Message; }
        }
        void levelWorker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            if (e.Result is Dictionary<int, string>)
                cmbLevel.ItemsSource = e.Result as Dictionary<int, string>;
            else if (!string.IsNullOrEmpty(e.Result.ToString()))
                MessageBox.Show(e.Result.ToString());
            prgPurchases.Value = 0;
        }
        void customerWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            try
            {
                object[] args = e.Argument as object[];
                string connectionString = ConstructConn(args[0].ToString(), TenantDbName, args[1].ToString(), args[2].ToString());

                string conn = ConstructConn(args[0].ToString(), TenantDbName, args[1].ToString(), args[2].ToString());
                using (SqlDataAdapter sdAdapter = new SqlDataAdapter(new SqlCommand("Select CustomerId, FirstName, LastName From Customers", new SqlConnection(conn))))
                using (DataSet tempDS = new DataSet())
                {
                    sdAdapter.Fill(tempDS);
                    if (tempDS.Tables.Count > 0 && tempDS.Tables[0].Rows.Count > 0)
                    {
                        Dictionary<int, string> tempCustomers = new Dictionary<int, string>();
                        int rowCount = tempDS.Tables[0].Rows.Count;
                        for (int i = 0; i < tempDS.Tables[0].Rows.Count; i++)
                        {
                            if (!tempCustomers.ContainsKey(Convert.ToInt32(tempDS.Tables[0].Rows[i]["CustomerId"])) && !string.IsNullOrWhiteSpace(tempDS.Tables[0].Rows[i]["FirstName"].ToString()))
                                tempCustomers.Add(Convert.ToInt32(tempDS.Tables[0].Rows[i]["CustomerId"]), tempDS.Tables[0].Rows[i]["FirstName"].ToString() + " " + tempDS.Tables[0].Rows[i]["LastName"].ToString());
                            customerWorker.ReportProgress(Convert.ToInt32(rowCount / (i + 1)));
                        }
                        customerWorker.ReportProgress(100);
                        e.Result = tempCustomers;
                    }
                }

            }
            catch (Exception ex) { e.Result = ex.Message; }
        }
        void customerWorker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            if (e.Result is Dictionary<int, string>)
                cmbCustomer.ItemsSource = e.Result as Dictionary<int, string>;
            else if (!string.IsNullOrEmpty(e.Result.ToString()))
                MessageBox.Show(e.Result.ToString());
            prgPurchases.Value = 0;
        }
        #endregion Background Data Refresh

        #region Ticket Purchase
        private void btnStart_Click(object sender, RoutedEventArgs e)
        {
            if (btnStart.Content.ToString() == "Start")
            {
                if (rdoNoClean.IsChecked == true || rdoCleanComplete.IsChecked == true)
                {
                    OverallTimer = DateTime.Now;
                    //purchaseWorker.RunWorkerAsync(new object[] { (cmbConcert.SelectedItem as Tuple<int, bool, string>).Item2 == false ? txtPrimary.Text : txtShard.Text, DatabaseUserName, DatabaseUserPassword, (cmbConcert.SelectedItem as Tuple<int, bool, string>).Item1, cmbLevel.SelectedValue, cmbCustomer.SelectedValue, txtTicketCount.Text, txtBulkPurchase.Text });
                    purchaseWorker.RunWorkerAsync(new object[] { (txtPrimary.Text), DatabaseUserName, DatabaseUserPassword, (cmbConcert.SelectedItem as Tuple<int, bool, string>).Item1, cmbLevel.SelectedValue, cmbCustomer.SelectedValue, txtTicketCount.Text, txtBulkPurchase.Text });
                    btnStart.Content = "Stop";
                }
                else if (rdoCleanOnly.IsChecked == true)
                    DeleteTickets();
            }
            else if (btnStart.Content.ToString() == "Stop")
            {
                purchaseWorker.CancelAsync();
                btnStart.Content = "Start";
            }
        }
        void purchaseWorker_DoWork(object sender, DoWorkEventArgs e)
        {
            try
            {
                object[] args = e.Argument as object[];
                if (args.Length != 8 || Convert.ToInt32(args[3]) <= 0 || Convert.ToInt32(args[4]) <= 0 || Convert.ToInt32(args[5]) <= 0 || Convert.ToInt32(args[6]) <= 0 || Convert.ToInt32(args[7]) <= 0)
                {
                    e.Result = "Please ensure you have selected a concert, ticket level, and customer, as well as supplied the ticket count and bulk purchase quantity.";
                    return;
                }
                string conn = ConstructConn(args[0].ToString(), TenantDbName, args[1].ToString(), args[2].ToString());
                string rootQuery =
                    string.Format("Insert Into Tickets (CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate) Values ({0}, '', {1}, {2}, GETDATE())",
                        Convert.ToInt32(args[5]).ToString(), Convert.ToInt32(args[4]).ToString(), Convert.ToInt32(args[3]).ToString());
                string runtimeQuery = string.Empty;
                int bulkPurchase = Convert.ToInt32(args[7]);
                for (int i = 0; i < bulkPurchase; i++)
                    runtimeQuery += rootQuery + "; ";
                int ticketCount = Convert.ToInt32(args[6]);
                int purchaseCounter = 0;

                var retryPolicy = new RetryPolicy<CustomTransientErrorDetectionStrategy>(exponentialBackoffStrategy);

                retryPolicy.ExecuteAction(() =>
                {
                    using (ReliableSqlConnection reliableSqlConnection = new ReliableSqlConnection(conn, retryPolicy))
                    {
                        reliableSqlConnection.Open(retryPolicy);
                        IDbTransaction transaction = reliableSqlConnection.BeginTransaction();
                        using (var cmd = new SqlCommand(runtimeQuery, reliableSqlConnection.Current, (SqlTransaction)transaction))
                        {
                            while (purchaseCounter < ticketCount)
                            {
                                if (purchaseWorker.CancellationPending)
                                    break;
                                if (ticketCount - purchaseCounter < bulkPurchase)
                                {
                                    runtimeQuery = string.Empty;
                                    bulkPurchase = ticketCount - purchaseCounter;
                                    for (int i = 0; i < bulkPurchase; i++)
                                        runtimeQuery += rootQuery;
                                    cmd.CommandText = runtimeQuery;
                                }

                                cmd.ExecuteNonQueryWithRetry(retryPolicy);

                                purchaseWorker.ReportProgress(Convert.ToInt32(((purchaseCounter * 1.0) / ticketCount) * 100), purchaseCounter);
                                purchaseCounter = purchaseCounter + bulkPurchase;
                            }
                            transaction.Commit();
                        }
                    }
                });
                e.Result = purchaseCounter + " tickets purchased";
            }
            catch (Exception ex) { e.Result = ex.Message; }
        }
        void purchaseWorker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            MessageBoxHelper.PrepToCenterMessageBoxOnForm(this);
            MessageBox.Show(e.Result.ToString());
            prgPurchases.Value = 0;
            //lblPurchases.Text = e.Result.ToString();
            lblPurchases.Text = " 0 tickets purchase";
            lblPurchasePerSec.Text = "0 tickets/second";
            lblDuration.Text = "00h00m00s";
            ticketsPurchasedCounter.TicketsPurchased = 0.0;
            if (rdoCleanComplete.IsChecked == true)
                DeleteTickets();
            btnStart.Content = "Start";
        }
        private void DeleteTickets()
        {
            try
            {
                //string conn = ConstructConn((cmbConcert.SelectedItem as Tuple<int, bool, string>).Item2 == false ? txtPrimary.Text : txtShard.Text, TicketsDatabaseName, DatabaseUserName, DatabaseUserPassword);
                string conn = ConstructConn(txtPrimary.Text, TenantDbName, DatabaseUserName, DatabaseUserPassword);

                using (SqlConnection sConn = new SqlConnection(conn))
                {
                    sConn.Open();
                    using (SqlCommand cmd = new SqlCommand(string.Format("Delete From Tickets Where Name='' and CustomerId={0} and TicketLevelId={1} and ConcertId={2}", cmbCustomer.SelectedValue, cmbLevel.SelectedValue, (cmbConcert.SelectedItem as Tuple<int, bool, string>).Item1), sConn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
                MessageBoxHelper.PrepToCenterMessageBoxOnForm(this);
                MessageBox.Show("Deleted all tickets created from the load generator for the specified concert, level, and customer.");
            }
            catch (Exception ex) 
            {
                MessageBoxHelper.PrepToCenterMessageBoxOnForm(this); 
                MessageBox.Show("Issue in deleting tickets: " + ex.Message);
            }
        }
        #endregion Ticket Purchase

        #region Utility Functions
        private string ConstructConn(string server, string db, string user, string pass)
        {
            return String.Format("Server=tcp:{0};Database={1};User ID={2};Password={3};Trusted_Connection=False;", server, db, user, pass);
        }
        internal class CustomTransientErrorDetectionStrategy : ITransientErrorDetectionStrategy
        {
            public bool IsTransient(Exception ex)
            {
                if (ex is SqlException)
                    return true;
                return false;
            }
        }
        private void worker_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            prgPurchases.Value = e.ProgressPercentage;
            if (e.UserState != null)
            {
                lblPurchases.Text = string.Format("{0} tickets purchased", e.UserState);
                TimeSpan runtime = DateTime.Now.Subtract(OverallTimer);
                lblDuration.Text = string.Format("{0}h{1}m{2}s", runtime.Hours, runtime.Minutes, runtime.Seconds);
                lblPurchasePerSec.Text = Math.Round(Convert.ToInt32(e.UserState) / runtime.TotalSeconds, 2).ToString() + " tickets/sec";
                this.myGauge.DataContext = ticketsPurchasedCounter;
                ticketsPurchasedCounter.TicketsPurchased = Convert.ToDouble(Math.Round(Convert.ToInt32(e.UserState) / runtime.TotalSeconds, 2));
            }
        }

        public class TicketsPurchasedCounter : INotifyPropertyChanged
        {
            private double ticketsPurchased;

            public double TicketsPurchased
            {
                get { return ticketsPurchased; }
                set
                {
                    ticketsPurchased = value;
                    if (PropertyChanged != null)
                    {
                        PropertyChanged(this, new PropertyChangedEventArgs("TicketsPurchased"));
                    }
                }
            }


            public TicketsPurchasedCounter(double ticketsPurchased)
            {
                this.TicketsPurchased = ticketsPurchased;
            }


            #region INotifyPropertyChanged Members

            public event PropertyChangedEventHandler PropertyChanged;

            #endregion
        }
        #endregion Utility Functions
    }
}