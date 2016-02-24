using System;

namespace Tenant.Mvc.Core.Models
{
    public class PurchasedTicketModel
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

        public PurchasedTicketModel()
        {
        }

        public PurchasedTicketModel(string performerName, int performerId, string venueName, int ticketQuantity, string sectionName, string seatName, DateTime eventDateTime, int concertId, int venueId)
        {
            ConcertId = concertId;
            PerformerId = performerId;
            PerformerName = performerName;
            VenueId = venueId;
            VenueName = venueName;
            TicketQuantity = ticketQuantity;
            SectionName = sectionName;
            SeatName = seatName;
            EventDateTime = eventDateTime;
        }

        #endregion
    }
}