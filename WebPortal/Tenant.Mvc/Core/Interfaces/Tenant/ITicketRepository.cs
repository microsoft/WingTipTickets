using System.Collections.Generic;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface ITicketRepository : IBaseRepository
    {
        List<ConcertTicketLevel> GetTicketLevelById(int concertId);
        List<ConcertTicket> WriteNewTicketToDb(PurchaseTicketsModel model);
    }
}