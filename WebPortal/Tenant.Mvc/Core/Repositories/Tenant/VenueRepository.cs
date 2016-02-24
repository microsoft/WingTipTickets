using System.Collections.Generic;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class VenueRepository : BaseRepository, IVenueRepository
    {
        #region - Implementation -

        public List<VenueModel> GetVenues(int cityId = 0)
        {
            return Context.Venues.GetVenues(cityId);
        }

        public VenueModel GetVenueByVenueId(int venueId)
        {
            return Context.Venues.GetVenueByVenueId(venueId);
        }

        public List<SeatSection> GetSeatMapForVenue(int venueId)
        {
            return Context.Venues.GetSeatMapForVenue(venueId);
        }

        public VenueModel AddNewVenue(string venueName, int cityId)
        {
            return Context.Venues.AddNewVenue(venueName, cityId);
        }

        #endregion
    }
}