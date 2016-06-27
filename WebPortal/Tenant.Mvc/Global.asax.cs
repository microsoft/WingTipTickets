using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using Microsoft.Azure.Search;
using Tenant.Mvc;

namespace WingTipTickets
{
    #region - AppConfig Class -

    public class AppConfig
    {
        // Tenant Settings
        public string TenantName { get; set; }
        public string TenantEventType { get; set; }
        public string TenantDatabaseServer { get; set; }
        public string TenantDatabase1 { get; set; }
        public string TenantDatabase2 { get; set; }

        // Recommendation Settings
        public string RecommendationDatabaseServer { get; set; }
        public string RecommendationDatabase { get; set; }

        // Shared Settings
        public string DatabaseUser { get; set; }
        public string DatabasePassword { get; set; }
        public bool AuditingEnabled { get; set; }
        public bool RunningInDev { get; set; }

        // Keys
        public string SearchServiceKey { get; set; }
        public string SearchServiceName { get; set; }
        public string DocumentDbUri { get; set; }
        public string DocumentDbKey { get; set; }
    }

    #endregion

    public class WingtipTicketApp : System.Web.HttpApplication
    {
        #region - Application Start -

        public static readonly object _lock = new object();
        public static AppConfig Config = null;
        public static SearchIndexClient SearchIndexClient;

        protected void Application_Start()
        {
            InitializeConfig();
            InitializeSearchService();

            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            UnityConfig.RegisterComponents();
        }

        #endregion

        #region - Initialization Methods -

        public static bool InitializeConfig()
        {
            Config = ReadAppConfig();
            return true;
        }

        public static void InitializeSearchService()
        {
            var searchServiceClient = new SearchServiceClient(Config.SearchServiceName, new SearchCredentials(Config.SearchServiceKey));

            SearchIndexClient = searchServiceClient.Indexes.GetClient("concerts");
        }

        #endregion

        #region - Connection Methods -

        public static string GetTenantConnectionString(string database)
        {
            var connectionString = BuildConnectionString(Config.TenantDatabaseServer, database, Config.DatabaseUser, Config.DatabasePassword, Config.RunningInDev);

            return connectionString;
        }

        public static string GetRecommendationConnectionString()
        {
            return BuildConnectionString(Config.RecommendationDatabaseServer, Config.RecommendationDatabase, Config.DatabaseUser, Config.DatabasePassword, Config.RunningInDev);
        }

        public static SqlConnection CreateTenantConnectionDatabase1()
        {
            return new SqlConnection(GetTenantConnectionString(Config.TenantDatabase1));
        }

        public static SqlConnection CreateTenantConnectionDatabase2()
        {
            return new SqlConnection(GetTenantConnectionString(Config.TenantDatabase2));
        }

        public static SqlConnection CreateRecommendationSqlConnection()
        {
            return new SqlConnection(GetRecommendationConnectionString()); 
        }

        #endregion

        #region - Private Methods -

        private static string BuildConnectionString(string databaseServer, string database, string username, string password, bool runningInDev)
        {
            var server = databaseServer.Split('.');

            if (runningInDev)
            {
                return String.Format("Server={0};Database={1};User ID={2};Password={3};Connection Timeout=30;",
                                     server[0], database, username, password);
            }
            
            return String.Format("Server=tcp:{0},1433;Database={1};User ID={2}@{3};Password={4};Trusted_Connection=False;Encrypt=True;Connection Timeout=30;",
                                     databaseServer, database, username, server[0], password);
        }

        private static AppConfig ReadAppConfig()
        {
            const string secureDatabaseUrl = ".database.secure.windows.net";
            const string unsecuredDatabaseUrl = ".database.windows.net";

            var appConfig = new AppConfig
            {
                TenantName = ConfigurationManager.AppSettings["TenantName"].Trim(),
                TenantEventType = ConfigurationManager.AppSettings["TenantEventType"].Trim(), 
                TenantDatabaseServer = ConfigurationManager.AppSettings["TenantPrimaryDatabaseServer"].Trim(),
                TenantDatabase1 = ConfigurationManager.AppSettings["TenantDatabase1"].Trim(),
                TenantDatabase2 = ConfigurationManager.AppSettings["TenantDatabase2"].Trim(),

                RecommendationDatabaseServer = ConfigurationManager.AppSettings["RecommendationDatabaseServer"].Trim(),
                RecommendationDatabase = ConfigurationManager.AppSettings["RecommendationDatabase"].Trim(),

                DatabaseUser = ConfigurationManager.AppSettings["DatabaseUser"].Trim(),
                DatabasePassword = ConfigurationManager.AppSettings["DatabasePassword"].Trim(),
                AuditingEnabled = string.IsNullOrEmpty(ConfigurationManager.AppSettings["AuditingEnabled"]) || Convert.ToBoolean(ConfigurationManager.AppSettings["AuditingEnabled"]),
                RunningInDev = string.IsNullOrEmpty(ConfigurationManager.AppSettings["RunningInDev"]) || Convert.ToBoolean(ConfigurationManager.AppSettings["RunningInDev"]),

                SearchServiceKey = ConfigurationManager.AppSettings["SearchServiceKey"].Trim(),
                SearchServiceName = ConfigurationManager.AppSettings["SearchServiceName"].Trim(),

                DocumentDbUri = ConfigurationManager.AppSettings["DocumentDbUri"].Trim(),
                DocumentDbKey = ConfigurationManager.AppSettings["DocumentDbKey"].Trim(),
            };
                
            // Adjust Tenant Database Server
            if (!String.IsNullOrEmpty(appConfig.TenantDatabaseServer))
            {
                appConfig.TenantDatabaseServer += appConfig.AuditingEnabled ? secureDatabaseUrl : unsecuredDatabaseUrl;
            }

            // Adjust Recommendation Database Server
            if (!String.IsNullOrEmpty(appConfig.RecommendationDatabaseServer))
            {
                appConfig.RecommendationDatabaseServer += appConfig.AuditingEnabled ? secureDatabaseUrl : unsecuredDatabaseUrl;
            }

            return appConfig;
        }

        #endregion
    }
}