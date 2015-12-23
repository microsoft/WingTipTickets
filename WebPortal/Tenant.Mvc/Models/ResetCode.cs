using System.Data.SqlClient;
using System.IO;
using System.Web;
using WingTipTickets;

namespace Tenant.Mvc.Models
{
    public class ResetCode
    {   
        #region - Public Methods -

        public bool RefreshConcerts(bool fullReset)
        {
            #region Full Reset - Trim Extra Concerts

            if (fullReset)
            {
                var trimSql = ReadSqlFromFile(HttpContext.Current.Server.MapPath("~/SqlScripts/TrimConcerts.sql"));

                if (!string.IsNullOrEmpty(trimSql))
                {
                    using (var conn = new SqlConnection(WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName)))
                    {
                        conn.Open();

                        using (var cmd = new SqlCommand(trimSql, conn))
                        {
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }

            #endregion Full Reset - Trim Extra Concerts

            #region Push Concert Dates to Future

            var resetDatesSql = ReadSqlFromFile(HttpContext.Current.Server.MapPath("~/SqlScripts/ResetConcertDates.sql"));

            if (!string.IsNullOrEmpty(resetDatesSql))
            {
                using (var conn = new SqlConnection(WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName)))
                {
                    conn.Open();

                    using (var cmd = new SqlCommand(resetDatesSql, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            #endregion Push Concert Dates to Future

            return true;
        }
        
        #endregion

        #region - Private Methods -

        private static string ReadSqlFromFile(string path)
        {
            using (var sr = new StreamReader(path))
            {
                return sr.ReadToEnd();
            }
        }

        #endregion
    }
}