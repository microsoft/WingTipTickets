using System.Collections.Generic;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models.DomainModels;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface IVenueRepository : IBaseRepository
    {
        List<VenueModel> GetVenues(int cityId = 0);
        VenueModel GetVenueByVenueId(int venueId);
        List<SeatSection> GetSeatMapForVenue(int venueId);
        VenueModel AddNewVenue(string venueName, int cityId);
    }
}
