using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Models;
using TenantProvisioning.Core.Provisioners.Base;

using ProvisioningParameters = TenantProvisioning.Core.Models.ProvisioningParameters;
using ProvisioningStatus = TenantProvisioning.Core.Models.ProvisioningStatus;

namespace TenantProvisioning.Core.Services
{
    public class ProvisioningService
    {
        #region - Fields -

        private readonly ProvisioningParameters _provisioningParameters;
        private readonly List<BaseProvisioner> _provisioningTasks = new List<BaseProvisioner>();

        #endregion

        #region - Properties -

        public bool TasksCompleted { get; private set; }
        public bool ProvisioningCompleted { get; private set; }
        public bool ErrorsOccurred { get; private set; }
        public bool IsAutomaticLocation { get; private set; }

        public string AutomaticLocation { get; private set; }

        public ProvisioningParameters ProvisioningParameters
        {
            get
            {
                return _provisioningParameters;
            }
        }

        #endregion

        #region - Constructors -

        private ProvisioningService(int provisioningOptionId, ProvisioningParameters provisioningParameters)
        {
            _provisioningTasks = Factory.CreatePipeline(provisioningOptionId, provisioningParameters);
            _provisioningParameters = provisioningParameters;

            SetParameters();
        }

        #endregion

        #region - Public Methods -

        public List<ProvisioningStatus> GetStatusses()
        {
            return _provisioningTasks.Select(p => new ProvisioningStatus()
            {
                Id = p.Id,
                Name = p.Name,
                Service = p.Service,
                Status = p.Status,
                Message = p.Message
            }).ToList();
        }

        public void RunProvisioningTasks()
        {
            Reset();

            var task = new Task(Provision);
            task.Start();
        }

        public void RunDeprovisioningTasks()
        {
            Reset();

            var task = new Task(Remove);
            task.Start();
        }

        #endregion

        #region - Private Methods -

        private void Reset()
        {
            // Reset Provisioning
            TasksCompleted = false;
            ProvisioningCompleted = false;
            ErrorsOccurred = false;

            // Reset Statusses and Messages
            _provisioningTasks.ForEach(p => p.Status = "Queued");
            _provisioningTasks.ForEach(p => p.RollbackRequired = false);
            _provisioningTasks.ForEach(p => p.Message = "");
        }

        private void SetParameters()
        {
            // Add Parameters on each Task
            _provisioningTasks.ForEach(p => p.Parameters = ProvisioningParameters);
        }

        private void Provision()
        {
            CheckExistence();

            if (!ErrorsOccurred)
            {
                CreateOrUpdate();
            }
        }

        private void CheckExistence()
        {
            ErrorsOccurred = false;

            // Run existence check on each provisioning tasks
            foreach (var provisioner in _provisioningTasks)
            {
                provisioner.RunExistenceCheck();

                if (provisioner.Status.Equals("Error"))
                {
                    TasksCompleted = true;
                    ErrorsOccurred = true;
                    break;
                }
            }
        }

        private void CreateOrUpdate()
        {
            var locations = GetLocationList();

            // Loop all locations to find viable Sql Server V12 location
            foreach (var location in locations)
            {
                var asyncTaskList = new List<Task<bool>>();
                var awaitTaskList = new List<Task<bool>>();

                // Set first location
                ProvisioningParameters.Properties.LocationPrimary = location;

                // Loop through all the Parallel Provisiong Groups
                for (var group = 1; group <= _provisioningTasks.Max(p => p.GroupNo); group++)
                {
                    awaitTaskList = new List<Task<bool>>();

                    // Start tasks assigned to group
                    foreach (var provisioner in _provisioningTasks.Where(p => p.GroupNo == group))
                    {
                        var task = new Task<bool>(provisioner.RunCreateOrUpdate);
                        task.Start();

                        if (provisioner.WaitForCompletion)
                        {
                            awaitTaskList.Add(task);
                        }
                        else
                        {
                            asyncTaskList.Add(task);
                        }
                    }

                    // Wait for non-waiting tasks before continueing to group 5 (deploys the website)
                    // Certain settings are required from the previous groups
                    if (group == 4)
                    {
                        Task.WaitAll(asyncTaskList.ToArray());

                        // Check if errors occurred
                        if (asyncTaskList.Any(t => t.Result == false))
                        {
                            TasksCompleted = true;
                            ErrorsOccurred = true;

                            break;
                        }
                    }

                    // Await tasks marked for waiting
                    Task.WaitAll(awaitTaskList.ToArray());

                    // Check if Rollback is needed
                    if (_provisioningTasks.Any(t => t.RollbackRequired))
                    {
                        _provisioningTasks.ForEach(p => p.Status = "Queued");

                        var resourceGroup = _provisioningTasks.First(p => p.Service.Equals("Resource Group"));
                        ErrorsOccurred = !resourceGroup.RunRemove("Select Next V12 Location");

                        break;
                    }

                    // Check if errors occurred
                    if (awaitTaskList.Any(t => t.Result == false))
                    {
                        TasksCompleted = true;
                        ErrorsOccurred = true;

                        break;
                    }
                }
            }

            // Set completion status and automatically selected location
            AutomaticLocation = ProvisioningParameters.Properties.LocationPrimary;
            TasksCompleted = true;

            // Mark scheduleTenant as provisioned
            if (_provisioningTasks.All(p => p.Status == "Deployed"))
            {
                ProvisioningCompleted = true;

                var tenantService = new TenantService();
                tenantService.SetProvisioningStatus(ProvisioningParameters.Tenant.TenantId, ProvisioningCompleted);
            }
        }

        private IEnumerable<string> GetLocationList()
        {
            // Gets the allowed locations list dependant on whether the user selected a location or not
            IsAutomaticLocation = string.IsNullOrEmpty(ProvisioningParameters.Properties.LocationPrimary);

            return !IsAutomaticLocation
                ? new List<string>() { ProvisioningParameters.Properties.LocationPrimary }
                : ProvisioningParameters.Properties.V12Locations;
        }

        private void Remove()
        {
            ErrorsOccurred = false;

            // Run remove on each provisioning component
            foreach (var provisioner in _provisioningTasks)
            {
                if (!provisioner.RunRemove())
                {
                    ErrorsOccurred = true;
                    break;
                }
            }

            TasksCompleted = true;
        }

        #endregion

        #region - Create Methods -

        public static ProvisioningService CreateForAdmin(int tenantId)
        {
            return Create(tenantId, true);
        }

        public static ProvisioningService CreateForTenant(int tenantId)
        {
            return Create(tenantId, false);
        }

        private static ProvisioningService Create(int tenantId, bool isAdminInterface)
        {
            // Fetch the Tenant
            var tenantService = new TenantService();
            var scheduledTenant = tenantService.FetchByTenantId(tenantId);

            // Get Day1 Tenant Site Url
            var tenants = tenantService.FetchByUsername(scheduledTenant.Username);
            var dayOneTenant = tenants.First(t => t.ProvisioningOptionCode.Equals("S1"));

            // Get DataCenters
            var day = scheduledTenant.ProvisioningOptionCode.Equals("S1") ? 1 : 2;
            var util = new ManagementUtilities();
            var dataCenters = util.GetLocations(day, Settings.AccountSubscriptionId);

            // Build Parameters
            var provisioningParameters = GetParameters(day, dataCenters, scheduledTenant, dayOneTenant, isAdminInterface);

            // Create Provisioning Service
            return new ProvisioningService((int)scheduledTenant.ProvisioningOptionId, provisioningParameters);
        }

        #endregion

        #region - Parameter Methods -

        private static ProvisioningParameters GetParameters(int day, IEnumerable<AzureLocation> dataCenters, TenantModel scheduleTenant, TenantModel day1Tenant, bool isAdminInterface)
        {
            // Default Parameters
            var parameters = new ProvisioningParameters()
            {
                Tenant = new Tenant()
                {
                    TenantId = scheduleTenant.TenantId,
                    SiteName = scheduleTenant.SiteName,
                    Theme = scheduleTenant.Theme,
                },
                Properties = new Properties()
                {
                    LocationPrimary = scheduleTenant.DataCenter,
                    TargetUsername = scheduleTenant.Username,
                    TargetSubscription = scheduleTenant.SubscriptionId,
                    TargetTenant = scheduleTenant.OrganizationId,
                    IsRunningFromAdminInterface = isAdminInterface,
                    V12Locations = dataCenters.Select(d => d.Name).ToList(),
                },
            };

            // Add Values
            if (day == 1)
            {
                SetDay1Parameters(parameters, scheduleTenant.Theme);
            }
            else
            {
                SetDay2Parameters(parameters);    
            }

            return parameters;
        }

        private static void SetDay1Parameters(ProvisioningParameters parameters, string theme)
        {
            // Database Properties
            parameters.Tenant.DatabaseName = Settings.TenantDbName;
            parameters.Tenant.SqlVersion = Settings.TenantDbVersion;
            parameters.Tenant.UserName = Settings.TenantDbUsername;
            parameters.Tenant.Password = Settings.TenantDbPassword;

            // Deployment Switches
            parameters.Properties.HasDatabaseSchema = true;
            parameters.Properties.HasDatabaseViews = true;

            // Deployment Scripts
            parameters.Properties.DatabaseSchema = ResourceHelper.ReadText(@"Tenant\Database\Schema.sql");
            parameters.Properties.DatabaseViews = ResourceHelper.ReadText(@"Tenant\Database\Views.sql");
            parameters.Properties.WebSitePackage = ResourceHelper.ReadBytes(@"Tenant\Website\Package.zip");
            parameters.Properties.WebSitePackageName = "scheduleTenant-package.zip";

            // Database
            switch (theme)
            {
                case "Rock":
                    parameters.Properties.DatabaseInformation = ResourceHelper.ReadText(@"Tenant\Database\Rock.sql");
                    break;
                case "Classical":
                    parameters.Properties.DatabaseInformation = ResourceHelper.ReadText(@"Tenant\Database\Symphony.sql");
                    break;
                case "Pop":
                    parameters.Properties.DatabaseInformation = ResourceHelper.ReadText(@"Tenant\Database\Pop.sql");
                    break;
            }
        }

        private static void SetDay2Parameters(ProvisioningParameters parameters)
        {
            // Database Properties
            parameters.Tenant.DatabaseName = Settings.ProductRecommendationsDbName;
            parameters.Tenant.SqlVersion = Settings.ProductRecommendationsDbVersion;
            parameters.Tenant.UserName = Settings.ProductRecommendationsDbUsername;
            parameters.Tenant.Password = Settings.ProductRecommendationsDbPassword;

            // Deployment Switches
            parameters.Properties.HasDatabaseSchema = true;
            parameters.Properties.HasDatabaseViews = false;

            // Deployment Scripts
            parameters.Properties.DatabaseSchema = ResourceHelper.ReadText(@"ProductRecommendations\Database\Schema.sql");
            parameters.Properties.DatabaseInformation = ResourceHelper.ReadText(@"ProductRecommendations\Database\Populate.sql");
            parameters.Properties.WebSitePackage = ResourceHelper.ReadBytes(@"ProductRecommendations\Website\Package.zip");
            parameters.Properties.WebSitePackageName = "recommendations-package.zip";
        }

        #endregion
    }
}
