using System;
using System.Linq;
using System.Threading;
using Microsoft.Azure.Management.Sql;
using Microsoft.Azure.Management.Sql.Models;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Provisioners.Base;

namespace TenantProvisioning.Core.Provisioners.Shared
{
    public class SqlAuditing : BaseProvisioner
    {
        #region - Constructors -

        public SqlAuditing(int id, string position, int groupNo, bool waitForCompletion)
            : base(position, groupNo, waitForCompletion)
        {
            Id = id;
            Service = "Auditing";
        }

        #endregion

        #region - Overidden Methods -

        protected override bool CheckExistence()
        {
            if (Parameters.Properties.ResourceGroupExists)
            {
                using (var client = new SqlManagementClient(GetCredentials()))
                {
                    var serverList = client.Servers.ListAsync(Parameters.Tenant.SiteName).Result;
                    var server = serverList.Servers.FirstOrDefault(s => s.Name.Equals(Parameters.GetSiteName(Position)));

                    //if (server != null)
                    //{
                    //    var getResult = client.AuditingPolicy.GetServerPolicyAsync(Parameters.Tenant.SiteName, Parameters.GetSiteName(Position)).Result;
                    //    return getResult.AuditingPolicy != null;
                    //}
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
                    // Sleep for 30 seconds to give the Traffic Manager Some time
                    // known bug if auditing switched on too fast
                    Thread.Sleep(30000);

                    using (var client = new SqlManagementClient(GetCredentials()))
                    {
                        var createResult = client.AuditingPolicy.CreateOrUpdateServerPolicyAsync(
                            Parameters.Tenant.SiteName,
                            Parameters.GetSiteName(Position),
                            new ServerAuditingPolicyCreateOrUpdateParameters()
                            {
                                Properties = new ServerAuditingPolicyProperties()
                                {
                                    AuditingState = "Enabled",
                                    StorageAccountKey = Parameters.Tenant.StoragePrimaryKey,
                                    StorageAccountName = Parameters.Tenant.SiteName,
                                    StorageAccountResourceGroupName = Parameters.Tenant.SiteName,
                                    StorageAccountSubscriptionId = Settings.AccountSubscriptionId,
                                    EventTypesToAudit = "PlainSQL_Success,PlainSQL_Failure,ParameterizedSQL_Success,ParameterizedSQL_Failure,StoredProcedure_Success,StoredProcedure_Success"
                                }
                            }).Result;
                    }
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
    }
}
