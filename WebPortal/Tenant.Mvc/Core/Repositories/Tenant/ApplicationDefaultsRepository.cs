using System;
using System.Linq;
using Tenant.Mvc.Core.Contexts;
using Tenant.Mvc.Core.Interfaces.Tenant;
using WingTipTickets;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class ApplicationDefaultsRepository : IApplicationDefaultsRepository
    {
        #region - Fields -

        public Action<string> StatusCallback { get; set; }

        #endregion

        #region - Implementation -

        public string GetApplicationDefault(string code)
        {
            using (var context = new WingTipTicketsEntities(WingtipTicketApp.GetTenantConnectionString(WingtipTicketApp.Config.TenantDatabase1)))
            {
                return context.ApplicationDefaults.First(a => a.Code.Equals(code)).Value;
            }
        }

        public void SetApplicationDefault(string code, string value)
        {
            using (var context = new WingTipTicketsEntities(WingtipTicketApp.GetTenantConnectionString(WingtipTicketApp.Config.TenantDatabase1)))
            {
                var setting = context.ApplicationDefaults.First(a => a.Code.Equals(code));
                setting.Value = value;

                context.SaveChanges();
            }
        }

        #endregion

        #region - Protected Methods -

        protected void UpdateStatus(string message)
        {
            if (StatusCallback != null)
            {
                StatusCallback(message);
            }
        }

        #endregion
    }
}