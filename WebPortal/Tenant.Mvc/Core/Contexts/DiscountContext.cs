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
    public class DiscountContext
    {
        #region - Get Methods -

        public List<DiscountedSeatModel> GetDiscountedSeat(int seatSectionId, int seatNumber)
        {
            var discountedSeatModels = new List<DiscountedSeatModel>();

            var sqlQuery = $@"SELECT * FROM Discount WHERE SeatSectionId = {seatSectionId} AND SeatNumber = {seatNumber} ORDER BY DiscountId DESC";

            using (var cmd = new SqlCommand(sqlQuery, WingtipTicketApp.CreateTenantConnectionDatabase1()))
            {
                using (var sdAdapter = new SqlDataAdapter(cmd))
                {
                    using (var ds = new DataSet())
                    {
                        sdAdapter.Fill(ds);

                        discountedSeatModels.AddRange(
                            from DataRow dr in ds.Tables[0].Rows
                            select new DiscountedSeatModel(Convert.ToInt32(dr[0].ToString()), Convert.ToInt32(dr[1].ToString()), Convert.ToInt32(dr[2].ToString()), Convert.ToDecimal(dr[3].ToString()), Convert.ToInt32(dr[4].ToString()), Convert.ToDecimal(dr[5].ToString())));
                    }
                }
            }
            return discountedSeatModels;
        }

        #endregion

        #region - Save Methods -

        public DiscountedSeatModel ApplyDiscount(DiscountModel discountModel)
        {
            using (var insertConnection = WingtipTicketApp.CreateTenantConnectionDatabase1())
            {
                insertConnection.Open();

                var insertQuery =
                    $@"INSERT INTO Discount (SeatSectionId, SeatNumber, InitialPrice, Discount, FinalPrice) VALUES ('{
                        discountModel.SeatSectionId}', '{discountModel.SeatNumber}', '{discountModel.InitialPrice}', '{
                        discountModel.Discount}', '{discountModel.FinalPrice}')";

                using (var insertCommand = new SqlCommand(insertQuery, insertConnection))
                {
                    insertCommand.ExecuteNonQuery();
                }

                insertConnection.Close();
                insertConnection.Dispose();
            }

            return GetDiscountedSeat(discountModel.SeatSectionId, discountModel.SeatNumber).First();
        }

        #endregion
    }
}