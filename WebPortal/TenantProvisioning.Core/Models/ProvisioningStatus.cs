namespace TenantProvisioning.Core.Models
{
    public class ProvisioningStatus
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Service { get; set; }
        public string Status { get; set; }
        public string Message { get; set; }
    }
}