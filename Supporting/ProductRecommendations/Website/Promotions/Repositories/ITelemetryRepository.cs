using System;
namespace Promotions.Repositories
{
    public interface ITelemetryRepository
    {
        void SendClick(Promotions.Events.ClickEvent click);
        void SendPurchase(Promotions.Events.PurchaseEvent purchase);
    }
}
