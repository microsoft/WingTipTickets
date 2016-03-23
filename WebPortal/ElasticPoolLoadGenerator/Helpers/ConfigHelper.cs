using System;
using System.Configuration;

namespace ElasticPoolLoadGenerator.Helpers
{
    public static class ConfigHelper
    {
        #region - Properties -

        public static string PrimaryDatabase
        {
            get
            {
                return ConfigurationManager.AppSettings["PrimaryDatabase"];
            }
        }

        public static string SecondaryDatabase
        {
            get
            {
                return ConfigurationManager.AppSettings["SecondaryDatabase"];
            }
        }

        public static string Username
        {
            get
            {
                return ConfigurationManager.AppSettings["Username"];
            }
        }

        public static string Password
        {
            get
            {
                return ConfigurationManager.AppSettings["Password"];
            }
        }

        public static int BatchSize
        {
            get
            {
                return Convert.ToInt32(ConfigurationManager.AppSettings["BatchSize"]);
            }
        }

        public static int LoadRecordLimit
        {
            get
            {
                return Convert.ToInt32(ConfigurationManager.AppSettings["LoadRecordLimit"]);
            }
        }

        public static int ConcertId
        {
            get
            {
                return Convert.ToInt32(ConfigurationManager.AppSettings["ConcertId"]);
            }
        }

        public static int TicketLevelId
        {
            get
            {
                return Convert.ToInt32(ConfigurationManager.AppSettings["TicketLevelId"]);
            }
        }

        public static int CustomerId
        {
            get
            {
                return Convert.ToInt32(ConfigurationManager.AppSettings["CustomerId"]);
            }
        }

        public static string CustomerName
        {
            get
            {
                return ConfigurationManager.AppSettings["CustomerName"];
            }
        }


        public static int Runtime
        {
            get
            {
                return Convert.ToInt32(ConfigurationManager.AppSettings["Runtime"]);
            }
        }

        public static int Sleeptime
        {
            get
            {
                return Convert.ToInt32(ConfigurationManager.AppSettings["Sleeptime"]);
            }
        }


        public static int TransientRetryCount
        {
            get
            {
                return Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingRetryCount"]);
            }
        }

        public static int TransientMinBackoffDelaySeconds
        {
            get
            {
                return Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingMinBackoffDelaySeconds"]);
            }
        }

        public static int TransientMaxBackoffDelaySeconds
        {
            get
            {
                return Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingMaxBackoffDelaySeconds"]);
            }
        }

        public static int TransientDeltaBackoffSeconds
        {
            get
            {
                return Convert.ToInt32(ConfigurationManager.AppSettings["TransientFaultHandlingDeltaBackoffSeconds"]);
            }
        }

        public static string ClientSettingsProviderServiceUri
        {
            get
            {
                return ConfigurationManager.AppSettings["ClientSettingsProvider.ServiceUri"];
            }
        }

        #endregion
    }
}
