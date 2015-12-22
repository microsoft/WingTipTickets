using System.Collections.Generic;

namespace TenantProvisioning.Mvc.Models
{
    public class MyAccountViewModel
    {
        public List<UserAccountViewModel> UserAccounts { get; set; }

        public MyAccountViewModel()
        {
            UserAccounts = new List<UserAccountViewModel>();
        }
    }

    public class UserAccountViewModel
    {
        public string Username { get; set; }

        public List<TenantViewModel> Tenants { get; set; }

        public UserAccountViewModel()
        {
            Tenants = new List<TenantViewModel>();
        }
    }

    public class TenantViewModel
    {
        public int Id { get; set; }
        public string Email { get; set; }
        public string Theme { get; set; }
        public string Plan { get; set; }
        public string Status { get; set; }
        public bool AzureServicesProvisioned { get; set; }

        public List<ServiceStatusViewModel> Services { get; set; }
    }
}