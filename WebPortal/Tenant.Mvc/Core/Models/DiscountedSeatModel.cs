using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tenant.Mvc.Core.Models
{
    public class DiscountedSeatModel
    {
        #region - Properties 

        public int DiscountId { get; set; }
        public int SeatSectionId { get; set; }
        public int SeatNumber { get; set; }
        public decimal InitialPrice { get; set; }
        public int Discount { get; set; }
        public decimal FinalPrice { get; set; }

        #endregion

        #region - Constructors -

        public DiscountedSeatModel()
        {
        }

        public DiscountedSeatModel(int discountId, int seatSectionId, int seatNumber, decimal initialPrice, int discount, decimal finalPrice)
        {
            DiscountId = discountId;
            SeatSectionId = seatSectionId;
            SeatNumber = seatNumber;
            InitialPrice = initialPrice;
            Discount = discount;
            FinalPrice = finalPrice;
        }

        #endregion
    }
}