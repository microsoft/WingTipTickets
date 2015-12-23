using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Promotions.Events
{
    public class PurchaseEvent
    {
        public Int64 customerId { get; set; }

        public Int64 productId { get; set; }

        public Guid orderId { get; set; }

        public int price { get; set; }

        public DateTime purchaseTime { get; set; }
    }
}