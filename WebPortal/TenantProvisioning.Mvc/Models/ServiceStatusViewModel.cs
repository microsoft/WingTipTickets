namespace TenantProvisioning.Mvc.Models
{
    public class ServiceStatusViewModel
    {
        public int StatusId { get; set; }
        public string Service { get; set; }
        public string Name { get; set; }
        public string Status { get; set; }
        public string Message { get; set; }
    }
}