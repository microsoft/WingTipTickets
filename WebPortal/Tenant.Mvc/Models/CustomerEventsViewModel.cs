using System;
using System.Collections.Generic;

namespace Tenant.Mvc.Models
{
    public class CustomerEventsViewModel
    {
        #region - Properties -

        public List<PurchasedTicketViewModel> TicketList { get; set; }
        public List<VenueViewModel> VenuesList { get; set; }

        #endregion

        #region - Constructors -

        public CustomerEventsViewModel()
        {
            TicketList = new List<PurchasedTicketViewModel>();
            VenuesList = new List<VenueViewModel>();
        }

        #endregion

        #region - Class VenueViewModel -

        public class VenueViewModel
        {
            public int VenueId { get; set; }
            public string VenueName { get; set; }

            public int CityId { get; set; }
            public string CityName { get; set; }

            public int StateId { get; set; }
            public string StateName { get; set; }

            public int Capacity { get; set; }
        }

        #endregion

        #region - Class PurchasedTicketViewModel -

        public class PurchasedTicketViewModel
        {
            public int ConcertId { get; set; }
            public DateTime ConcertDate { get; set; }

            public int PerformerId { get; set; }
            public string PerformerName { get; set; }

            public int VenueId { get; set; }
            public string VenueName { get; set; }

            public int TicketQuantity { get; set; }
            public string SectionName { get; set; }
            public string SeatName { get; set; }
        }

        #endregion
    }
}