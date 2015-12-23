using Promotions.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Promotions.Models
{
    public class CatalogModel
    {
        public IEnumerable<CatalogItem> _catalogItems;
        public IEnumerable<CatalogItem> _recommendedItems;

        public CatalogModel(IEnumerable<CatalogItem> catalogItems, IEnumerable<CatalogItem> recommendedItems)
        {
            _catalogItems = catalogItems;
            _recommendedItems = recommendedItems;
        }



    }

}
