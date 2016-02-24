using System.Collections.Generic;
using Tenant.Mvc.Models.DomainModels;

namespace Tenant.Mvc.Core.Models
{
    public class DataForAdminPortalPage
    {
        #region - Properties -

        public List<PerformerModel> Artists { get; set; }
        public List<CityModel> Cities { get; set; }
        public List<VenueModel> Venues { get; set; }
        public List<ConcertModel> Events { get; set; }
        public int SelectedArtist { get; set; }
        public int SelectedCity { get; set; }
        public int SelectedVenue { get; set; }
        public ConcertModel SelectedEvent { get; set; }

        #endregion
    }
}