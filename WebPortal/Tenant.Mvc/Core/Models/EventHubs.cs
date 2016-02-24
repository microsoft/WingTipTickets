using Microsoft.ServiceBus.Messaging;

namespace Tenant.Mvc.Core.Models
{
    public class EventHubs
    {
        public EventHubClient ClickClient;
        public EventHubClient PurchaseClient;

        public EventHubs(EventHubClient clickClient, EventHubClient purchaseClient)
        {
            ClickClient = clickClient;
            PurchaseClient = purchaseClient;
        }

    }
}
