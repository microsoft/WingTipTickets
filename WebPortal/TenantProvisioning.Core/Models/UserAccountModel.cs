using System;

namespace TenantProvisioning.Core.Models
{
    public class UserAccountModel
    {
        public int UserAccountId { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
        public byte[] CachedData { get; set; }
        public DateTime UpdateDate { get; set; }
    }
}