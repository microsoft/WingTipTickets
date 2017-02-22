using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using Tenant.Mvc.Core.Models;
using WingTipTickets;

namespace Tenant.Mvc.Core.Contexts
{
    public class AllSeatsContext
    {

        #region - Get Methods -

        public AllSeatsModel GetSeatDetails(string seatDescription, int tminusDaysToConcert)
        {
            var seatDetails = new AllSeatsModel();

            var sqlQuery = $@"SELECT * FROM AllSeats WHERE SeatDescription = '{seatDescription}' AND TMinusDaysToConcert = {tminusDaysToConcert}";

            using (var cmd = new SqlCommand(sqlQuery, WingtipTicketApp.CreateTenantConnectionDatabase1()))
            {
                using (var sdAdapter = new SqlDataAdapter(cmd))
                {
                    using (var ds = new DataSet())
                    {
                        sdAdapter.Fill(ds);

                        seatDetails = (from DataRow dr in ds.Tables[0].Rows
                            select
                                new AllSeatsModel(Convert.ToInt32(dr[0].ToString()), dr[1].ToString(),
                                    Convert.ToInt32(dr[2].ToString()), Convert.ToInt32(dr[3].ToString()),
                                    Convert.ToInt32(dr[4].ToString()), Convert.ToInt32(dr[5].ToString()),
                                    Convert.ToInt32(dr[6].ToString()), Convert.ToInt32(dr[7].ToString())))
                            .FirstOrDefault();

                    }
                }
            }

            return seatDetails;
        }

        #endregion



        #region - Save Methods -

        public int UpdateSeatDetails(int discount, string seatDescription, int tMinusDaysToConcert, int count)
        {
            string columnName = "[0%]";
            switch (discount)
            {
                case 10:
                    columnName = "[10%]";
                    break;
                case 20:
                    columnName = "[20%]";
                    break;
                case 30:
                    columnName = "[30%]";
                    break;
            }

            using (var connection = WingtipTicketApp.CreateTenantConnectionDatabase1())
            {
                connection.Open();

                var sqlQuery =
                  $"UPDATE AllSeats SET {columnName} = {count} WHERE SeatDescription = '{seatDescription}' AND TMinusDaysToConcert = {tMinusDaysToConcert}";

                using (var insertCommand = new SqlCommand(sqlQuery, connection))
                {
                    insertCommand.ExecuteNonQuery();
                }

                connection.Close();
                connection.Dispose();
            }

            return 1;
        }

        #endregion
    }
}