using System.Linq;
using System.Security.Principal;

namespace TenantProvisioning.Core.Helpers
{
    public static class IdentityExtensions
    {
        public static string SplitName(this IIdentity identity)
        {
            return identity.Name.Split('#').Last();
        }
    }
}