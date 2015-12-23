using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Promotions.Events
{
    public class ClickEvent
    {
        public Int64 customerId { get; set; }

        public Int64 productId { get; set; }

        public DateTime clickTime { get; set; }
    }

}