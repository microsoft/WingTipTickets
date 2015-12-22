using System;
using System.Linq;
using Microsoft.Azure.Management.TrafficManager;
using Microsoft.Azure.Management.TrafficManager.Models;
using TenantProvisioning.Core.Provisioners.Base;

namespace TenantProvisioning.Core.Provisioners.Shared
{
    public class TrafficManagerProfile : BaseProvisioner
    {
        #region - Constructors -

        public TrafficManagerProfile(int id, string position, int groupNo, bool waitForCompletion)
            : base(position, groupNo, waitForCompletion)
        {
            Id = id;
            Service = "Traffic Manager";
        }

        #endregion

        #region - Overidden Methods -

        protected override bool CheckExistence()
        {
            if (Parameters.Properties.ResourceGroupExists)
            {
                using (var client = new TrafficManagerManagementClient(GetCredentials()))
                {
                    var listResult = client.Profiles.ListAllAsync().Result;
                    return listResult.Profiles.Any(database => database.Name.Equals(Parameters.Tenant.SiteName));
                }
            }

            return false;
        }

        protected override bool CreateOrUpdate()
        {
            var created = true;

            try
            {
                using (var client = new TrafficManagerManagementClient(GetCredentials()))
                {
                    // Skip if exists
                    if (!CheckExistence())
                    {
                        var createResult = client.Profiles.CreateOrUpdateAsync(
                            Parameters.Tenant.SiteName, 
                            Parameters.Tenant.SiteName,
                            new ProfileCreateOrUpdateParameters()
                            {
                                Profile = new Profile()
                                {
                                    Location = "Global",
                                    Properties = new ProfileProperties()
                                    {
                                        DnsConfig = new DnsConfig()
                                        {
                                            RelativeName = Parameters.Tenant.SiteName,
                                            Fqdn = string.Format("{0}.trafficmanager.net", Parameters.Tenant.SiteName),
                                            Ttl = 30
                                        },

                                        MonitorConfig = new MonitorConfig("Http", 80, "/"),
                                        TrafficRoutingMethod = "Priority",
                                        Endpoints = Parameters.Properties.EndPoints
                                    }
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
