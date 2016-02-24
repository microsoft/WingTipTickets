using System.Collections.Generic;
using Microsoft.Owin;
using Owin;
using Tenant.Mvc;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models.DomainModels;

[assembly: OwinStartup(typeof(Startup))]
namespace Tenant.Mvc
{
    public partial class Startup
    {
        public static List<CustomerModel> SessionUsers = null;

        public void Configuration(IAppBuilder app)
        {
            SessionUsers = new List<CustomerModel>();
        }
    }
}
