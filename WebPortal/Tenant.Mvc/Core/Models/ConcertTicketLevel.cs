namespace Tenant.Mvc.Core.Models
{
    public class ConcertTicketLevel
    {
        #region - Properties -

        public int TicketLevelId { get; set; }
        public string Description { get; set; }
        public int ConcertId { get; set; }
        public int SeatSectionId { get; set; }
        public decimal TicketPrice { get; set; }

        #endregion

        #region - Constructors -

        public ConcertTicketLevel()
        {
        }

        public ConcertTicketLevel(int ticketLevelId, string description, int concertId, int seatSectionId, decimal ticketPrice)
        {
            TicketLevelId = ticketLevelId;
            Description = description;
            ConcertId = concertId;
            SeatSectionId = seatSectionId;
            TicketPrice = ticketPrice;
        }

        #endregion
    }
}