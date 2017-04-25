using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Tenant.Mvc.Core.Models
{
    public class DiscountModel
    {
        #region - Properties 

        public int SeatSectionId { get; set; }
        public int SeatNumber { get; set; }
        public decimal InitialPrice { get; set; }
        public int Discount { get; set; }
        public decimal FinalPrice { get; set; }

        #endregion
    }
}