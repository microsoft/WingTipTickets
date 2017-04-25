using System.Collections.Generic;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface IVenueRepository : IBaseRepository
    {
        List<VenueModel> GetVenues(int venueId = 0, int cityId = 0);
        VenueModel GetVenueByVenueId(int venueId);
        //List<SeatSection> GetSeatMapForVenue(int venueId);
        VenueModel AddNewVenue(string venueName, int cityId);
        int GetVenueIdByVenueName(string venueName);
    }
}
