using System;
using System.Collections.Generic;

namespace Tenant.Mvc.Models
{
    public class VenueIndexViewModel
    {
        #region - Properties -

        public List<VenueViewModel> Venues { get; set; }

        #endregion

        #region - Class VenueViewModel -

        public class VenueViewModel
        {
            public int VenueId { get; set; }
            public String VenueName { get; set; }
            public int Capacity { get; set; }
            public String Description { get; set; }
        }

        #endregion
    }
}