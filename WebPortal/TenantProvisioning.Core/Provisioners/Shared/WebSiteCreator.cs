using System;
using System.Linq;
using Microsoft.Azure.Management.Resources;
using Microsoft.Azure.Management.Resources.Models;
using Microsoft.Azure.Management.TrafficManager.Models;
using Microsoft.Azure.Management.WebSites;
using Microsoft.Azure.Management.WebSites.Models;
using TenantProvisioning.Core.Provisioners.Base;

namespace TenantProvisioning.Core.Provisioners.Shared
{
    public class WebSiteCreator : BaseProvisioner
    {
        #region - Constructors -

        public WebSiteCreator(int id, string position, int groupNo, bool waitForCompletion)
            : base(position, groupNo, waitForCompletion)
        {
            Id = id;
            Service = "WebSite";
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
                        ResourceType = "Microsoft.Web/sites"
                    }).Result;

                    return result.Resources.Any();
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
                    var websiteId = CreateWebsite();
                    AddEndPoints(websiteId);
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

        private string CreateWebsite()
        {
            using (var client = new WebSiteManagementClient(GetCredentials()))
            {
                var wsResult = client.WebSites.CreateOrUpdateAsync(
                    Parameters.Tenant.SiteName,
                    Parameters.GetSiteName(Position),
                    null,
                    new WebSiteCreateOrUpdateParameters()
                    {
                        WebSite = new WebSiteBase(Parameters.Location(Position))
                        {
                            Properties = new WebSiteBaseProperties()
                            {
                                ServerFarm = Parameters.FarmName(Position)
                            }
                        }
                    }).Result;

                return wsResult.WebSite.Id;
            }
        }

        private void AddEndPoints(string websiteId)
        {
            Parameters.Properties.EndPoints.Add(new Endpoint()
            {
                Name = Position,
                Type = "Microsoft.Network/trafficManagerProfiles/azureEndpoints",
                Properties =
                    new EndpointProperties(string.Format("{0}.azurewebsites.net", Parameters.GetSiteName(Position)), "Enabled")
                    {
                        EndpointStatus = "Enabled",
                        Target = string.Format("{0}.azurewebsites.net/", Parameters.GetSiteName(Position)),
                        TargetResourceId = websiteId
                    },
            });
        }

        #endregion
    }
}
