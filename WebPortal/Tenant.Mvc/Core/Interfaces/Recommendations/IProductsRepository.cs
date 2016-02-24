using System;
using System.Collections.Generic;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models.DomainModels;

namespace Tenant.Mvc.Core.Interfaces.Recommendations
{
    public interface IProductsRepository
    {
        IEnumerable<Product> GetProducts();

        IEnumerable<Product> GetRelatedProducts(Int64 productId);

        IEnumerable<Product> GetRecommendedProducts(Int64 customerId);

        int GetSongPlayCount(Int64 productId, Int64 customerId);

        Product GetProduct(Int64 id);
    }
}
