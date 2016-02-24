using System;
using System.Configuration;
using System.Net;
using System.Web.Mvc;
using System.Web.Routing;

namespace Tenant.Mvc.Controllers
{
    public class BaseController : Controller
    {
        #region - Controllers -

        public BaseController()
        {
            // Set up ViewBag data displayed on screen
            ViewBag.PrimaryDbServerName = ConfigurationManager.AppSettings["PrimaryDatabaseServer"];
        }

        #endregion

        #region - Overidden Methods -

        protected override void Initialize(RequestContext requestContext)
        {
            base.Initialize(requestContext);
            ExtractHostingSite();
        }

        #endregion

        #region - Protected Methods -

        protected void DisplayMessage(string content)
        {
            if (!string.IsNullOrWhiteSpace(content))
            {
                TempData["msg"] = string.Format("<script>alert(\"{0}\");</script>", content);
            }
        }

        #endregion

        #region - Private Methods -

        private void ExtractHostingSite()
        {
            var requestUrl = Request.Url;

            if (requestUrl == null)
            {
                throw new Exception("No request Url to resolve the Host");
            }

            if (!requestUrl.Host.Contains("trafficmanager.net"))
            {
                ViewBag.SiteHostName = requestUrl.Host;
            }
            else
            {
                try
                {
                    var resolvedHostName = Dns.GetHostEntry(requestUrl.Host);

                    if (resolvedHostName.HostName.Contains("waws"))
                    {
                        ViewBag.SiteHostName = Environment.ExpandEnvironmentVariables("%WEBSITE_SITE_NAME%") + ".azurewebsites.net";
                    }
                    else
                    {
                        ViewBag.SiteHostName = resolvedHostName.HostName;
                    }
                }
                catch
                {
                    throw new Exception(String.Format("Unable to resolve host for {0}", requestUrl.Host));
                }
            }
        }

        #endregion
    }
}