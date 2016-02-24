using System.Collections.Generic;

namespace Tenant.Mvc.Core.Models
{
    public class CatalogItemDetailsModel
    {
        public CatalogItem Item;
        public IEnumerable<CatalogItem> RelatedItems;

        public CatalogItemDetailsModel(CatalogItem item, IEnumerable<CatalogItem> relatedItems)
        {
            Item = item;
            RelatedItems = relatedItems;
        }
    }
}