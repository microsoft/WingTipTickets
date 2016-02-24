using System.Collections.Generic;
using Tenant.Mvc.Core.Contexts;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models.DomainModels;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface ITicketRepository : IBaseRepository
    {
        List<ConcertTicketLevel> GetTicketLevelById(int concertId);
        List<ConcertTicket> WriteNewTicketToDb(PurchaseTicketsModel model);
    }
}