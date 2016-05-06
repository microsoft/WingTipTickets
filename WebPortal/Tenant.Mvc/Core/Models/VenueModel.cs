using System;
using System.Collections.Generic;

namespace Tenant.Mvc.Core.Models
{
    public class VenueModel
    {
        #region - Properties -

        public int VenueId { get; set; }
        public String VenueName { get; set; }
        public int Capacity { get; set; }
        public String Description { get; set; }
        public CityModel VenueCityModel { get; set; }
        //public List<SeatSection> VenueSeatSections { get; set; }
        public int ConcertQty { get; set; }

        #endregion
    }
}