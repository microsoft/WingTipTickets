using System.Collections.Generic;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface IArtistRepository : IBaseRepository
    {
        List<PerformerModel> GetArtists();
        PerformerModel GetArtistByName(string artistName);
        PerformerModel GetArtistById(int artistId);
        PerformerModel AddNewArtist(string artistName);
    }
}