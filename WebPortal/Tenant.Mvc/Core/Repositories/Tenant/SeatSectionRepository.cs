using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class SeatSectionRepository: BaseRepository, ISeatSectionRepository
    {
        #region - Implementation -
        public SeatSectionModel GetSeatSection(int venueId, string description)
        {
            return Context.SeatSection.GetSeatSection(venueId, description);
        }

        public SeatSectionModel GetSeatSectionDetails(int seatSectionId)
        {
            return Context.SeatSection.GetSeatSectionDetails(seatSectionId);
        }
        #endregion
    }
}
