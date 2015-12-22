using System.Linq;
using System.Security.Claims;
using System.Web.Mvc;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Models;
using TenantProvisioning.Core.Services;
using TenantProvisioning.Mvc.Models;

namespace TenantProvisioning.Mvc.Controllers
{
    [Authorize]
    public class SignUpController : BaseController
    {
        #region - Index View -

        [HttpGet]
        public ActionResult Index()
        {
            // Build the Lookups
            var themes = FetchThemes();
            var provisioningOptions = FetchProvisioningOptions();
            var day1DataCenters = FetchAvailableDataCenters(1, null);
            var day2DataCenters = FetchAvailableDataCenters(2, null);
            var subscriptions = FetchSubscriptions();

            // Setup the ViewBag
            ViewBag.Themes = new SelectList(themes, "Id", "Description", null);
            ViewBag.Day1DataCenters = new SelectList(day1DataCenters, "Code", "Name", null);
            ViewBag.Day2DataCenters = new SelectList(day2DataCenters, "Code", "Name", null);
            ViewBag.Subscriptions = new SelectList(subscriptions, "Id", "DisplayName", null);

            // Setup the Initial Model
            var viewModel = new SignUpViewModel()
            {
                ProvisioningOptionTitle = provisioningOptions.First(o => o.Code.Equals("S1")).Description,
                ThemeId = (int)themes.First(t => t.Code != null && t.Code.Equals("P")).Id
            };

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult Index(SignUpViewModel day1ViewModel)
        {
            var tenantService = new TenantService();

            // Build the Lookups
            var themes = FetchThemes();
            var provisioningOptions = FetchProvisioningOptions();
            var day1DataCenters = FetchAvailableDataCenters(1, day1ViewModel.SubscriptionId);
            var day2DataCenters = FetchAvailableDataCenters(2, day1ViewModel.SubscriptionId);
            var subscriptions = FetchSubscriptions();

            // Setup the ViewBag
            ViewBag.Themes = new SelectList(themes, "Id", "Description", null);
            ViewBag.Day1DataCenters = new SelectList(day1DataCenters, "Code", "Name", null);
            ViewBag.Day2DataCenters = new SelectList(day2DataCenters, "Code", "Name", null);
            ViewBag.Subscriptions = new SelectList(subscriptions, "Id", "DisplayName", null);

            // Check model validity
            if (!ModelState.IsValid)
            {
                return View(day1ViewModel);
            }

            // Check name and email
            var errors = tenantService.Validate(day1ViewModel.SiteName, day1ViewModel.SubscriptionId);
            if (errors.Any())
            {
                ViewBag.Errors = errors;
                return View(day1ViewModel);
            }

            // Update the DB with modification or new entry
            var organizationId = Settings.AccountOrganizationId;

            // Valid - Process the SignUp (Day1)
            var tenantId = tenantService.CreateDay1(new CreateTenantModel()
            {
                Tenant = new CreateTenantModel.TenantModel()
                {
                    ThemeId = day1ViewModel.ThemeId,
                    ProvisioningOptionId = provisioningOptions.First(o => o.Code.Equals("S1")).Id ?? -1,
                    DataCenter = !string.IsNullOrEmpty(day1ViewModel.Day1DataCenter) ? day1ViewModel.Day1DataCenter : null,
                    SiteName = day1ViewModel.SiteName.ToLower(),
                    OrganizationId = organizationId,
                    SubscriptionId = day1ViewModel.SubscriptionId
                },
                UserAccount = new CreateTenantModel.UserAccountModel()
                {
                    Username = ClaimsPrincipal.Current.Identity.SplitName(),
                    Firstname = day1ViewModel.FirstName,
                    Lastname = day1ViewModel.LastName,
                },
                CreditCard = new CreateTenantModel.CreditCardModel()
                {
                    CreditCardNumber = day1ViewModel.CreditCardNumber,
                    ExpiryDate = day1ViewModel.ExpiryDate,
                    CardVerificationValue = day1ViewModel.CardVerificationValue
                }
            });

            // Valid - Process the SignUp (Day2)
            tenantService.CreateDay2(new CreateTenantModel()
            {
                Tenant = new CreateTenantModel.TenantModel()
                {
                    ThemeId = day1ViewModel.ThemeId,
                    ProvisioningOptionId = provisioningOptions.First(o => o.Code.Equals("S2")).Id ?? -1,
                    DataCenter = !string.IsNullOrEmpty(day1ViewModel.Day2DataCenter) ? day1ViewModel.Day2DataCenter : null,
                    SiteName = day1ViewModel.SiteName.ToLower() + "pr",
                    OrganizationId = organizationId,
                    SubscriptionId = day1ViewModel.SubscriptionId
                }
            });

            return RedirectToAction("Index", "TenantView", new
            {
                tenantId
            });
        }

        #endregion

        #region - Ajax Helpers -

        [HttpGet]
        public JsonResult GetSiteName(int themeId)
        {
            var lookupService = new LookupService();

            var item = lookupService.FetchThemes().FirstOrDefault(t => t.Id == themeId);

            if (item != null)
            {
                return Json(new { SiteName = item.SiteName }, JsonRequestBehavior.AllowGet);
            }

            return Json(new { SiteName = string.Empty }, JsonRequestBehavior.AllowGet);
        }

        #endregion
    }
}
