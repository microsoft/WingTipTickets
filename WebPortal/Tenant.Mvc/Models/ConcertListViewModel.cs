using System;
using System.Collections.Generic;
using Tenant.Mvc.Models.ViewModels;

namespace Tenant.Mvc.Models.DomainModels
{
    public class ConcertListViewModel
    {
        #region - Properties -

        public List<ConcertViewModel> ConcertsList { get; set; }
        public List<VenueViewModel> VenuesList { get; set; }
        public int SelectedCity { get; set; }
        public int SelectedVenue { get; set; }

        #endregion

        #region - Constructors -

        public ConcertListViewModel()
        {
            ConcertsList = new List<ConcertViewModel>();
            VenuesList = new List<VenueViewModel>();
        }

        #endregion

        public class ConcertViewModel
        {
            #region - Properties -

            public int ConcertId { get; set; }
            public string Name { get; set; }
            public string Performer { get; set; }
            public string Venue { get; set; }
            public DateTime Date { get; set; }

            #endregion    
        }

        //public class VenueViewModel
        //{
        //    public int VenueId { get; set; }
        //    public String VenueName { get; set; }
        //    public int Capacity { get; set; }
        //    public String Description { get; set; }
        //    public CityModel VenueCityModel { get; set; }
        //    public List<SeatSection> VenueSeatSections { get; set; }
        //    public int ConcertQty { get; set; }
        //}
    }
}