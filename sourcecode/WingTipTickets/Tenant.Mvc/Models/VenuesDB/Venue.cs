using System;
using System.Collections.Generic;

namespace Tenant.Mvc.Models.VenuesDB
{
    public class Venue
    {
        #region - Properties -

        public int VenueId { get; set; }
        public String VenueName { get; set; }
        public int Capacity { get; set; }
        public String Description { get; set; }
        public City VenueCity { get; set; }
        public List<SeatSection> VenueSeatSections { get; set; }

        #endregion
    }
}