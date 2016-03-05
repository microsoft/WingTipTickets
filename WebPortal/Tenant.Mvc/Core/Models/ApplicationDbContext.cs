using Microsoft.AspNet.Identity.EntityFramework;

namespace Tenant.Mvc.Core.Models
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
    {
        public ApplicationDbContext()
            : base("DefaultConnection")
        {
        }
    }
}