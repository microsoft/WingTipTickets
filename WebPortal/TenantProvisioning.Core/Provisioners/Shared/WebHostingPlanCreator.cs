using System;
using System.Linq;
using Microsoft.Azure.Management.WebSites;
using Microsoft.Azure.Management.WebSites.Models;
using TenantProvisioning.Core.Provisioners.Base;

namespace TenantProvisioning.Core.Provisioners.Shared
{
    public class WebHostingPlanCreator : BaseProvisioner
    {
        #region - Constructors -

        public WebHostingPlanCreator(int id, string position, int groupNo, bool waitForCompletion)
            : base(position, groupNo, waitForCompletion)
        {
            Id = id;
            Service = "WebSite Hosting Plan";
        }

        #endregion

        #region - Overidden Methods -

        protected override bool CheckExistence()
        {
            if (Parameters.Properties.ResourceGroupExists)
            {
                using (var client = new WebSiteManagementClient(GetCredentials()))
                {
                    var listResult = client.WebHostingPlans.ListAsync(Parameters.Tenant.SiteName).Result;
                    return listResult.WebHostingPlans.Any(p => p.Name.Equals(Parameters.FarmName(Position)));
                }
            }

            return false;
        }

        protected override bool CreateOrUpdate()
        {
            var created = true;

            try
            {
                using (var client = new WebSiteManagementClient(GetCredentials()))
                {
                    // Skip if exists
                    if (!CheckExistence())
                    {
                        var createResult = client.WebHostingPlans.CreateOrUpdateAsync(
                            Parameters.Tenant.SiteName,
                            new WebHostingPlanCreateOrUpdateParameters()
                            {
                                WebHostingPlan =
                                    new WebHostingPlan()
                                    {
                                        Name = Parameters.FarmName(Position),
                                        Location = Parameters.Location(Position),
                                        Properties = new WebHostingPlanProperties()
                                        {
                                            Sku = SkuOptions.Standard
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
