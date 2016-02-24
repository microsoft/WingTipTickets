using Tenant.Mvc.Core.Telemetry;

namespace Tenant.Mvc.Core.Interfaces.Recommendations
{
    public interface ITelemetryRepository
    {
        void SendClick(ClickEvent click);
        void SendPurchase(PurchaseEvent purchase);
    }
}
