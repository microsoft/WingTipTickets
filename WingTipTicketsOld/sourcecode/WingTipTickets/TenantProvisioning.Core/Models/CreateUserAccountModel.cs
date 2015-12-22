using System;
namespace TenantProvisioning.Core.Models
{
    public class CreateUserAccountModel
    {
        public string Firstname { get; set; }
        public string Lastname { get; set; }
        public string Username { get; set; }
        public byte[] CachedData { get; set; }
        public DateTime UpdateDate { get; set; }
    }
}