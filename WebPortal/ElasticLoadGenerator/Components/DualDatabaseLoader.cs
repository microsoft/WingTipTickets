using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Threading;
using ElasticPoolLoadGenerator.Helpers;
using ElasticPoolLoadGenerator.Interfaces;
using ElasticPoolLoadGenerator.Models;
using Microsoft.Practices.EnterpriseLibrary.TransientFaultHandling;

namespace ElasticPoolLoadGenerator.Components
{
    public class DualDatabaseLoader : BaseDatabaseLoader, IDatabaseLoader
    {
        #region - Fields -

        private readonly DataTable _data;

        #endregion

        #region - Constructors -

        public DualDatabaseLoader(MainViewModel viewModel, DataTable data)
            : base(viewModel)
        {
            _data = data;
        }

        #endregion

        #region - Overidden Methods -

        protected override void RunDatabaseLoad(DoWorkEventArgs e)
        {
            try
            {
                // Create the Retry Policy
                var retryPolicy = new RetryPolicy<ErrorDetectionStrategy>(BackoffStrategy);

                retryPolicy.ExecuteAction(() =>
                {
                    do
                    {
                        if (Worker.CancellationPending)
                        {
                            e.Cancel = true;
                            break;
                        }

                        // Load the Database & Sleep for x amount of time
                        if (CanLoadDatabase)
                        {
                            LoadDatabase(retryPolicy, _data);
                            Sleep();

                            // Switch Databases
                            IsLoadingPrimaryDatabase = !IsLoadingPrimaryDatabase;
                        }
                        else
                        {
                            Thread.Sleep(500);
                        }
                    }
                    while (TotalElapsedSeconds < ConfigHelper.Runtime);
                });
            }
            catch (Exception ex)
            {
                e.Result = ex.Message;
            }
        }

        protected override bool IsLoadCompleted()
        {
            // Quit after tickets purchased past the record limit
            return TicketsPurchased >= ConfigHelper.LoadRecordLimit;
        }

        protected override void ReportProgress(DateTime loadStartTime, string database = "")
        {
            // Calculate values
            var percentage = Convert.ToInt32(TotalElapsedSeconds / ConfigHelper.Runtime * 100);
            var loadElapsedSeconds = (DateTime.Now - loadStartTime).TotalSeconds;

            // Build value object
            var values = new ProgressValues()
            {
                ElapsedMinutes = Convert.ToInt32(TotalElapsedSeconds / 60),
                TotalMinutes = Convert.ToInt32(ConfigHelper.Runtime / 60),

                PurchasesPerSecond = !IsSleeping
                    ? Math.Round(TicketsPurchased / loadElapsedSeconds, 2)
                    : default(double),

                LoadingDatabase = !IsSleeping
                    ? string.Format("Loading: {0}", database)
                    : string.Format("Sleeping for {0} minutes", Convert.ToInt32(ConfigHelper.Sleeptime / 60))
            };

            // Check for NaN
            values.PurchasesPerSecond = !double.IsNaN(values.PurchasesPerSecond) ? values.PurchasesPerSecond : 0d;
            values.StatusText = string.Format("{0} of {1} Minutes", values.ElapsedMinutes, values.TotalMinutes);

            // Report on Progress
            Worker.ReportProgress(percentage, values);
        }

        #endregion
    }
}
