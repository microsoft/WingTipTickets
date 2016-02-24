using Microsoft.AspNet.Identity;

namespace Tenant.Mvc.Core.Models
{
    public class CustomerRec : IUser
    {
        public long CustomerId { get; set; }

        public string Id { get; private set; }

        public string UserName { get; set; }

        public string Region { get; set; }
    }
}