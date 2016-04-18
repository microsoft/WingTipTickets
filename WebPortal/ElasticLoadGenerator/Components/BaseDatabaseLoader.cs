using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Threading;
using ElasticPoolLoadGenerator.Helpers;
using ElasticPoolLoadGenerator.Interfaces;
using ElasticPoolLoadGenerator.Models;
using Microsoft.Practices.EnterpriseLibrary.TransientFaultHandling;

namespace ElasticPoolLoadGenerator.Components
{
    public class BaseDatabaseLoader : IDatabaseLoader
    {
        #region - Fields -

        public bool CanLoadDatabase { get; set; }
        public event EventHandler NotifyDoneSleeping;

        protected virtual void OnNotifyDoneSleeping()
        {
            EventHandler handler = NotifyDoneSleeping;

            if (handler != null)
            {
                handler(this, EventArgs.Empty);
            }
        }

        #endregion

        #region - Properties -

        public MainViewModel Model { get; set; }
        public BackgroundWorker Worker { get; set; }
        public DateTime StartTime { get; set; }
        public ExponentialBackoff BackoffStrategy { get; set; }

        public bool IsSleeping { get; set; }
        public bool IsLoadingPrimaryDatabase { get; set; }
        public double TicketsPurchased { get; set; }
        public double TotalElapsedSeconds { get; set; }

        #endregion

        #region - Constructors -

        public BaseDatabaseLoader(MainViewModel viewModel)
        {
            Model = viewModel;
            StartTime = DateTime.Now;
            IsSleeping = false;
            IsLoadingPrimaryDatabase = true;
            CanLoadDatabase = true;

            // Setup the Background Worker
            Worker = new BackgroundWorker
            {
                WorkerReportsProgress = true,
                WorkerSupportsCancellation = true
            };

            Worker.DoWork += Worker_DoWork;
            Worker.RunWorkerCompleted += Worker_RunWorkerCompleted;
            Worker.ProgressChanged += Worker_ProgressChanged;

            // Initialize Backoff Strategy
            InitializeBackoffStrategy();
        }

        #endregion


        #region - Public Methods -

        public void Start()
        {
            Worker.RunWorkerAsync();
        }

        public void Stop()
        {
            Worker.CancelAsync();
        }

        public void Continue()
        {
            CanLoadDatabase = true;
        }

        #endregion

        #region - Virtual Methods -

        protected virtual void RunDatabaseLoad(DoWorkEventArgs e)
        {
            throw new NotImplementedException("RunDatabaseLoad() function not Implemented");
        }

        protected virtual bool IsLoadCompleted()
        {
            throw new NotImplementedException("IsLoadCompleted() function not Implemented");
        }

        protected virtual void ReportProgress(DateTime loadStartTime, string database = "")
        {
            throw new NotImplementedException("ReportProgress() function not Implemented");
        }

        #endregion

        #region - Protected Methods -

        protected void InitializeBackoffStrategy()
        {
            try
            {
                // Create Backoff Strategy
                BackoffStrategy = new ExponentialBackoff(
                    "exponentialBackoffStrategy",
                    Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingRetryCount"].Trim()),
                    TimeSpan.FromSeconds(Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingMinBackoffDelaySeconds"].Trim())),
                    TimeSpan.FromSeconds(Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingMaxBackoffDelaySeconds"].Trim())),
                    TimeSpan.FromSeconds(Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingDeltaBackoffSeconds"].Trim())));

                // Set default retry manager
                RetryManager.SetDefault(new RetryManager(new List<RetryStrategy>
                {
                    BackoffStrategy
                }, "exponentialBackoffStrategy"));
            }
            catch
            {
            }
        }

        protected void LoadDatabase(RetryPolicy<ErrorDetectionStrategy> retryPolicy, DataTable data)
        {
            // Reset load Values
            var loadStartTime = DateTime.Now;

            // Build the Connection String
            var database = IsLoadingPrimaryDatabase ? Model.PrimaryDatabase : Model.SecondaryDatabase;
            var connectionString = DatabaseHelper.ConstructConnectionString(Model.DatabaseServer, database, Model.Username, Model.Password);

            using (var sqlConnection = new ReliableSqlConnection(connectionString, retryPolicy))
            {
                TicketsPurchased = 0d;
                sqlConnection.Open(retryPolicy);

                const string query = "INSERT INTO TICKETS (CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate, SeatNumber) SELECT CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate, SeatNumber FROM @Data";

                using (var cmd = new SqlCommand(query, sqlConnection.Current))
                {
                    cmd.Parameters.Add(new SqlParameter()
                    {
                        ParameterName = "@Data",
                        SqlDbType = SqlDbType.Structured,
                        TypeName = "TicketType",
                        Value = data
                    });

                    do
                    {
                        if (Worker.CancellationPending)
                        {
                            break;
                        }

                        // Run the batch insert script
                        cmd.Transaction = (SqlTransaction)sqlConnection.BeginTransaction();
                        cmd.ExecuteNonQuery();
                        //cmd.ExecuteNonQueryWithRetry(retryPolicy); 
                        cmd.Transaction.Commit();

                        // Update Values
                        TicketsPurchased += Model.BulkPurchaseQty;

                        UpdateTotalValues();
                        ReportProgress(loadStartTime, database);

                        // Minimize tickets added
                        Thread.Sleep(5);
                    }
                    while (!IsLoadCompleted());
                }
            }
        }

        protected void Sleep()
        {
            // Enable sleep feedback
            IsSleeping = true;
            CanLoadDatabase = false;

            // Reset sleep values
            var loadElapsedSeconds = 0d;
            var loadStartTime = DateTime.Now;

            do
            {
                if (Worker.CancellationPending)
                {
                    break;
                }

                // Update Values
                loadElapsedSeconds = (DateTime.Now - loadStartTime).TotalSeconds;

                UpdateTotalValues();
                ReportProgress(loadStartTime);

                Thread.Sleep(5000);
            }
            while (loadElapsedSeconds < ConfigHelper.Sleeptime);

            IsSleeping = false;
            OnNotifyDoneSleeping();
        }

        protected void UpdateTotalValues()
        {
            // Update totals
            TotalElapsedSeconds = (DateTime.Now - StartTime).TotalSeconds;
        }

        #endregion

        #region - Event Methods -

        void Worker_DoWork(object sender, DoWorkEventArgs e)
        {
            RunDatabaseLoad(e);
        }

        private void Worker_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            // Get the progress values
            var values = (ProgressValues)e.UserState;

            // Update the model
            Model.ProgressValue = e.ProgressPercentage;
            Model.StatusText = values.StatusText;
            Model.PurchasesPerSecond = values.PurchasesPerSecond;
            Model.LoadingDatabase = values.LoadingDatabase;
        }

        private void Worker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            // Reset the model values
            Model.PurchasesPerSecond = 0;
            Model.ProgressValue = 0;
            Model.FieldsEnabled = true;
            Model.StartText = "Start";
            Model.StatusText = "";

            Model.LoadingDatabase = "Load Generation " + (e.Cancelled ? "Cancelled" : "Completed");
        }

        #endregion


        #region - ProgressValues class -

        protected class ProgressValues
        {
            public double PurchasesPerSecond { get; set; }
            public int ElapsedMinutes { get; set; }
            public int TotalMinutes { get; set; }
            public string LoadingDatabase { get; set; }
            public string StatusText { get; set; }
        }

        #endregion
    }
}