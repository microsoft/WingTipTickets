using System.Collections.Generic;
using Tenant.Mvc.Models.ViewModels;

namespace Tenant.Mvc.Models.DomainModels
{
    public class EventsViewModel
    {
        #region - Properties -

        public List<PurchasedTicketViewModel> PurchasedTickets { get; set; }
        public List<VenueViewModel> Venues { get; set; }

        #endregion

        #region - Constructors -

        public EventsViewModel()
        {
            PurchasedTickets = new List<PurchasedTicketViewModel>();
            Venues = new List<VenueViewModel>();
        }

        #endregion
    }
}