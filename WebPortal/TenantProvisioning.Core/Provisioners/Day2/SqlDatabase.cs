using System;
using System.Linq;
using System.Threading;
using Microsoft.Azure.Management.Sql;
using Microsoft.Azure.Management.Sql.Models;
using TenantProvisioning.Core.Models;
using TenantProvisioning.Core.Provisioners.Base;

using ProvisioningStatus = TenantProvisioning.Core.Helpers.ProvisioningStatus;

namespace TenantProvisioning.Core.Provisioners.Day2
{
    public class SqlDatabase : BaseProvisioner
    {
        #region - Constructors -

        public SqlDatabase(int id, string position, int groupNo, bool waitForCompletion)
            : base(position, groupNo, waitForCompletion)
        {
            Id = id;
            Service = "Database Server";
        }

        #endregion

        #region - Overidden Methods -

        protected override bool CheckExistence()
        {
            var exists = false;

            // Check existence
            if (Parameters.Properties.ResourceGroupExists)
            {
                using (var client = new SqlManagementClient(GetCredentials()))
                {
                    var listResult = client.Servers.ListAsync(Parameters.Tenant.SiteName).Result;
                    var server = listResult.Servers.FirstOrDefault(s => s.Name.Equals(Parameters.GetSiteName(Position)));

                    Parameters.Properties.Components.Add(new AzureComponent()
                    {
                        Name = Parameters.GetSiteName(Position),
                        Service = Service,
                        Exists = server != null
                    });

                    if (server != null)
                    {
                        Status = ProvisioningStatus.Warning;
                        Message = string.Format("{0} name {1} is already in use and will be updated.", Service, Parameters.GetSiteName(Position));
                        exists = true;
                    }
                }
            }

            return exists;
        }

        protected override bool CreateOrUpdate()
        {
            var created = true;

            try
            {
                // Skip if exists
                if (!CheckExistence())
                {
                    CreateServer();
                    CreateFirewallRule();
                }
            }
            catch (Exception ex)
            {
                created = false;
                Message = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
            }

            return created;
        }

        private void CreateServer()
        {
            using (var client = new SqlManagementClient(GetCredentials()))
            {
                var createResult = client.Servers.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.GetSiteName(Position),
                    new ServerCreateOrUpdateParameters()
                    {
                        Location = Parameters.Location(Position),
                        Properties = new ServerCreateOrUpdateProperties()
                        {
                            AdministratorLogin = Parameters.Tenant.UserName,
                            AdministratorLoginPassword = Parameters.Tenant.Password,
                            Version = Parameters.Tenant.SqlVersion
                        }
                    }).Result;
            }
        }

        private void CreateFirewallRule()
        {
            using (var client = new SqlManagementClient(GetCredentials()))
            {
                // Sleep for 30 seconds to give the Firewall settings some time
                Thread.Sleep(30000);

                var firewallResult = client.FirewallRules.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.GetSiteName(Position), "OpenAll",
                    new FirewallRuleCreateOrUpdateParameters()
                    {
                        Properties = new FirewallRuleCreateOrUpdateProperties()
                        {
                            StartIpAddress = "0.0.0.0",
                            EndIpAddress = "255.255.255.255",
                        }
                    }).Result;
            }
        }

        #endregion
    }
}
