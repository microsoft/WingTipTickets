using System;
using System.Configuration;

namespace Tenant.Mvc.Core.Helpers
{
    public static class ConfigHelper
    {
        #region - Properties -

        public static string PowerbiApiUrl
        {
            get
            {
                return ConfigurationManager.AppSettings["powerbiApiUrl"];
            }
        }

        public static string PowerbiSigningKey
        {
            get
            {
                return ConfigurationManager.AppSettings["powerbiSigningKey"];
            }
        }

        public static string PowerbiWorkspaceCollection
        {
            get
            {
                return ConfigurationManager.AppSettings["powerbiWorkspaceCollection"];
            }
        }

        public static Guid PowerbiWorkspaceId
        {
            get
            {
                return new Guid(ConfigurationManager.AppSettings["powerbiWorkspaceId"]);
            }
        }

        public static string SeatMapReportId
        {
            get
            {
                return ConfigurationManager.AppSettings["SeatMapReportId"];
            }
        }

        #endregion
    }
}
