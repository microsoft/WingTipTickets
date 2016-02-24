using System;
using System.Collections.Generic;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class ArtistRepository : BaseRepository, IArtistRepository
    {
        #region - Implementation -

        public List<PerformerModel> GetArtists()
        {
            return Context.Concerts.GetArtists();
        }

        public PerformerModel GetArtistByName(String artistName)
        {
            return Context.Concerts.GetArtistByName(artistName);
        }

        public PerformerModel GetArtistById(int artistId)
        {
            return Context.Concerts.GetArtistById(artistId);
        }

        public PerformerModel AddNewArtist(string artistName)
        {
            return Context.Concerts.AddNewArtist(artistName);
        }

        #endregion
    }
}