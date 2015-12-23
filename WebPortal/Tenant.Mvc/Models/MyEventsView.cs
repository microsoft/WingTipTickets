using System.Collections.Generic;
using Tenant.Mvc.Models.ConcertTicketDB;
using Tenant.Mvc.Models.VenuesDB;

namespace Tenant.Mvc.Models
{
    public class MyEventsView
    {
        #region - Properties -

        public List<PurchasedTicket> PurchasedTickets { get; set; }
        public List<Venue> MyVenues { get; set; }

        #endregion

        #region - Constructors -

        public MyEventsView()
        {
            PurchasedTickets = new List<PurchasedTicket>();
            MyVenues = new List<Venue>();
        }

        #endregion
    }
}