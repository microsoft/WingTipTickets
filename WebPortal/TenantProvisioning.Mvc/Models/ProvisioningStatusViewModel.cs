using System.Collections.Generic;
using TenantProvisioning.Mvc.Controllers;

namespace TenantProvisioning.Mvc.Models
{
    public class ProvisioningStatusViewModel
    {
        public List<TenantStatusViewModel> Tenants { get; set; }

        public ProvisioningStatusViewModel()
        {
            Tenants = new List<TenantStatusViewModel>();
        }
    }

    public class TenantStatusViewModel
    {
        public int TenantId { get; set; }

        public bool ProvisioningCompleted { get; set; }

        public bool ErrorsOccurred { get; set; }

        public List<ServiceStatusViewModel> Services { get; set; }

        public TenantStatusViewModel()
        {
            Services = new List<ServiceStatusViewModel>();
        }
    }
}