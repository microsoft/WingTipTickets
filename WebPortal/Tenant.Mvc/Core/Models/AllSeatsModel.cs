using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tenant.Mvc.Core.Models
{
    public class AllSeatsModel
    {
        #region - Properties 

        public int SeatId { get; set; }
        public string SeatDescription { get; set; }
        public int SeatNumber { get; set; }
        public int TMinusDaysToConcert { get; set; }
        public int DiscountTen { get; set; }
        public int DiscountTwenty { get; set; }
        public int DiscountThirty { get; set; }
        public int DiscountZero { get; set; }

        #endregion


        #region - Constructors -

        public AllSeatsModel()
        {
        }

        public AllSeatsModel(int seatId, string seatDescription, int seatNumber, int tMinusDaysToConcert, int discountTen, int discountTwenty, int discountThirty, int discountZero)
        {
            SeatId = seatId;
            SeatDescription = seatDescription;
            SeatNumber = seatNumber;
            TMinusDaysToConcert = tMinusDaysToConcert;
            DiscountTen = discountTen;
            DiscountTwenty = discountTwenty;
            DiscountThirty = discountThirty;
            DiscountZero = discountZero;
        }

        #endregion

    }
}