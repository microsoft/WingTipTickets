using System;
using System.Collections.Generic;

namespace Tenant.Mvc.Models.ViewModels
{
    public class VenueViewModel
    {
        public int VenueId { get; set; }
        public String VenueName { get; set; }
        public int Capacity { get; set; }
        public String Description { get; set; }
        public CityViewModel VenueCity { get; set; }
        public List<SeatSectionViewModel> VenueSeatSections { get; set; }
        public int ConcertQty { get; set; }
    }
}