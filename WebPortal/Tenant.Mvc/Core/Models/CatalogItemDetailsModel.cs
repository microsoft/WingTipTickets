using System.Collections.Generic;

namespace Tenant.Mvc.Core.Models
{
    public class CatalogItemDetailsModel
    {
        #region - Properties -

        public CatalogItem Item;
        public IEnumerable<CatalogItem> RelatedItems;

        #endregion

        #region - Constructors -

        public CatalogItemDetailsModel(CatalogItem item, IEnumerable<CatalogItem> relatedItems)
        {
            Item = item;
            RelatedItems = relatedItems;
        }

        #endregion

    }
}