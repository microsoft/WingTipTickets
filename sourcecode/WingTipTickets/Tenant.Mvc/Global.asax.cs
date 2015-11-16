using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using Tenant.Mvc;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using Microsoft.Azure.Search;

namespace WingTipTickets
{
    public class AppConfig
    {

        public string TenantEventTypeGenre { get; set; }
        public string TenantName { get; set; }
        public string DatabaseUserName { get; set; }
        public string DatabaseUserPassword { get; set; }
        public string PrimaryDatabaseServer { get; set; }
        public string SecondaryDatabaseServer { get; set; }
        public string TenantDbName { get; set; }
        public bool EnableAuditing { get; set; }
        public string SearchServiceKey { get; set; }
        public string SearchServiceName { get; set; }

        public string DocumentDbServiceEndpointUri { get; set; }
        public string DocumentDbServiceAuthorizationKey { get; set; }

        public string RecommendationSiteUrl { get; set; }
    }

    public class WingtipTicketApp : System.Web.HttpApplication
    {
        #region Application Functionality
        public static readonly object _lock = new object();
        public static AppConfig Config = null;
        public static SearchIndexClient SearchIndexClient;

        protected void Application_Start()
        {
            InitializeConfig();

            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            DataConfig.Configure();
        }
        #endregion Application Functionality

        #region Web.Config Initialization

        public static bool InitializeConfig()
        {
            Config = readAppConfig();
            return true;
        }

        #region App Configuration
        private static AppConfig readAppConfig()
        {
            var appConfig = new AppConfig();
            appConfig.TenantEventTypeGenre = ConfigurationManager.AppSettings["TenantEventTypeGenre"].Trim();
            appConfig.TenantName = ConfigurationManager.AppSettings["TenantName"].Trim();
            String secureDbUrlTextToAppend = ".database.secure.windows.net";
            String dbUrlTextToAppend = ".database.windows.net";
            appConfig.DatabaseUserName = ConfigurationManager.AppSettings["DatabaseUserName"].Trim();
            appConfig.DatabaseUserPassword = ConfigurationManager.AppSettings["DatabaseUserPassword"].Trim();
            appConfig.PrimaryDatabaseServer = ConfigurationManager.AppSettings["PrimaryDatabaseServer"].Trim();
            appConfig.SecondaryDatabaseServer = ConfigurationManager.AppSettings["SecondaryDatabaseServer"].Trim();
            appConfig.EnableAuditing = string.IsNullOrEmpty(ConfigurationManager.AppSettings["EnableAuditing"]) ? true : Convert.ToBoolean(ConfigurationManager.AppSettings["EnableAuditing"]);
            if (!String.IsNullOrEmpty(appConfig.PrimaryDatabaseServer))
                if (appConfig.EnableAuditing == true)
                    appConfig.PrimaryDatabaseServer += secureDbUrlTextToAppend;
                else { appConfig.PrimaryDatabaseServer += dbUrlTextToAppend; }
            if (!String.IsNullOrEmpty(appConfig.SecondaryDatabaseServer))
                if (appConfig.EnableAuditing == true)
                    appConfig.SecondaryDatabaseServer += secureDbUrlTextToAppend;
                else { appConfig.SecondaryDatabaseServer += dbUrlTextToAppend; }
            appConfig.TenantDbName = ConfigurationManager.AppSettings["TenantDbName"].Trim();
            appConfig.SearchServiceKey = ConfigurationManager.AppSettings["SearchServiceKey"].Trim();
            appConfig.SearchServiceName = ConfigurationManager.AppSettings["SearchServiceName"].Trim();

            appConfig.DocumentDbServiceEndpointUri = ConfigurationManager.AppSettings["DocumentDbServiceEndpointUri"].Trim();
            appConfig.DocumentDbServiceAuthorizationKey = ConfigurationManager.AppSettings["DocumentDbServiceAuthorizationKey"].Trim();

            appConfig.RecommendationSiteUrl = ConfigurationManager.AppSettings["RecommendationSiteUrl"].Trim();

            return appConfig;
        }
        #endregion App Configuration

        #region Connection String
        public static string ConstructConnection(string serverName, string dbName)
        {
            string[] server = serverName.Split('.');
            return String.Format("Server=tcp:{0},1433;Database={1};User ID={2}@{3};Password={4};Trusted_Connection=False;Encrypt=True;Connection Timeout=30;",
                                        serverName, dbName, WingtipTicketApp.Config.DatabaseUserName, server[0], WingtipTicketApp.Config.DatabaseUserPassword);
        }
        #endregion Connection String

    }
    #endregion Web.Config Initialization
}