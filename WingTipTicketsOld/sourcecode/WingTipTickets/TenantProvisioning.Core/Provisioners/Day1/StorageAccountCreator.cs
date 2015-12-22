using System;
using System.IO;
using System.Threading;
using Microsoft.Azure.Management.Storage;
using Microsoft.Azure.Management.Storage.Models;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using TenantProvisioning.Core.Provisioners.Base;

namespace TenantProvisioning.Core.Provisioners.Day1
{
    public class StorageAccountCreator : BaseProvisioner
    {
        #region - Constructors -

        public StorageAccountCreator(int id, string position, int groupNo, bool waitForCompletion)
            : base(position, groupNo, waitForCompletion)
        {
            Id = id;
            Service = "Storage Account";
        }

        #endregion

        #region - Overidden Methods -

        protected override bool CheckExistence()
        {
            if (Parameters.Properties.ResourceGroupExists)
            {
                using (var storageClient = new StorageManagementClient(GetCredentials()))
                {
                    var availabilityResult = storageClient.StorageAccounts.CheckNameAvailabilityAsync(Parameters.Tenant.SiteName).Result;

                    return !availabilityResult.NameAvailable;
                }
            }

            return false;
        }

        protected override bool CreateOrUpdate()
        {
            var created = true;

            try
            {
                var exists = CheckExistence();

                // Skip if exists
                if (!exists)
                {
                    // Create Account
                    CreateStorageAccount();
                }

                // Set Values
                SetPrimaryStorageKey();
                SetSecondaryLocation();

                // Upload Deployment Pack
                UploadDeploymentPackage();

                RollbackRequired = CheckIfSqlServerRollbackRequired();
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

        private bool CheckIfSqlServerRollbackRequired()
        {
            // Check existence
            var primaryLocation = Parameters.Location("Primary");
            var secondaryLocation = Parameters.Location("Secondary");

            if (!Parameters.Properties.V12Locations.Contains(primaryLocation) && !Parameters.Properties.V12Locations.Contains(secondaryLocation))
            {
                return true;
            }

            return false;
        }
        
        private void CreateStorageAccount()
        {
            using (var storageClient = new StorageManagementClient(GetCredentials()))
            {
                // Create the Storage Account
                var checkResult = storageClient.StorageAccounts.CheckNameAvailabilityAsync(Parameters.Tenant.SiteName).Result;

                if (checkResult.NameAvailable)
                {
                    var createResult = storageClient.StorageAccounts.CreateAsync(
                        Parameters.Tenant.SiteName,
                        Parameters.Tenant.SiteName,
                        new StorageAccountCreateParameters
                        {
                            AccountType = AccountType.StandardGRS,
                            Location = Parameters.Location(Position)
                        }).Result;
                }
            }
        }

        private void SetPrimaryStorageKey()
        {
            using (var storageClient = new StorageManagementClient(GetCredentials()))
            {
                // Get Primary Storage Key
                var keyResult = storageClient.StorageAccounts.ListKeysAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName).Result;

                Parameters.Tenant.StoragePrimaryKey = keyResult.StorageAccountKeys.Key1;
            }
        }

        private void SetSecondaryLocation()
        {
            using (var storageClient = new StorageManagementClient(GetCredentials()))
            {
                // Get Secondary Location
                var propertyResult = storageClient.StorageAccounts.GetProperties(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName);

                Parameters.Properties.LocationSecondary = propertyResult.StorageAccount.SecondaryLocation;
            }
        }

        private void UploadDeploymentPackage()
        {
            // Retrieve storage account
            var storageAccount = CloudStorageAccount.Parse(string.Format("DefaultEndpointsProtocol=https;AccountName={0};AccountKey={1}", Parameters.Tenant.SiteName, Parameters.Tenant.StoragePrimaryKey));

            // Create the blob client
            var blobClient = storageAccount.CreateCloudBlobClient();

            // Retrieve container reference
            var container = blobClient.GetContainerReference("deployment-files");

            // Create container if it doesn't already exist
            container.CreateIfNotExists();

            // Set permissions
            container.SetPermissions(
            new BlobContainerPermissions
            {
                PublicAccess = BlobContainerPublicAccessType.Blob
            });

            // Retrieve reference to a blob
            var blockBlob = container.GetBlockBlobReference(Parameters.Properties.WebSitePackageName);

            // Sleep for 30 seconds to give the Storage Account some time
            // known bug if continueing to fast
            Thread.Sleep(30000);

            // Create or overwrite the blob with contents from resource
            using (var fileStream = new MemoryStream(Parameters.Properties.WebSitePackage))
            {
                blockBlob.UploadFromStream(fileStream);
            }
        }

        #endregion
    }
}
