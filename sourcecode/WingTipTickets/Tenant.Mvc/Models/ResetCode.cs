using System.Data.SqlClient;
using System.IO;
using System.Web;
using WingTipTickets;

namespace Tenant.Mvc.Models
{
    public class ResetCode
    {   
        #region Public Functions
        public bool RefreshConcerts(bool FullReset)
        {
            try
            {
                #region Full Reset - Trim Extra Concerts
                if (FullReset)
                {
                    string trimSql = ReadSqlFromFile(HttpContext.Current.Server.MapPath("~/TSql/TrimConcerts.sql"));
                    if (!string.IsNullOrEmpty(trimSql))
                        using (SqlConnection conn = new SqlConnection(WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName)))
                        {
                            conn.Open();
                            using (SqlCommand cmd = new SqlCommand(trimSql, conn))
                                cmd.ExecuteNonQuery();
                        }
                }
                #endregion Full Reset - Trim Extra Concerts

                #region Push Concert Dates to Future
                string resetDatesSql = ReadSqlFromFile(HttpContext.Current.Server.MapPath("~/TSql/ResetConcertDates.sql"));
                if (!string.IsNullOrEmpty(resetDatesSql))
                    using (SqlConnection conn = new SqlConnection(WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName)))
                    {
                        conn.Open();
                        using (SqlCommand cmd = new SqlCommand(resetDatesSql, conn))
                            cmd.ExecuteNonQuery();
                    }
                #endregion Push Concert Dates to Future
                return true;
            }
            catch { return false; }
        }
        
        #endregion Public Functions

        #region Utility Function
        private string ReadSqlFromFile(string path)
        {
            try { using (StreamReader sr = new StreamReader(path)) return sr.ReadToEnd(); }
            catch { return string.Empty; }
        }
        #endregion Utility Function
    }
}