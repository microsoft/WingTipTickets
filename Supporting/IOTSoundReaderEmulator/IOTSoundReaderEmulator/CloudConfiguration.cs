using System;
using System.Configuration;

namespace IOTSoundReaderEmulator
{
    public static class CloudConfiguration
    {
        // Database Config
        public static string TenantPrimaryDatabaseServer => ConfigurationManager.AppSettings["TenantPrimaryDatabaseServer"];
        public static string TenantDatabase1 => ConfigurationManager.AppSettings["TenantDatabase1"];
        public static string DatabaseUser => ConfigurationManager.AppSettings["DatabaseUser"];
        public static string DatabasePassword => ConfigurationManager.AppSettings["DatabasePassword"];

        // System Config
        public static bool RunningInDev => Convert.ToBoolean(ConfigurationManager.AppSettings["RunningInDev"]);

        // Event Hub config
        public static string EventHubName => ConfigurationManager.AppSettings["EventHubName"];
        public static string EventHubConnString => ConfigurationManager.AppSettings["Microsoft.ServiceBus.ConnectionString"];

        // DocumentDB config
        public static string DocumentDbUri => ConfigurationManager.AppSettings["DocumentDbUri"];
        public static string DocumentDbKey => ConfigurationManager.AppSettings["DocumentDbKey"];
        public static string DocumentDbDatabaseName => ConfigurationManager.AppSettings["DocumentDbDatabaseName"];
        public static string DocumentDbCollectionName => ConfigurationManager.AppSettings["DocumentDbCollectionName"];

        public static string UnsecuredDatabaseUrl = ".database.windows.net";
    }
}
