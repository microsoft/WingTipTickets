using System;
using System.Text;
using Microsoft.ServiceBus.Messaging;
using Newtonsoft.Json;
using Tenant.Mvc.Core.Interfaces.Recommendations;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Core.Telemetry;

namespace Tenant.Mvc.Core.Repositories.Recommendations
{
    public class TelemetryRepository : ITelemetryRepository
    {
        #region - Fields -

        private readonly EventHubs _eventHubs;

        #endregion

        #region - Constructors -

        public TelemetryRepository(EventHubs eventHubs)
        {
            _eventHubs = eventHubs;
        }

        #endregion

        #region - Public Methods -

        public void SendClick(ClickEvent click)
        {
            var serializedString = JsonConvert.SerializeObject(click);

            var data = new EventData(Encoding.UTF8.GetBytes(serializedString))
            {
                PartitionKey = click.ProductId.ToString()
            };

            // Set user properties if needed
            data.Properties.Add("Type", "Telemetry_" + DateTime.UtcNow.ToLongTimeString());

            _eventHubs.ClickClient.Send(data);
        }

        public void SendPurchase(PurchaseEvent purchase)
        {
            var serializedString = JsonConvert.SerializeObject(purchase);

            var data = new EventData(Encoding.UTF8.GetBytes(serializedString))
            {
                PartitionKey = purchase.ProductId.ToString()
            };

            // Set user properties if needed
            data.Properties.Add("Type", "Telemetry_" + DateTime.UtcNow.ToLongTimeString());

            _eventHubs.PurchaseClient.Send(data);
        }

        #endregion
    }
}