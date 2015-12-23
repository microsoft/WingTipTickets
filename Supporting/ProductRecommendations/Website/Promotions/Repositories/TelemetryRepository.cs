using Microsoft.ServiceBus.Messaging;
using Newtonsoft.Json;
using Promotions.Events;
using Promotions.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace Promotions.Repositories
{
    public class TelemetryRepository : Promotions.Repositories.ITelemetryRepository
    {
        private EventHubs _eventHubs;

        public TelemetryRepository(EventHubs eventHubs)
        {
            _eventHubs = eventHubs;
        }

        public void SendClick(ClickEvent click)
        {
            var serializedString = JsonConvert.SerializeObject(click);
            EventData data = new EventData(Encoding.UTF8.GetBytes(serializedString))
            {
                PartitionKey = click.productId.ToString()
            };

            // Set user properties if needed
            data.Properties.Add("Type", "Telemetry_" + DateTime.UtcNow.ToLongTimeString());

            _eventHubs._clickClient.Send(data);

            //TODO: Add output to log here.
        }

        public void SendPurchase(PurchaseEvent purchase)
        {
            var serializedString = JsonConvert.SerializeObject(purchase);
            EventData data = new EventData(Encoding.UTF8.GetBytes(serializedString))
            {
                PartitionKey = purchase.productId.ToString()
            };

            // Set user properties if needed
            data.Properties.Add("Type", "Telemetry_" + DateTime.UtcNow.ToLongTimeString());

            _eventHubs._purchaseClient.Send(data);

            //TODO: Add output to log here.
        }
    }
}