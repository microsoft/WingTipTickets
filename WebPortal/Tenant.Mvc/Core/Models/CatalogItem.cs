using System;
using System.Globalization;

namespace Tenant.Mvc.Core.Models
{
    public class CatalogItem
    {
        #region - Properties -

        public Int64 Id;

        public string Name;

        public string Description;

        public string Title1;

        public string Title2;

        public int TitlesCount;

        public string Category;

        public int OriginalPrice;

        public int CurrentPrice;

        public string PromotionDiscount;

        public int PlayCount;

        public string Price
        {
            get
            {
                if (string.IsNullOrWhiteSpace(PromotionDiscount))
                {
                    return OriginalPrice.ToString();
                }

                return string.Format(CultureInfo.InvariantCulture, "{0} instead of ${1} ({2} off)", CurrentPrice, OriginalPrice, PromotionDiscount);
            }
        }

        #endregion
    }
}