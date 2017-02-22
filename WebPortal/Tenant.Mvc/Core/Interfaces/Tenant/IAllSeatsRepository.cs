using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
  public  interface IAllSeatsRepository : IBaseRepository
  {
      AllSeatsModel GetSeatDetails(string seatDescription, int tminusDaysToConcert);
      int UpdateSeatDetails(int discount, string seatDescription, int tMinusDaysToConcert, int count);
  }
}
