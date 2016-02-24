using System;

namespace Tenant.Mvc.Core.Telemetry
{
    public class ClickEvent
    {
        public Int64 CustomerId { get; set; }

        public Int64 ProductId { get; set; }

        public DateTime ClickTime { get; set; }
    }

}