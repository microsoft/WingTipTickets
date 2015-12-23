using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Promotions.Repositories
{
    public class Promotion
    {
        public Int64 CustomerId;
        public Int64 ProductId;
        public string PromotionDiscount;
        public int NewPrice;
    }
}
