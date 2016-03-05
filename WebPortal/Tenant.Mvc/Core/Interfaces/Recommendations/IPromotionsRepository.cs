using System;
using System.Collections.Generic;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Interfaces.Recommendations
{
    public interface IPromotionsRepository
    {
        IEnumerable<Promotion> GetPromotions(Int64 customerId);
        Promotion GetPromotion(Int64 customerId, Int64 productId);
    }
}
