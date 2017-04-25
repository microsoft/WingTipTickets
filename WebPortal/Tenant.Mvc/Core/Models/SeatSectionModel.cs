using System;

namespace Tenant.Mvc.Core.Models
{
    public class SeatSectionModel
    {
        #region - Properties -

        public int SeatSectionId { get; set; }
        public int SeatCount { get; set; }
        public string Description { get; set; }
        public int VenueId { get; set; }
        public int TicketLevelId { get; set; }
        public decimal TicketPrice { get; set; }
        public string TicketLevelDescription { get; set; }

        #endregion
    }
}