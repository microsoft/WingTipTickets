using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Tenant.Mvc.Core.Contexts;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface ISeatSectionRepository : IBaseRepository
    {
        SeatSectionModel GetSeatSection(int venueId, string description);

        SeatSectionModel GetSeatSectionDetails(int seatSectionId);
    }
}
