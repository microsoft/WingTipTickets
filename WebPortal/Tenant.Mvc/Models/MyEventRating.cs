using Tenant.Mvc.Models.ConcertTicketDB;

namespace Tenant.Mvc.Models
{
    public class MyEventRating
    {
        #region - Properties -

        public PurchasedTicket PurchasedTicket { get; set; }
        public string Comments { get; set; }
        public int Score { get; set; }

        #endregion
    }
}