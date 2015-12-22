using System;
using Microsoft.Azure.Management.Resources;
using TenantProvisioning.Core.Provisioners.Base;

namespace TenantProvisioning.Core.Provisioners.Shared
{
    public class ResourceGroup : BaseProvisioner
    {
        #region - Constructors -

        public ResourceGroup(int id, string position, int groupNo, bool waitForCompletion)
            : base(position, groupNo, waitForCompletion)
        {
            Id = id;
            Service = "Resource Group";
        }

        #endregion

        #region - Overidden Methods -

        protected override bool CheckExistence()
        {
            using (var resourceClient = new ResourceManagementClient(GetCredentials()))
            {
                var existenceResult = resourceClient.ResourceGroups.CheckExistenceAsync(Parameters.Tenant.SiteName).Result;

                Parameters.Properties.ResourceGroupExists = existenceResult.Exists;
                return existenceResult.Exists;
            }
        }

        protected override bool CreateOrUpdate()
        {
            var created = true;

            try
            {
                // Skip if exists
                if (!CheckExistence())
                {
                    //throw new Exception();

                    CreateResourceGroup();
                    RegisterProviders();
                }
            }
            catch (Exception ex)
            {
                created = false;
                Message = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
            }

            return created;
        }

        protected override bool Remove()
        {
            var removed = true;

            try
            {
                using (var client = new ResourceManagementClient(GetCredentials()))
                {
                    var checkResult = client.ResourceGroups.CheckExistenceAsync(Parameters.Tenant.SiteName).Result;

                    if (checkResult.Exists)
                    {
                        var deleteResult = client.ResourceGroups.DeleteAsync(Parameters.Tenant.SiteName).Result;
                    }
                }
            }
            catch (Exception ex)
            {
                removed = false;
                Message = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
            }

            return removed;
        }

        #endregion

        #region - Private Methods -

        private void CreateResourceGroup()
        {
            using (var resourceClient = new ResourceManagementClient(GetCredentials()))
            {
                if (!Parameters.Properties.ResourceGroupExists)
                {
                    var createResult = resourceClient.ResourceGroups.CreateOrUpdateAsync(
                        Parameters.Tenant.SiteName,
                        new Microsoft.Azure.Management.Resources.Models.ResourceGroup()
                        {
                            Location = Parameters.Location(Position)
                        }).Result;
                }
            }
        }

        private void RegisterProviders()
        {
            using (var resourceClient = new ResourceManagementClient(GetCredentials()))
            {
                // Register Providers
                var registerStorageResult = resourceClient.Providers.RegisterAsync("Microsoft.Storage").Result;
                var registerNetworkResult = resourceClient.Providers.RegisterAsync("Microsoft.Network").Result;
                var registerComputeResult = resourceClient.Providers.RegisterAsync("Microsoft.Compute").Result;
                var registerDocumentResult = resourceClient.Providers.RegisterAsync("Microsoft.DocumentDb").Result;
                var registerWebResult = resourceClient.Providers.RegisterAsync("Microsoft.Web").Result;
                var registerDataFactory = resourceClient.Providers.RegisterAsync("Microsoft.DataFactory").Result;
            }
        }

        #endregion
    }
}
