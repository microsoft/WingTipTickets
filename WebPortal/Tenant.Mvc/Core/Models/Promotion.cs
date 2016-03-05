using System;

namespace Tenant.Mvc.Core.Models
{
    public class Promotion
    {
        #region - Properties -

        public Int64 CustomerId;
        public Int64 ProductId;
        public string PromotionDiscount;
        public int NewPrice;

        #endregion
    }
}
