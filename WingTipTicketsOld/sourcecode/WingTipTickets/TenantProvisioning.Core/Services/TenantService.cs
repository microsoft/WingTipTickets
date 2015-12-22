using System.Collections.Generic;
using System.Security.Claims;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Models;
using TenantProvisioning.Core.Provisioners.Shared;
using TenantProvisioning.Core.Repositories;

namespace TenantProvisioning.Core.Services
{
    public class TenantService
    {
        #region - Public Methods -

        public TenantModel FetchByTenantId(int tenantId)
        {
            // Create repository
            var tenantRepository = new TenantRepository();

            // Find the tenant
            var tenant = tenantRepository.FetchById(tenantId);

            return tenant;
        }

        public List<TenantModel> FetchByUsername(string username)
        {
            // Create repository
            var tenantRepository = new TenantRepository();

            // Find the tenant
            var tenants = tenantRepository.FetchByUsername(username);

            return tenants;
        }

        public List<TenantModel> FetchTenants()
        {
            // Create repository
            var tenantRepository = new TenantRepository();

            // FetchById the themes
            var tenants = tenantRepository.FetchAll();

            return tenants;
        }

        public List<string> Validate(string siteName, string subscriptionId)
        {
            var errors = new List<string>();

            // Create provisioner
            var resourceGroupTask = new ResourceGroup(1, "", 1, true)
            {
                Parameters = new ProvisioningParameters()
                {
                    Tenant = new Tenant()
                    {
                        SiteName = siteName,
                    },
                    Properties = new Properties()
                    {
                        TargetUsername = ClaimsPrincipal.Current.Identity.SplitName(),
                        TargetSubscription = subscriptionId,
                        TargetTenant = Settings.AccountOrganizationId,
                        IsRunningFromAdminInterface = true,
                    }
                }
            };

            // Check if resource group unique
            if (resourceGroupTask.RunExistenceCheck())
            {
                errors.Add(string.Format("The resource group name {0} is already in use", siteName));
            }

            return errors;
        }

        public int CreateDay1(CreateTenantModel domainModel)
        {
            var username = ClaimsPrincipal.Current.Identity.SplitName();

            // Create repositories
            var tenantRepository = new TenantRepository();
            var userAccountRepository = new UserAccountRepository();
            var creditCardRepository = new CreditCardRepository();

            // Get the User
            var user = userAccountRepository.Fetch(username);

            // Create the Tenant
            var tenantId = tenantRepository.Create(user.UserAccountId, domainModel.Tenant);

            // Create the CreditCard
            if (!string.IsNullOrEmpty(domainModel.CreditCard.CreditCardNumber))
            {
                creditCardRepository.Insert(tenantId, domainModel.CreditCard);
            }

            // Update the User
            userAccountRepository.UpdatePesonalDetails(username, domainModel.UserAccount.Firstname, domainModel.UserAccount.Lastname);

            return tenantId;
        }

        public int CreateDay2(CreateTenantModel domainModel)
        {
            var username = ClaimsPrincipal.Current.Identity.SplitName();

            // Create repositories
            var tenantRepository = new TenantRepository();
            var userAccountRepository = new UserAccountRepository();

            // Get the User
            var user = userAccountRepository.Fetch(username);

            // Create the Tenant
            var tenantId = tenantRepository.Create(user.UserAccountId, domainModel.Tenant);

            return tenantId;
        }

        public int SetProvisioningStatus(int tenantId, bool azureServicesProvisioned)
        {
            // Create repositories
            var tenantRepository = new TenantRepository();

            // Update the Tenant
            var rowsAffected = tenantRepository.SetProvisioningStatus(tenantId, azureServicesProvisioned);

            return rowsAffected;
        }

        public int DeleteTenant(string username)
        {
            // Create repositories
            var tenantRepository = new TenantRepository();

            // Update the Tenant
            var rowsAffected = tenantRepository.Delete(username);

            return rowsAffected;
        }

        #endregion
    }
}