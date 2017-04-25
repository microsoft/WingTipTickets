using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class AllSeatsRepository:BaseRepository, IAllSeatsRepository
    {
        public AllSeatsModel GetSeatDetails(string seatDescription, int tminusDaysToConcert)
        {
            return Context.AllSeats.GetSeatDetails(seatDescription, tminusDaysToConcert);
        }

        public int UpdateSeatDetails(int discount, string seatDescription, int tMinusDaysToConcert, int count)
        {
            return Context.AllSeats.UpdateSeatDetails(discount, seatDescription, tMinusDaysToConcert, count);
        }
    }
}