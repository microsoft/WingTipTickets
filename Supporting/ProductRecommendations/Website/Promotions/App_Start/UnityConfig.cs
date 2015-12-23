using System.Web.Mvc;
using Microsoft.Practices.Unity;
using Unity.Mvc5;
using System.Data.SqlClient;
using System;
using Promotions.Repositories;
using Microsoft.AspNet.Identity;
using Microsoft.ServiceBus.Messaging;
using Promotions.Models;

namespace Promotions
{
    public static class UnityConfig
    {
        public static void RegisterComponents()
        {
			var container = new UnityContainer();
            
            // register all your components with the container here
            // it is NOT necessary to register your controllers
            
            // e.g. container.RegisterType<ITestService, TestService>();

            var settings = System.Web.Configuration.WebConfigurationManager.AppSettings;

            container.RegisterInstance<Func<SqlConnection>>(() =>
                {
                    SqlConnectionStringBuilder builder = new SqlConnectionStringBuilder();

                    builder.DataSource = settings["SqlServer"];
                    builder.InitialCatalog = settings["SqlDB"];
                    builder.UserID = settings["SqlUserID"];
                    builder.Password = settings["SqlPassword"];

                    return new SqlConnection(builder.ToString());
                });

            container.RegisterType<ICustomerRepository, CustomerRepository>();

            container.RegisterType<IProductsRepository, ProductsRepository>();

            container.RegisterType<IPromotionsRepository, PromotionsRepository>();

            container.RegisterType<ITelemetryRepository, TelemetryRepository>();

            container.RegisterType<IUserStore<Customer>, CustomerRepository>();

            var serviceBusConnectionString = settings["Microsoft.ServiceBus.ConnectionString"];
            var clickEventHubName = settings["clickEvents"];
            var purchaseEventHubName = settings["purchaseEvents"];

            container.RegisterInstance<EventHubs>(
                new EventHubs(
                    EventHubClient.CreateFromConnectionString(serviceBusConnectionString, clickEventHubName),
                    EventHubClient.CreateFromConnectionString(serviceBusConnectionString, purchaseEventHubName)
            ));

            DependencyResolver.SetResolver(new UnityDependencyResolver(container));

        }
    }
}