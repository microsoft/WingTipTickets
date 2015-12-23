using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Promotions.Models
{
    public class CatalogItemDetailsModel
    {
        public CatalogItem _item;
        public IEnumerable<CatalogItem> _relatedItems;

        public CatalogItemDetailsModel(CatalogItem item, IEnumerable<CatalogItem> relatedItems)
        {
            _item = item;
            _relatedItems = relatedItems;
        }
    }
}