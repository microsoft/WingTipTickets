using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Models;
using TenantProvisioning.Core.Services;
using TenantProvisioning.Mvc.Models;

using ProvisioningStatus = TenantProvisioning.Core.Helpers.ProvisioningStatus;

namespace TenantProvisioning.Mvc.Controllers
{
    [Authorize(Roles = RoleNames.Tenant)]
    public class TenantViewController : Controller
    {
        #region - Index View -

        [HttpGet]
        public ActionResult Index()
        {
            // Get working values
            var pipelineRunning = TempData["PipelineRunning"] != null && (bool)TempData["PipelineRunning"];
            var process = TempData["Process"] != null ? TempData["Process"].ToString() : string.Empty;

            // Get data
            var tenantService = new TenantService();
            var tenants = tenantService.FetchByUsername(HttpContext.User.Identity.SplitName());

            // Build the ViewModel
            var viewModel = BuildTenantViewModel(tenants);
            AddTenantServices(viewModel, pipelineRunning, process);
            SetupViewBag(viewModel, pipelineRunning, process);

            return View(viewModel);
        }

        #endregion

        #region - Ajax Helpers -

        public ActionResult StartProvisioning()
        {
            TempData["PipelineRunning"] = true;
            TempData["Process"] = "Provisioning";

            var tenantService = new TenantService();
            var tenants = tenantService.FetchByUsername(HttpContext.User.Identity.SplitName());

            ProvisionTenantSite(tenants);

            return RedirectToAction("Index", "TenantView");
        }

        public ActionResult StartDeprovisioning()
        {
            TempData["PipelineRunning"] = true;
            TempData["Process"] = "Deprovisioning";

            var tenantService = new TenantService();
            var tenants = tenantService.FetchByUsername(HttpContext.User.Identity.SplitName());

            DeprovisionTenantSite(tenants);

            return RedirectToAction("Index", "TenantView");
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

        [HttpGet]
        public JsonResult ClearServiceFromSession()
        {
            Session["ProvisioningService"] = null;

            return Json(new
            {
                Completed = true
            }, JsonRequestBehavior.AllowGet);
        }

        #endregion

        #region - Private Methods -

        private static MyAccountViewModel BuildTenantViewModel(IEnumerable<TenantModel> tenants)
        {
            // Set default
            var viewModel = new MyAccountViewModel();

            // Build the viewmodel
            if (tenants != null)
            {
                viewModel = new MyAccountViewModel()
                {
                    UserAccounts = tenants.GroupBy(u => u.Username).Select(u => new UserAccountViewModel()
                    {
                        Username = u.Key,
                        Tenants = u.Select(t => new TenantViewModel()
                        {
                            Id = t.TenantId,
                            Plan = t.ProvisioningOption,
                            Theme = t.Theme,
                            Status = t.AzureServicesProvisioned
                                ? ProvisioningStatus.Deployed
                                : ProvisioningStatus.NotDeployed,
                            AzureServicesProvisioned = t.AzureServicesProvisioned,
                        }).ToList()
                    }).ToList()
                };
            }

            return viewModel;
        }

        private static void AddTenantServices(MyAccountViewModel viewModel, bool pipelineRunning, string process)
        {
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

                // Update statusses
                foreach (var tenant in userAccount.Tenants)
                {
                    // Set the Status
                    if (!tenant.AzureServicesProvisioned)
                    {
                        tenant.Status = pipelineRunning
                            ? process.Equals("Provisioning") ? ProvisioningStatus.Provisioning : ProvisioningStatus.Removing
                            : ProvisioningStatus.NotDeployed;

                        tenant.Services.ForEach(s => s.Status = ProvisioningStatus.NotDeployed);
                    }
                    else
                    {
                        tenant.Status = pipelineRunning && process.Equals("Deprovisioning") ? ProvisioningStatus.Removing : ProvisioningStatus.Deployed;
                        tenant.Services.ForEach(s => s.Status = ProvisioningStatus.Deployed);
                    }
                }
            }
        }

        private void SetupViewBag(MyAccountViewModel viewModel, bool pipelineRunning, string process)
        {
            // Build up the ViewBag
            var tenants = viewModel.UserAccounts[0].Tenants;

            ViewBag.ShowOpen = tenants.All(t => t.AzureServicesProvisioned);
            ViewBag.ShowStart = tenants.Any(t => !t.AzureServicesProvisioned) && !pipelineRunning;

            ViewBag.ShowDelete = !pipelineRunning;
            ViewBag.PipelineRunning = pipelineRunning;
            ViewBag.Process = process;
        }

        private void ProvisionTenantSite(IEnumerable<TenantModel> tenants)
        {
            var provisioningServices = new List<ProvisioningService>();

            // Create services
            foreach (var tenant in tenants.Where(t => !t.AzureServicesProvisioned))
            {
                var service = ProvisioningService.CreateForTenant(tenant.TenantId);

                // Start and Run the Provisioning tasks asynchronously
                var task = new Task(service.RunProvisioningTasks);
                task.Start();

                provisioningServices.Add(service);
            }

            // Save the Provisioning service for later access
            Session["ProvisioningService"] = provisioningServices;
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
