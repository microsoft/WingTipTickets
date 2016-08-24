using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using WingTipTickets;

namespace Tenant.Mvc.Core.Helpers
{
    public static class DataHelper
    {   
        #region - Public Methods -

        public static bool RefreshConcerts(bool fullReset)
        {
            try
            {
                if (fullReset)
                {
                    TrimConcerts();
                }

                ResetConcertDates();

                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public static void ExecuteNonQuery(string sqlScript)
        {
            // Stop if no script supplied
            if (string.IsNullOrEmpty(sqlScript))
            {
                throw new Exception("No Sql to specified to Execute");
            }

            // Run the script
            using (var conn = WingtipTicketApp.CreateTenantConnectionDatabase1())
            {
                conn.Open();

                using (var cmd = new SqlCommand(sqlScript, conn))
                {
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public static List<TModelType> ExecuteReader<TModelType>(string sqlScript, Func<SqlDataReader, TModelType> mapper)
        {
            var items = new List<TModelType>();

            // Stop if no script supplied
            if (string.IsNullOrEmpty(sqlScript))
            {
                throw new Exception("No Sql to specified to Execute");
            }

            // Run the script
            using (var connection = WingtipTicketApp.CreateTenantConnectionDatabase1())
            {
                connection.Open();

                using (var command = new SqlCommand(sqlScript, connection))
                {
                    var reader = command.ExecuteReader();

                    while (reader.Read() && mapper != null)
                    {
                        items.Add(mapper(reader));
                    }
                }
            }

            return items;
        }

        public static int ExecuteInsert(string sqlScript)
        {
            var entityId = 0;
            var dataSet = new DataSet();

            using (var connection = WingtipTicketApp.CreateTenantConnectionDatabase1())
            {
                using (var command = new SqlCommand(sqlScript, connection))
                {
                    using (var adapter = new SqlDataAdapter(command))
                    {
                        adapter.Fill(dataSet);

                        // Capture id of the new entity
                        if (dataSet.Tables.Count > 0 && dataSet.Tables[0].Rows.Count > 0 && dataSet.Tables[0].Rows[0][0] != DBNull.Value)
                        {
                            Int32.TryParse(dataSet.Tables[0].Rows[0][0].ToString(), out entityId);
                        }

                        return entityId;
                    }
                }
            }
        }

        #endregion

        #region - Private Methods -

        private static void ResetConcertDates()
        {
            // Reset concert dates to the future
            var sqlScript = ReadSqlFromFile(HttpContext.Current.Server.MapPath("~/SqlScripts/ResetConcertDates.sql"));

            ExecuteNonQuery(sqlScript);
        }

        private static void TrimConcerts()
        {
            // Trim any unessecary concerts
            var sqlScript = ReadSqlFromFile(HttpContext.Current.Server.MapPath("~/SqlScripts/TrimConcerts.sql"));

            ExecuteNonQuery(sqlScript);
        }

        private static string ReadSqlFromFile(string path)
        {
            // Read script file from path
            using (var sr = new StreamReader(path))
            {
                return sr.ReadToEnd();
            }
        }

        #endregion
    }
}