using System;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading;
using System.Web.Helpers;
using Microsoft.Azure.Management.Resources;
using Microsoft.Azure.Management.Resources.Models;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Provisioners.Base;

using ProvisioningState = Microsoft.Azure.Management.Storage.Models.ProvisioningState;

namespace TenantProvisioning.Core.Provisioners.Shared
{
    public class DocumentDb : BaseProvisioner
    {
        #region - Constructors -

        public DocumentDb(int id, string position, int groupNo, bool waitForCompletion)
            : base(position, groupNo, waitForCompletion)
        {
            Id = id;
            Service = "Document DB";
        }

        #endregion

        #region - Overidden Methods -

        protected override bool CheckExistence()
        {
            if (Parameters.Properties.ResourceGroupExists)
            {
                using (var client = new ResourceManagementClient(GetCredentials()))
                {
                    var result = client.Resources.ListAsync(new ResourceListParameters()
                    {
                        ResourceGroupName = Parameters.Tenant.SiteName,
                        ResourceType = "Microsoft.DocumentDb/databaseAccounts"
                    }).Result;

                    return result.Resources.Any(r => r.Name.Equals(Parameters.Tenant.SiteName));
                }
            }

            return false;
        }

        protected override bool CreateOrUpdate()
        {
            var created = true;

            try
            {
                using (var client = new ResourceManagementClient(GetCredentials()))
                {
                    // Skip if exists
                    if (!CheckExistence())
                    {
                        // Build deployment parameters
                        var deployment = new Deployment
                        {
                            Properties = new DeploymentProperties
                            {
                                Mode = DeploymentMode.Incremental,
                                Template = GetTemplate(),
                            }
                        };

                        // Run deployment
                        var result = client.Deployments.CreateOrUpdateAsync(Parameters.Tenant.SiteName, "Microsoft.DocumentDB", deployment).Result;

                        // Wait for deployment to finish
                        for (var i = 0; i < 30; i++)
                        {
                            var deploymentStatus = client.Deployments.GetAsync(Parameters.Tenant.SiteName, "Microsoft.DocumentDB").Result;

                            if (deploymentStatus.Deployment.Properties.ProvisioningState == ProvisioningState.Succeeded.ToString())
                            {
                                break;
                            }

                            Thread.Sleep(30000);
                        }

                        Console.WriteLine(result.StatusCode);
                    }

                    // Find the Account Keys
                    SetAccountKeys();
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

        private void SetAccountKeys()
        {
            // Get capabilities uri
            var uri = BuildUri("https://management.azure.com/subscriptions/{0}/resourcegroups/{1}/providers/Microsoft.DocumentDB/databaseAccounts/{2}/listKeys?api-version=2015-04-08", Settings.AccountSubscriptionId, Parameters.Tenant.SiteName, Parameters.Tenant.SiteName);

            // Create the HttpClient
            var client = CreateManagementClient(uri);

            // Invoke get request
            var content = new StringContent("");
            content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            // Invoke get request
            var response = client.PostAsync(uri, content).Result;

            if (response.IsSuccessStatusCode)
            {
                // Read Json response
                var dataObjects = response.Content.ReadAsStringAsync().Result;
                dynamic data = Json.Decode(dataObjects);

                // Build up capable locations
                Parameters.Tenant.DocumentDbKey = data.PrimaryMasterKey;
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }
        }

        private string GetTemplate()
        {
            // Load the Template resource file
            var template = ResourceHelper.ReadText(@"Tenant\DocumentDb\Deployment.json");

            // Replace the paramater values
            template = template.Replace("@DatabaseName", Parameters.Tenant.SiteName);
            template = template.Replace("@Location", Parameters.Properties.LocationPrimary);

            return template;
        }

        #endregion
    }
}
