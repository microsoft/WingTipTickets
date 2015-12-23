using System;
namespace Promotions.Repositories
{
    public interface IProductsRepository
    {
        System.Collections.Generic.IEnumerable<Product> GetProducts();

        System.Collections.Generic.IEnumerable<Product> GetRelatedProducts(Int64 productId);

        System.Collections.Generic.IEnumerable<Product> GetRecommendedProducts(Int64 customerId);

        int GetSongPlayCount(Int64 productId, Int64 customerId);

        Product GetProduct(Int64 id);
    }
}
