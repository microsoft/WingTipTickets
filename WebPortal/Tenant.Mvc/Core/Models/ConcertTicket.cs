using System;

namespace Tenant.Mvc.Core.Models
{
    public class ConcertTicket
    {
        #region - Properties -

        public int TicketId { get; set; }
        public int CustomerId { get; set; }
        public String Name { get; set; }
        public int ConcertId { get; set; }
        public int TicketLevelId { get; set; }
        public int Price { get; set; }
        public DateTime PurchasedDate { get; set; }
        public string SeatNumber { get; set; }

        #endregion

        #region - Constructors -

        public ConcertTicket()
        {
        }

        public ConcertTicket(int ticketId, int customerId, string name, int concertId, int ticketLevelId, int price, DateTime purchaseDate, string seatNumber)
        {
            TicketId = ticketId;
            CustomerId = customerId;
            Name = name;
            ConcertId = concertId;
            TicketLevelId = ticketLevelId;
            Price = price;
            PurchasedDate = purchaseDate;
            SeatNumber = seatNumber;
        }

        #endregion
    }
}