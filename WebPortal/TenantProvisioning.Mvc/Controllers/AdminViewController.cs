using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Models;
using TenantProvisioning.Core.Services;
using TenantProvisioning.Mvc.Models;
using WebGrease.Css.Extensions;

using ProvisioningStatus = TenantProvisioning.Core.Helpers.ProvisioningStatus;

namespace TenantProvisioning.Mvc.Controllers
{
    [Authorize(Roles = RoleNames.Administrator)]
    public class AdminViewController : BaseController
    {
        #region - Index View -

        [HttpGet]
        public ActionResult Index()
        {
            // Fetch required data
            var accountService = new UserAccountService();
            var user = accountService.FetchByUsername(HttpContext.User.Identity.SplitName());

            var tenantService = new TenantService();
            var tenants = tenantService.FetchTenants();

            // Build the tenants viewmodel
            var viewModel = tenants != null
                ? new MyAccountViewModel()
                {
                    UserAccounts = tenants.GroupBy(u => u.Username).Select(u => new UserAccountViewModel()
                    {
                        Username = u.Key,
                        Tenants = u.Select(t => new TenantViewModel()
                        {
                            Id = t.TenantId,
                            Plan = t.ProvisioningOption,
                            Theme = t.Theme,
                            Status = t.AzureServicesProvisioned ? ProvisioningStatus.Deployed : ProvisioningStatus.NotDeployed,
                            AzureServicesProvisioned = t.AzureServicesProvisioned,
                        }).ToList()
                    }).ToList()
                }
                : new MyAccountViewModel();

            // Get working values
            var pipelineRunning = TempData["PipelineRunning"] != null && (bool)TempData["PipelineRunning"];
            var username = TempData["Username"] != null ? (string)TempData["Username"] : string.Empty;

            // Add each tenants services
            foreach (var userAccount in viewModel.UserAccounts)
            { 
                foreach (var company in userAccount.Tenants)
                {
                    var provisioningService = ProvisioningService.CreateForAdmin(company.Id);

                    company.Services = provisioningService.GetStatusses().Select(s => new ServiceStatusViewModel()
                    {
                        StatusId = s.Id,
                        Name = s.Name,
                        Service = s.Service,
                        Status = company.AzureServicesProvisioned ? ProvisioningStatus.Deployed : ProvisioningStatus.NotDeployed
                    }).ToList();
                }

                // Set already provisioned tenant services to active
                userAccount.Tenants.Where(c => c.AzureServicesProvisioned)
                           .ForEach(c => c.Services.ForEach(s => s.Status = ProvisioningStatus.Deployed));

                // Update statusses
                foreach (var tenant in userAccount.Tenants)
                {
                    // Set the Status
                    if (!tenant.AzureServicesProvisioned)
                    {
                        tenant.Status = pipelineRunning && userAccount.Username.Equals(username) ? ProvisioningStatus.Removing : ProvisioningStatus.NotDeployed;
                    }
                    else
                    {
                        tenant.Status = pipelineRunning && userAccount.Username.Equals(username) ? ProvisioningStatus.Removing : ProvisioningStatus.Deployed;
                    }
                }
            }

            // Build up the ViewBag
            ViewBag.PipelineRunning = pipelineRunning;
            ViewBag.Username = username;

            return View(viewModel);
        }

        #endregion

        #region - Ajax Helpers -

        public ActionResult StartDeprovisioning(string username)
        {
            var tenantService = new TenantService();
            var tenants = tenantService.FetchByUsername(username);

            TempData["PipelineRunning"] = true;
            TempData["Username"] = username;

            DeprovisionTenantSite(tenants);

            return RedirectToAction("Index", "AdminView");
        }

        [HttpGet]
        public JsonResult GetStatusses()
        {
            var provisioningServices = Session["ProvisioningService"] as List<ProvisioningService>;
            var viewModel = new ProvisioningStatusViewModel();

            if (provisioningServices != null)
            {
                foreach (var service in provisioningServices)
                {
                    var statusses = service.GetStatusses();

                    // Return statusses
                    viewModel.Tenants.Add(new TenantStatusViewModel()
                    {
                        TenantId = service.ProvisioningParameters.Tenant.TenantId,
                        ProvisioningCompleted = service.TasksCompleted,
                        ErrorsOccurred = statusses.Any(s => s.Status.Equals("Error")),

                        Services = statusses.Select(s => new ServiceStatusViewModel()
                        {
                            StatusId = s.Id,
                            Name = s.Name,
                            Service = s.Service,
                            Status = s.Status,
                            Message = s.Message
                        }).ToList()
                    });
                }
            }

            return Json(new
            {
                Result = viewModel
            }, JsonRequestBehavior.AllowGet);
        }

        private void DeprovisionTenantSite(IEnumerable<TenantModel> tenants)
        {
            var provisioningServices = new List<ProvisioningService>();

            // Create services
            foreach (var tenant in tenants)
            {
                var service = ProvisioningService.CreateForTenant(tenant.TenantId);

                // Start and Run the Deprovisioning tasks asynchronously
                var task = new Task(service.RunDeprovisioningTasks);
                task.Start();

                provisioningServices.Add(service);
            }

            // Save the Provisioning service for later access
            Session["ProvisioningService"] = provisioningServices;
        }

        #endregion
    }
}
