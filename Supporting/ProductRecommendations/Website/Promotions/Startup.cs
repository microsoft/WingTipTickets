using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(Promotions.Startup))]
namespace Promotions
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
