using System.Collections.Generic;
using Microsoft.Owin;
using Owin;
using Tenant.Mvc;
using Tenant.Mvc.Models.CustomersDB;

[assembly: OwinStartup(typeof(Startup))]
namespace Tenant.Mvc
{
    public partial class Startup
    {
        public static List<Customer> SessionUsers = null;

        public void Configuration(IAppBuilder app)
        {
            SessionUsers = new List<Customer>();
        }
    }
}
