using System;
using System.Collections.Generic;

namespace Tenant.Mvc.Models
{
    public class ConcertListViewModel
    {
        #region - Properties -

        public List<ConcertViewModel> ConcertList { get; set; }
        public List<VenueViewModel> VenueList { get; set; }
        public int SelectedCity { get; set; }
        public int SelectedVenue { get; set; }

        #endregion

        #region - Constructors -

        public ConcertListViewModel()
        {
            ConcertList = new List<ConcertViewModel>();
            VenueList = new List<VenueViewModel>();
        }

        #endregion

        #region - Class ConcertViewModel -

        public class ConcertViewModel
        {
            public int ConcertId { get; set; }
            public string Name { get; set; }
            public string Performer { get; set; }
            public string Venue { get; set; }
            public DateTime Date { get; set; }   
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

            public int ConcertCount { get; set; }
        }

        #endregion
    }
}