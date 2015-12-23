using System;
namespace Promotions.Repositories
{
    public interface IPromotionsRepository
    {
        System.Collections.Generic.IEnumerable<Promotion> GetPromotions(Int64 customerId);
        Promotion GetPromotion(Int64 customerId, Int64 productId);
    }
}
