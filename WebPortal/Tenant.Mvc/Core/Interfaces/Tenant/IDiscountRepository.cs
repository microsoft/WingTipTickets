using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface IDiscountRepository : IBaseRepository
    {
        DiscountedSeatModel ApplyDiscount(DiscountModel discountModel);
        List<DiscountedSeatModel> GetDiscountedSeat(int seatSectionId, int seatNumber);
    }
}
