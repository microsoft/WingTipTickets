using Microsoft.ServiceBus.Messaging;

namespace Tenant.Mvc.Core.Models
{
    public class EventHubs
    {
        #region - Properties -

        public EventHubClient ClickClient;
        public EventHubClient PurchaseClient;

        #endregion

        #region - Constructors -

        public EventHubs(EventHubClient clickClient, EventHubClient purchaseClient)
        {
            ClickClient = clickClient;
            PurchaseClient = purchaseClient;
        }

        #endregion

    }
}
