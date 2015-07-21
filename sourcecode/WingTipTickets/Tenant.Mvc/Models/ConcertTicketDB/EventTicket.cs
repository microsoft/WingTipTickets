using System;

namespace Tenant.Mvc.Models.ConcertTicketDB
{
    public class ConcertTicket
    {
        public int TicketId { get; set; }
        public int CustomerId { get; set; }
        public String Name { get; set; }
        public int ConcertId { get; set; }
        public int TicketLevelId { get; set; }
        public int Price { get; set; }
        public DateTime PurchasedDate { get; set; }
        public ConcertTicket() { }
        public ConcertTicket(int ticketId, int customerId, string name, int concertId, int ticketLevelId, int price, DateTime purchaseDate)
        {
            TicketId = ticketId;
            CustomerId = customerId;
            Name = name;
            ConcertId = concertId;
            TicketLevelId = ticketLevelId;
            Price = price;
            PurchasedDate = purchaseDate;
        }
    }
    public class PurchasedTicket
    {
        public int ConcertId { get; set; }
        public string PerformerName { get; set; }
        public int PerformerId { get; set; }
        public string VenueName { get; set; }
        public int VenueId { get; set; }
        public int TicketQuantity { get; set; }
        public string SectionName { get; set; }
        public string SeatName { get; set; }
        public DateTime EventDateTime { get; set; }
        public PurchasedTicket() { }
        public PurchasedTicket(string performerName, int performerId, string venueName, int ticketQuantity, string sectionName, string seatName, DateTime eventDateTime, int concertId, int venueId)
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
    }
}