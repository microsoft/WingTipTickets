using System.Collections.Generic;

namespace Tenant.Mvc.Core.Models
{
    public class PurchaseTicketsModel
    {
        #region - Properties -

        public int ConcertId { get; set; }
        public int SeatSectionId { get; set; }

        public int CustomerId { get; set; }
        public string CustomerName { get; set; }

        public int Quantity { get; set; }
        public string Seat { get; set; }
        public int TMinusDaysToConcert { get; set; }
        public decimal Discount { get; set; }

        #endregion
    }
}