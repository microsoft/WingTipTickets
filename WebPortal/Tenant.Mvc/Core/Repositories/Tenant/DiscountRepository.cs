using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class DiscountRepository: BaseRepository, IDiscountRepository
    {
        #region - Implementation -
        public DiscountedSeatModel ApplyDiscount(DiscountModel discountModel)
        {
            return Context.Discount.ApplyDiscount(discountModel);
        }

        public List<DiscountedSeatModel> GetDiscountedSeat(int seatSectionId, int seatNumber)
        {
            return Context.Discount.GetDiscountedSeat(seatSectionId, seatNumber);
        }
        #endregion
    }
}