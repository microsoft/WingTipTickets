using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using Microsoft.Azure.Management.Resources;
using Microsoft.Azure.Management.Resources.Models;
using Microsoft.Azure.Management.WebSites;
using Microsoft.Azure.Management.WebSites.Models;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Provisioners.Base;

namespace TenantProvisioning.Core.Provisioners.Day2
{
    public class WebSiteDeployment : BaseProvisioner
    {
        #region - Constructors -

        public WebSiteDeployment(int id, string position, int groupNo, bool waitForCompletion)
            : base(position, groupNo, waitForCompletion)
        {
            Id = id;
            Service = "WebSite Deployment";
        }

        #endregion

        #region - Overidden Methods -

        protected override bool CheckExistence()
        {
            if (Parameters.Properties.ResourceGroupExists)
            {
                using (var client = new ResourceManagementClient(GetCredentials()))
                {
                    var result = client.Deployments.ListAsync(Parameters.Tenant.SiteName, new DeploymentListParameters()
                    {
                        ProvisioningState = ProvisioningState.Succeeded
                    }).Result;

                    return result.Deployments.Any();
                }
            }

            return false;
        }

        protected override bool CreateOrUpdate()
        {
            var created = true;

            try
            {
                // Skip if exists
                if (!CheckExistence())
                {
                    CreateDeployment();
                    UpdateRecommendationsSiteApplicationSettings();
                }
            }
            catch (Exception ex)
            {
                created = false;
                Message = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
            }

            return created;
        }

        #endregion

        #region - Private Methods -

        private void CreateDeployment()
        {
            using (var client = new ResourceManagementClient(GetCredentials()))
            {
                // Create Deployment
                var deploymentResult = client.Deployments.CreateOrUpdateAsync(
                    Parameters.Tenant.SiteName,
                    string.Format("production-{0}", Position),
                    new Deployment()
                    {
                        Properties = new DeploymentProperties()
                        {
                            Mode = DeploymentMode.Incremental,
                            Template = GetTemplate()
                        }
                    }).Result;

                // Wait for Deployment to finish
                var succesful = false;
                for (var i = 0; i < 18; i++)
                {
                    var deploymentStatus = client.Deployments.GetAsync(Parameters.Tenant.SiteName, string.Format("production-{0}", Position)).Result;

                    if (deploymentStatus.Deployment.Properties.ProvisioningState == ProvisioningState.Succeeded)
                    {
                        succesful = true;
                        break;
                    }

                    if (deploymentStatus.Deployment.Properties.ProvisioningState == ProvisioningState.Failed)
                    {
                        break;
                    }

                    Thread.Sleep(30000);
                }

                if (!succesful)
                {
                    throw new Exception("Deployment failed, please see events tab in the portal");
                }
            }
        }

        private void UpdateRecommendationsSiteApplicationSettings()
        {
            using (var client = new WebSiteManagementClient(GetCredentials()))
            {
                // Build up the Application Setting list
                var properties = new List<NameValuePair>()
                {
                    new NameValuePair()
                    {
                        Name = "SqlServer",
                        Value = string.Format("{0}.database.windows.net", Parameters.GetSiteName("primary"))
                    },
                    new NameValuePair()
                    {
                        Name = "SqlDB",
                        Value = Parameters.Tenant.DatabaseName
                    },
                    new NameValuePair()
                    {
                        Name = "SqlUserID",
                        Value = Parameters.Tenant.UserName
                    },
                    new NameValuePair()
                    {
                        Name = "SqlPassword",
                        Value = Parameters.Tenant.Password
                    }
                };

                // Update the Settings
                var updateResult = client.WebSites.UpdateAppSettingsAsync(
                    Parameters.Tenant.SiteName, 
                    Parameters.GetSiteName(Position),
                    null, new WebSiteNameValueParameters()
                    {
                        Location = Parameters.Location(Position),
                        Properties = properties,
                    }).Result;
            }
        }

        private string GetTemplate()
        {
            // Load the Template resource file
            var template = ResourceHelper.ReadText(@"ProductRecommendations\Website\Deployment.json");

            // Replace the paramater values
            template = template.Replace("@SiteName", Parameters.GetSiteName(Position));
            template = template.Replace("@HostingPlanName", Parameters.FarmName(Position));
            template = template.Replace("@SiteLocation", Parameters.Location(Position));
            template = template.Replace("@ApiVersion", "2015-04-01");
            template = template.Replace("@PackageUri", string.Format("https://{0}.blob.core.windows.net/deployment-files/{1}", Parameters.Tenant.SiteName, Parameters.Properties.WebSitePackageName));

            return template;
        }

        #endregion
    }
}
