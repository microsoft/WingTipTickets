using System;

namespace Tenant.Mvc.Models.DomainModels
{
    public class PurchasedTicketViewModel
    {
        #region - Properties -

        public int ConcertId { get; set; }
        public string PerformerName { get; set; }
        public int PerformerId { get; set; }
        public string VenueName { get; set; }
        public int VenueId { get; set; }
        public int TicketQuantity { get; set; }
        public string SectionName { get; set; }
        public string SeatName { get; set; }
        public DateTime EventDateTime { get; set; }

        #endregion

        #region - Constructors -

        public PurchasedTicketViewModel()
        {
        }

        #endregion
    }
}