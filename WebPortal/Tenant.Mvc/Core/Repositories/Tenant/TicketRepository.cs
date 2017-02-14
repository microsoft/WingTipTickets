using System.Collections.Generic;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class TicketRepository : BaseRepository, ITicketRepository
    {
        #region - Implementation -

        public List<ConcertTicketLevel> GetTicketLevelById(int concertId)
        {
            return Context.Tickets.GetTicketLevelById(concertId);
        }

        public List<ConcertTicket> WriteNewTicketToDb(List<PurchaseTicketsModel> model)
        {
            return Context.Tickets.WriteNewTicketToDb(model);
        }

        #endregion
    }
}