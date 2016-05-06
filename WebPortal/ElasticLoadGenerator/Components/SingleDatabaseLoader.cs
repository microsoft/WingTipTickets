using System;
using System.ComponentModel;
using System.Data;
using ElasticPoolLoadGenerator.Helpers;
using ElasticPoolLoadGenerator.Interfaces;
using ElasticPoolLoadGenerator.Models;
using Microsoft.Practices.EnterpriseLibrary.TransientFaultHandling;

namespace ElasticPoolLoadGenerator.Components
{
    public class SingleDatabaseLoader : BaseDatabaseLoader, IDatabaseLoader
    {
        #region - Fields -

        private readonly DataTable _data;

        #endregion

        #region - Constructors -

        public SingleDatabaseLoader(MainViewModel viewModel, DataTable data)
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

                retryPolicy.ExecuteAction(() => LoadDatabase(retryPolicy, _data));

                if (Worker.CancellationPending)
                {
                    e.Cancel = true;
                }
            }
            catch (Exception ex)
            {
                e.Result = ex.Message;
            }
        }

        protected override bool IsLoadCompleted()
        {
            // Quit this after 6 hours
            return TotalElapsedSeconds >= 6 * 60 * 60; 
        }

        protected override void ReportProgress(DateTime loadStartTime, string database = "")
        {
            // Calculate values
            var loadElapsedSeconds = (DateTime.Now - loadStartTime).TotalSeconds;

            // Build value object
            var values = new ProgressValues()
            {
                ElapsedMinutes = Convert.ToInt32(TotalElapsedSeconds / 60),
                TotalMinutes = Convert.ToInt32(ConfigHelper.Runtime / 60),
                PurchasesPerSecond = Math.Round(TicketsPurchased / loadElapsedSeconds, 2),
                LoadingDatabase = string.Format("Loading: {0}", database),
                StatusText = "Loading until manually stopped"
            };

            // Check for NaN
            values.PurchasesPerSecond = !double.IsNaN(values.PurchasesPerSecond) ? values.PurchasesPerSecond : 0d;

            // Report on Progress
            Worker.ReportProgress(0, values);
        }

        #endregion
    }
}
