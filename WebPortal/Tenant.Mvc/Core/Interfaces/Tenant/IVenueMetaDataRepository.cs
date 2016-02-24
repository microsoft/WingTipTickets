using System.Threading.Tasks;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models.DomainModels;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface IVenueMetaDataRepository : IBaseRepository
    {
        Task<VenueMetaData> GetVenueMetaData(int venueId);
        Task SetVenueMetaData(int venueId, dynamic metaData);
    }
}