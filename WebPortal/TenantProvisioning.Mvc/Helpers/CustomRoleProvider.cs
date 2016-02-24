using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Web.Security;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Services;

namespace TenantProvisioning.Mvc.Helpers
{
    public class CustomRoleProvider : RoleProvider
    {
        #region - Public Methods -

        public override bool IsUserInRole(string username, string roleName)
        {
            // Check if Administrator
            if (roleName.Equals(RoleNames.Administrator) && IsAdministrator())
            {
                return true;
            }

            // Check if Tenant
            if (roleName.Equals(RoleNames.Tenant) && IsTenant(username))
            {
                return true;
            }

            return false;
        }

        public override string[] GetRolesForUser(string username)
        {
            var roles = new List<string>();

            // Check if Administrator
            if (IsAdministrator())
            {
                roles.Add(RoleNames.Administrator);
            }

            // Check if Tenant
            if (IsTenant(username))
            {
                roles.Add(RoleNames.Tenant);
            }

            return roles.ToArray();
        }

        #endregion

        #region - Private Methods -

        private bool IsAdministrator()
        {
            // Check if Administrator
            if (ClaimsPrincipal.Current.Identity.IsAuthenticated)
            {
                var tenantId = Settings.AccountOrganizationId;

                if (tenantId.Equals(Settings.ProvisionerTenantId))
                {
                    return true;
                }
            }

            return false;
        }

        private bool IsTenant(string username)
        {
            // Fix the Username
            username = username.Split('#').Last();

            // Find the user
            var command = new TenantService();
            var tenants = command.FetchByUsername(username);

            // Check if user
            return tenants != null &&tenants.Any();
        }

        #endregion

        #region - Not Implemented -

        public override void CreateRole(string roleName)
        {
            throw new NotImplementedException();
        }

        public override bool DeleteRole(string roleName, bool throwOnPopulatedRole)
        {
            throw new NotImplementedException();
        }

        public override bool RoleExists(string roleName)
        {
            throw new NotImplementedException();
        }

        public override void AddUsersToRoles(string[] usernames, string[] roleNames)
        {
            throw new NotImplementedException();
        }

        public override void RemoveUsersFromRoles(string[] usernames, string[] roleNames)
        {
            throw new NotImplementedException();
        }

        public override string[] GetUsersInRole(string roleName)
        {
            throw new NotImplementedException();
        }

        public override string[] GetAllRoles()
        {
            throw new NotImplementedException();
        }

        public override string[] FindUsersInRole(string roleName, string usernameToMatch)
        {
            throw new NotImplementedException();
        }

        public override string ApplicationName { get; set; }

        #endregion
    }
}