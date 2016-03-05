using System.Collections.Generic;
using System.Web.Mvc;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Models
{
    public class EventAdministrationViewModel
    {
        #region - Properties -
        
        public int CityId { get; set; }
        public int VenueId { get; set; }
        public int EventId { get; set; }
        public int ArtistId { get; set; }
        public int Year { get; set; }
        public int Month { get; set; }
        public int Day { get; set; }

        public string NewCity { get; set; }
        public string NewVenue { get; set; }
        public string NewEvent { get; set; }
        public string NewArtist { get; set; }
        public string Description { get; set; }

        public SelectList Artists { get; set; }
        public SelectList Cities { get; set; }
        public SelectList Venues { get; set; }
        public SelectList Events { get; set; }
        public SelectList Years { get; set; }
        public SelectList Months { get; set; }
        public SelectList Days { get; set; }

        #endregion
    }
}