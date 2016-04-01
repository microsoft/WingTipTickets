using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data.SqlClient;
using System.Threading;
using ElasticPoolLoadGenerator.Helpers;
using ElasticPoolLoadGenerator.Models;
using Microsoft.Practices.EnterpriseLibrary.TransientFaultHandling;

namespace ElasticPoolLoadGenerator.Components
{
    public class DatabaseLoader
    {
        #region - Fields -

        private double _totalElapsedSeconds;
        private bool _loadingPrimaryDatabase;
        private bool _isSleeping;

        private readonly BackgroundWorker _worker;
        private readonly MainViewModel _model;
        private readonly DateTime _startTime;
        private ExponentialBackoff _backoffStrategy;

        #endregion

        #region - Constructors -

        public DatabaseLoader(MainViewModel viewModel)
        {
            _model = viewModel;
            _isSleeping = false;
            _startTime = DateTime.Now;
            _loadingPrimaryDatabase = true;

            // Setup the Background Worker
            _worker = new BackgroundWorker
            {
                WorkerReportsProgress = true,
                WorkerSupportsCancellation = true
            };

            _worker.DoWork += Worker_DoWork;
            _worker.RunWorkerCompleted += Worker_RunWorkerCompleted;
            _worker.ProgressChanged += Worker_ProgressChanged;

            // Initialize Backoff Strategy
            InitializeBackoffStrategy();
        }

        #endregion

        #region - Public Methods -

        public void Start()
        {
            _worker.RunWorkerAsync();
        }

        public void Stop()
        {
            _worker.CancelAsync();
        }

        #endregion

        #region - Private Methods -

        private void InitializeBackoffStrategy()
        {
            // Create Backoff Strategy
            _backoffStrategy = new ExponentialBackoff(
                "exponentialBackoffStrategy",
                Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingRetryCount"].Trim()),
                TimeSpan.FromSeconds(Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingMinBackoffDelaySeconds"].Trim())),
                TimeSpan.FromSeconds(Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingMaxBackoffDelaySeconds"].Trim())),
                TimeSpan.FromSeconds(Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingDeltaBackoffSeconds"].Trim())));

            // Set default retry manager
            RetryManager.SetDefault(new RetryManager(new List<RetryStrategy> { _backoffStrategy }, "exponentialBackoffStrategy"));
        }

        private void LoadDatabase(RetryPolicy<ErrorDetectionStrategy> retryPolicy, string batchQuery)
        {
            // Reset load Values
            var ticketsPurchased = 0d;
            var loadStartTime = DateTime.Now;

            // Build the Connection String
            var database = _loadingPrimaryDatabase ? _model.PrimaryDatabase : _model.SecondaryDatabase;
            var connectionString = DatabaseHelper.ConstructConnectionString(_model.DatabaseServer, database, _model.Username, _model.Password);

            using (var sqlConnection = new ReliableSqlConnection(connectionString, retryPolicy))
            {
                sqlConnection.Open(retryPolicy);

                do
                {
                    if (_worker.CancellationPending)
                    {
                        break;
                    }

                    var transaction = sqlConnection.BeginTransaction();

                    using (var cmd = new SqlCommand(batchQuery, sqlConnection.Current, (SqlTransaction)transaction))
                    {
                        // Run the batch insert script
                        cmd.ExecuteNonQueryWithRetry(retryPolicy);
                        transaction.Commit();

                        // Update Values
                        ticketsPurchased += _model.BulkPurchaseQty;

                        UpdateTotalValues();
                        ReportProgress(ticketsPurchased, loadStartTime, database);

                        // Minimize tickets added
                        Thread.Sleep(50);
                    }
                }
                while (ticketsPurchased < ConfigHelper.LoadRecordLimit);
            }
        }

        private void Sleep()
        {
            // Enable sleep feedback
            _isSleeping = true;

            // Reset sleep values
            var loadElapsedSeconds = 0d;
            var loadStartTime = DateTime.Now;

            do
            {
                if (_worker.CancellationPending)
                {
                    break;
                }

                // Update Values
                loadElapsedSeconds = (DateTime.Now - loadStartTime).TotalSeconds;

                UpdateTotalValues();
                ReportProgress(0, loadStartTime);

                Thread.Sleep(5000);
            }
            while (loadElapsedSeconds < ConfigHelper.Sleeptime);

            // Disable sleep feedback
            _isSleeping = false;
        }

        private void ReportProgress(double ticketsPurchased, DateTime loadStartTime, string database = "")
        {
            // Calculate values
            var percentage = Convert.ToInt32(_totalElapsedSeconds / ConfigHelper.Runtime * 100);
            var loadElapsedSeconds = (DateTime.Now - loadStartTime).TotalSeconds;

            // Build value object
            var values = new ProgressValues()
            {
                ElapsedMinutes = Convert.ToInt32(_totalElapsedSeconds / 60),
                TotalMinutes = Convert.ToInt32(ConfigHelper.Runtime / 60),

                PurchasesPerSecond = !_isSleeping
                    ? Math.Round(ticketsPurchased / loadElapsedSeconds, 2)
                    : default(double),

                LoadingDatabase = !_isSleeping
                    ? string.Format("Loading: {0}", database)
                    : string.Format("Sleeping for {0} minutes", Convert.ToInt32(ConfigHelper.Sleeptime / 60))
            };

            // Check for NaN
            values.PurchasesPerSecond = !double.IsNaN(values.PurchasesPerSecond) ? values.PurchasesPerSecond : 0d;

            // Report on Progress
            _worker.ReportProgress(percentage, values);
        }

        private void UpdateTotalValues()
        {
            // Update totals
            _totalElapsedSeconds = (DateTime.Now - _startTime).TotalSeconds;
        }

        #endregion

        #region - Event Methods -

        void Worker_DoWork(object sender, DoWorkEventArgs e)
        {
            try
            {
                // Build the Queries
                var rootQuery = DatabaseHelper.BuildInsertQuery();
                var batchQuery = DatabaseHelper.BuildBatchQuery(_model.BulkPurchaseQty, rootQuery);

                // Create the Retry Policy
                var retryPolicy = new RetryPolicy<ErrorDetectionStrategy>(_backoffStrategy);

                retryPolicy.ExecuteAction(() =>
                {
                    do
                    {
                        if (_worker.CancellationPending)
                        {
                            e.Cancel = true;
                            break;
                        }

                        // Load the Database & Sleep for x amount of time
                        LoadDatabase(retryPolicy, batchQuery);
                        Sleep();

                        // Switch Databases
                        _loadingPrimaryDatabase = !_loadingPrimaryDatabase;
                    }
                    while (_totalElapsedSeconds < ConfigHelper.Runtime);
                });
            }
            catch (Exception ex)
            {
                e.Result = ex.Message;
            }
        }

        void Worker_ProgressChanged(object sender, ProgressChangedEventArgs e)
        {
            // Get the progress values
            var values = (ProgressValues)e.UserState;

            // Update the model
            _model.ProgressValue = e.ProgressPercentage;
            _model.StatusText = string.Format("{0} of {1} Minutes", values.ElapsedMinutes, values.TotalMinutes);
            _model.PurchasesPerSecond = values.PurchasesPerSecond;
            _model.LoadingDatabase = values.LoadingDatabase;
        }

        void Worker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
        {
            // Reset the model values
            _model.PurchasesPerSecond = 0;
            _model.ProgressValue = 0;
            _model.StartEnabled = true;
            _model.StartText = "Start";
            _model.StatusText = "";

            _model.LoadingDatabase = "Load Generation " + (e.Cancelled ? "Cancelled" : "Completed");
        }

        #endregion

        #region - ProgressValues class -

        private class ProgressValues
        {
            public double PurchasesPerSecond { get; set; }
            public int ElapsedMinutes { get; set; }
            public int TotalMinutes { get; set; }
            public string LoadingDatabase { get; set; }
        }

        #endregion
    }
}
