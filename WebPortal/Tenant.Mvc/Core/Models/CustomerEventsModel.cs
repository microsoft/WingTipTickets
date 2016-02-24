using System.Collections.Generic;
using Tenant.Mvc.Models.DomainModels;

namespace Tenant.Mvc.Core.Models
{
    public class CustomerEventsModel
    {
        #region - Properties -

        public List<PurchasedTicketModel> PurchasedTickets { get; set; }
        public List<VenueModel> MyVenues { get; set; }

        #endregion

        #region - Constructors -

        public CustomerEventsModel()
        {
            PurchasedTickets = new List<PurchasedTicketModel>();
            MyVenues = new List<VenueModel>();
        }

        #endregion
    }
}