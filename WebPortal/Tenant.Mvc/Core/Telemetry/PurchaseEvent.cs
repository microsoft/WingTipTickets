using System;

namespace Tenant.Mvc.Core.Telemetry
{
    public class PurchaseEvent
    {
        #region - Properties -

        public Int64 CustomerId { get; set; }

        public Int64 ProductId { get; set; }

        public Guid OrderId { get; set; }

        public int Price { get; set; }

        public DateTime PurchaseTime { get; set; }

        #endregion
    }
}