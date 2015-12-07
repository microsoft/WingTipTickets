using System.Linq;
using System.Security.Claims;
using System.Web.Mvc;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Services;

namespace TenantProvisioning.Mvc.Controllers
{
    public class OptionController : Controller
    {
        #region - Index View -

        [HttpGet]
        public ActionResult Index(bool isDataCamp)
        {
            // Set Visibility
            ViewBag.Day1Visible = true;
            ViewBag.Day2Visible = isDataCamp;
            ViewBag.ShowMessage = false;

            // Set Defaults - Not logged in
            ViewBag.Day1Provisioned = false;
            ViewBag.Day2Provisioned = true;

            if (ClaimsPrincipal.Current.Identity.IsAuthenticated)
            {
                // Get the Tenants linked to the user
                var tenantService = new TenantService();
                var tenants = tenantService.FetchByUsername(ClaimsPrincipal.Current.Identity.SplitName());

                ViewBag.Day1Provisioned = 
                    tenants != null && 
                    tenants.Any(t => t.ProvisioningOptionCode.Equals("S1"));

                ViewBag.Day2Provisioned = 
                    tenants == null || 
                    tenants.Any(t => t.ProvisioningOptionCode.Equals("S1") && !t.AzureServicesProvisioned) || 
                    tenants.Any(t => t.ProvisioningOptionCode.Equals("S2"));

                ViewBag.ShowMessage =
                    tenants != null &&
                    tenants.Any(t => !t.AzureServicesProvisioned);

                return PartialView();
            }

            return PartialView();
        }

        #endregion
    }
}
