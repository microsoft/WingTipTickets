using System.Web.Http;

namespace Tenant.Mvc
{
    public static class WebApiConfig
    {
        #region - Public Methods -

        public static void Register(HttpConfiguration config)
        {
            // Web API configuration and services

            // Web API routes
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute(
                                       name: "DefaultApi",
                                       routeTemplate: "api/{controller}/{id}",
                                       defaults: new { id = RouteParameter.Optional }
                );
        }

        #endregion
    }
}
