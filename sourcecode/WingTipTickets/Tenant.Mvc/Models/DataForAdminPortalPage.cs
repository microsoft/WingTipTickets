using System.Collections.Generic;
using Tenant.Mvc.Models.ConcertsDB;
using Tenant.Mvc.Models.VenuesDB;

namespace Tenant.Mvc.Models
{
    public class DataForAdminPortalPage
    {
        public List<Performer> Artists { get; set; }
        public List<City> Cities { get; set; }
        public List<Venue> Venues { get; set; }
        public List<Concert> Events { get; set; }
        public int SelectedArtist { get; set; }
        public int SelectedCity { get; set; }
        public int SelectedVenue { get; set; }
        public Concert SelectedEvent { get; set; }
    }
}