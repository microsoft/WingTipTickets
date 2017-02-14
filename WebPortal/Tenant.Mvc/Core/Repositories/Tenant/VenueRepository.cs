using System.Collections.Generic;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class VenueRepository : BaseRepository, IVenueRepository
    {
        #region - Implementation -

        public List<VenueModel> GetVenues(int venueId = 0, int cityId = 0)
        {
            return Context.Venues.GetVenues(venueId, cityId);
        }

        public VenueModel GetVenueByVenueId(int venueId)
        {
            return Context.Venues.GetVenueByVenueId(venueId);
        }

        public int GetVenueIdByVenueName(string venueName)
        {
            return Context.Venues.GetVenueIdByVenueName(venueName);
        }

        //public List<SeatSection> GetSeatMapForVenue(int venueId)
        //{
        //    return Context.Venues.GetSeatMapForVenue(venueId);
        //}

        public VenueModel AddNewVenue(string venueName, int cityId)
        {
            return Context.Venues.AddNewVenue(venueName, cityId);
        }

        #endregion
    }
}