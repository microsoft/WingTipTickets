using System.Collections.Generic;

namespace Tenant.Mvc.Core.Models
{
    public class CatalogModel
    {
        public IEnumerable<CatalogItem> CatalogItems;
        public IEnumerable<CatalogItem> RecommendedItems;

        public CatalogModel(IEnumerable<CatalogItem> catalogItems, IEnumerable<CatalogItem> recommendedItems)
        {
            CatalogItems = catalogItems;
            RecommendedItems = recommendedItems;
        }



    }

}
