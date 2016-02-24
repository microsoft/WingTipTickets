using Microsoft.Owin;
using Owin;
using TenantProvisioning.Mvc;

[assembly: OwinStartup(typeof(Startup))]

namespace TenantProvisioning.Mvc
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}