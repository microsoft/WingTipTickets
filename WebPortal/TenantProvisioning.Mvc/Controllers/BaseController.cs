using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Models;
using TenantProvisioning.Core.Services;

namespace TenantProvisioning.Mvc.Controllers
{
    public class BaseController : Controller
    {
        #region - Ajax Helpers -

        [HttpGet]
        public JsonResult FetchDataCenters(int day, string subscriptionId)
        {
            return new JsonResult() { Data = FetchAvailableDataCenters(day, subscriptionId), JsonRequestBehavior = JsonRequestBehavior.AllowGet };
        }

        #endregion

        #region - Protected Methods -

        protected static List<LookupModel> FetchProvisioningOptions()
        {
            var lookupService = new LookupService();

            var list = lookupService.FetchProvisioningOptions();

            return list;
        }

        protected List<AzureLocation> FetchAvailableDataCenters(int day, string subscriptionId)
        {
            // Create defaults
            var dataCenters = new List<AzureLocation>()
            {
                new AzureLocation()
                {
                    Code = null,
                    Name = day == 1 ? "Day1 Location" : "Day2 Location"
                }
            };

            if (!string.IsNullOrEmpty(subscriptionId) && User.Identity.IsAuthenticated)
            {
                var util = new ManagementUtilities();
                dataCenters.AddRange(util.GetLocations(day, subscriptionId));
            }

            return dataCenters;
        }

        protected static List<LookupModel> FetchThemes()
        {
            var lookupService = new LookupService();

            var list = lookupService.FetchThemes();

            return list;
        }

        protected List<AzureSubscription> FetchSubscriptions()
        {
            var util = new ManagementUtilities();

            var subscriptions = User.Identity.IsAuthenticated
                ? util.GetSubscriptions(Settings.AccountOrganizationId)
                : new List<AzureSubscription>();

            if (!subscriptions.Any(d => d.DisplayName.Equals("Subscription")))
            {
                subscriptions.Insert(0, new AzureSubscription()
                {
                    Id = null,
                    DisplayName = "Subscription"
                });
            }

            return subscriptions;
        }

        #endregion
    }
}