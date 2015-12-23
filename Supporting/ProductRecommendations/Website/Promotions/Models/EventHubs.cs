using Microsoft.ServiceBus.Messaging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Promotions.Models
{
    public class EventHubs
    {
        public EventHubClient _clickClient;
        public EventHubClient _purchaseClient;

        public EventHubs(EventHubClient clickClient, EventHubClient purchaseClient)
        {
            _clickClient = clickClient;
            _purchaseClient = purchaseClient;
        }

    }
}
