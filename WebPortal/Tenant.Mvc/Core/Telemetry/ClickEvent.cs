using System;

namespace Tenant.Mvc.Core.Telemetry
{
    public class ClickEvent
    {
        #region - Properties -

        public Int64 CustomerId { get; set; }

        public Int64 ProductId { get; set; }

        public DateTime ClickTime { get; set; }

        #endregion
    }
}