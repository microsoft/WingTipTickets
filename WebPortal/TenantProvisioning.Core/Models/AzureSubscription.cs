using System;

namespace TenantProvisioning.Core.Models
{
    public class AzureSubscription
    {
        public string Id { get; set; }
        public string DisplayName { get; set; }
        public string OrganizationId { get; set; }
        public bool IsConnected { get; set; }
        public DateTime ConnectedOn { get; set; }
        public string ConnectedBy { get; set; }
        public bool AzureAccessNeedsToBeRepaired { get; set; }
    }
}