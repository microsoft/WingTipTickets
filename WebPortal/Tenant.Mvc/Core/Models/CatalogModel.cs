using System.Collections.Generic;

namespace Tenant.Mvc.Core.Models
{
    public class CatalogModel
    {
        #region - Properties -

        public IEnumerable<CatalogItem> CatalogItems;
        public IEnumerable<CatalogItem> RecommendedItems;

        #endregion

        #region - Constructors -

        public CatalogModel(IEnumerable<CatalogItem> catalogItems, IEnumerable<CatalogItem> recommendedItems)
        {
            CatalogItems = catalogItems;
            RecommendedItems = recommendedItems;
        }

        #endregion

    }
}
