namespace TenantProvisioning.Core.Models
{
    public class TenantModel
    {
        public int TenantId { get; set; }
        public int UserAccountId { get; set; }
        public int? ThemeId { get; set; }
        public int? ProvisioningOptionId { get; set; }
        public string DataCenter { get; set; }
        public string SiteName { get; set; }
        public bool AzureServicesProvisioned { get; set; }

        public string Theme { get; set; }
        public string ThemeCode { get; set; }
        public string ProvisioningOption { get; set; }
        public string ProvisioningOptionCode { get; set; }

        public string OrganizationId { get; set; }
        public string SubscriptionId { get; set; }
        public string Username { get; set; }
    }
}