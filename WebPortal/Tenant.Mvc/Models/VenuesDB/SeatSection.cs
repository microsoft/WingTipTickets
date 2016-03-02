using System;

namespace Tenant.Mvc.Models.VenuesDB
{
    public class SeatSection
    {
        #region - Properties -

        public int SeatSectionId { get; set; }
        public int SeatCount { get; set; }
        public String Description { get; set; }
        public int VenueId { get; set; }
        public int TicketLevelId { get; set; }
        public decimal TicketPrice { get; set; }
        public String TicketLevelDescription { get; set; }

        #endregion
    }
}