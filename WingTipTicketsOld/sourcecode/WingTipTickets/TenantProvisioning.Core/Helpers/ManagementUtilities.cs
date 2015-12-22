using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text.RegularExpressions;
using System.Web.Helpers;
using TenantProvisioning.Core.Models;
using TenantProvisioning.Core.Provisioners.Base;

namespace TenantProvisioning.Core.Helpers
{
    public class ManagementUtilities : BaseProvisioner
    {
        #region - Fields -

        private static readonly List<CachedLocations> _cachedLocations = new List<CachedLocations>();

        #endregion

        #region - Constructors -

        public ManagementUtilities() :
            base("Primary")
        {
            
        }

        #endregion


        #region - Main Utilities -

        public List<AzureOrganization> GetOrganizations()
        {
            var organizations = new List<AzureOrganization>();

            // Get capabilities uri
            var uri = BuildUri("https://management.azure.com/tenants?api-version={0}", "2014-04-01-preview");

            // Create the HttpClient
            var client = CreateManagementClient(uri);

            // Invoke get request
            var response = client.GetAsync("").Result;

            if (response.IsSuccessStatusCode)
            {
                // Endpoint returns JSON with an array of Tenant Objects
                // id                                            tenantId
                // --                                            --------
                // /tenants/7fe877e6-a150-4992-bbfe-f517e304dfa0 7fe877e6-a150-4992-bbfe-f517e304dfa0
                // /tenants/62e173e9-301e-423e-bcd4-29121ec1aa24 62e173e9-301e-423e-bcd4-29121ec1aa24

                var responseContent = response.Content.ReadAsStringAsync().Result;
                var organizationsResult = (Json.Decode(responseContent)).value;

                foreach (var organization in organizationsResult)
                {
                    organizations.Add(new AzureOrganization()
                    {
                        Id = organization.tenantId
                    });
                }
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }

            return organizations;
        }

        public List<AzureSubscription> GetSubscriptions(string organizationId)
        {
            var subscriptions = new List<AzureSubscription>();

            // Get capabilities uri
            var uri = BuildUri("https://management.azure.com/subscriptions?api-version={0}", "2014-04-01-preview");

            // Create the HttpClient
            var client = CreateManagementClient(uri);

            // Invoke get request
            var response = client.GetAsync("").Result;

            if (response.IsSuccessStatusCode)
            {
                // Endpoint returns JSON with an array of AzureSubscription Objects
                // id                                                  subscriptionId                       displayName state
                // --                                                  --------------                       ----------- -----
                // /subscriptions/c276fc76-9cd4-44c9-99a7-4fd71546436e c276fc76-9cd4-44c9-99a7-4fd71546436e Production  Enabled
                // /subscriptions/e91d47c4-76f3-4271-a796-21b4ecfe3624 e91d47c4-76f3-4271-a796-21b4ecfe3624 Development Enabled

                var responseContent = response.Content.ReadAsStringAsync().Result;
                var subscriptionsResult = (Json.Decode(responseContent)).value;

                foreach (var subscription in subscriptionsResult)
                {
                    if (subscription.State == "Enabled")
                    {
                        subscriptions.Add(new AzureSubscription()
                        {
                            Id = subscription.subscriptionId,
                            DisplayName = subscription.displayName,
                            OrganizationId = organizationId
                        });
                    }
                }
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }

            return subscriptions;
        }

        public bool CanManageAccess(string subscriptionId, string organizationId)
        {
            var ret = false;

            // Get capabilities uri
            var uri = BuildUri("https://management.azure.com/subscriptions/{0}/providers/microsoft.authorization/permissions?api-version={1}", subscriptionId, "2014-07-01-preview");

            // Create the HttpClient
            var client = CreateManagementClient(uri);

            // Invoke get request
            var response = client.GetAsync("").Result;

            if (response.IsSuccessStatusCode)
            {
                // Endpoint returns JSON with an array of Actions and NotActions
                // actions  notActions
                // -------  ----------
                // {*}      {Microsoft.Authorization/*/Write, Microsoft.Authorization/*/Delete}
                // {*/read} {}

                var responseContent = response.Content.ReadAsStringAsync().Result;
                var permissionsResult = (Json.Decode(responseContent)).value;

                foreach (var permissions in permissionsResult)
                {
                    var permissionMatch = false;

                    foreach (string action in permissions.actions)
                    {
                        var actionPattern = "^" + Regex.Escape(action.ToLower()).Replace("\\*", ".*") + "$";
                        permissionMatch = Regex.IsMatch("microsoft.authorization/roleassignments/write", actionPattern);

                        if (permissionMatch)
                        {
                            break;
                        }
                    }

                    // if one of the actions match, check that the NotActions don't
                    if (permissionMatch)
                    {
                        foreach (string notAction in permissions.notActions)
                        {
                            var notActionPattern = "^" + Regex.Escape(notAction.ToLower()).Replace("\\*", ".*") + "$";
                            if (Regex.IsMatch("microsoft.authorization/roleassignments/write", notActionPattern))
                            {
                                permissionMatch = false;
                            }

                            if (!permissionMatch)
                            {
                                break;
                            }
                        }
                    }

                    if (permissionMatch)
                    {
                        ret = true;
                        break;
                    }
                }
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }

            return ret;
        }

        public bool HasContributorAccess(string subscriptionId, string organizationId)
        {
            var ret = false;

            // Get capabilities uri
            var uri = BuildUri("https://management.azure.com/subscriptions/{0}/providers/microsoft.authorization/permissions?api-version={1}", subscriptionId, "2014-07-01-preview");

            // Create the HttpClient
            var client = CreateManagementClient(uri);

            // Invoke get request
            var response = client.GetAsync("").Result;

            if (response.IsSuccessStatusCode)
            {
                // Endpoint returns JSON with an array of Actions and NotActions
                // actions  notActions
                // -------  ----------
                // {*}      {Microsoft.Authorization/*/Write, Microsoft.Authorization/*/Delete}
                // {*/read} {}

                var responseContent = response.Content.ReadAsStringAsync().Result;
                var permissionsResult = (Json.Decode(responseContent)).value;

                foreach (var permissions in permissionsResult)
                {
                    var permissionMatch = false;

                    foreach (string action in permissions.actions)
                    {
                        if (action.Equals("*/contributor", StringComparison.CurrentCultureIgnoreCase) || action.Equals("*", StringComparison.CurrentCultureIgnoreCase))
                        {
                            {
                                permissionMatch = true;
                                break;
                            }
                        }
                    }

                    // if one of the actions match, check that the NotActions don't
                    if (permissionMatch)
                    {
                        foreach (string notAction in permissions.notActions)
                        {
                            if (notAction.Equals("*", StringComparison.CurrentCultureIgnoreCase) || notAction.EndsWith("/contributor", StringComparison.CurrentCultureIgnoreCase))
                            {
                                permissionMatch = false;
                                break;
                            }
                        }
                    }

                    if (permissionMatch)
                    {
                        ret = true;
                        break;
                    }
                }
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }

            return ret;
        }

        public void GrantContributorAccess(string servicePrincipleId, string subscriptionId, string organizationId)
        {
            // Create role assignment for application on the subscription
            var roleAssignmentId = Guid.NewGuid().ToString();
            var roleDefinitionId = GetRoleId("Contributor", subscriptionId, organizationId);

            var uri = BuildUri("https://management.azure.com/subscriptions/{0}/providers/microsoft.authorization/roleassignments/{1}?api-version={2}", subscriptionId, roleAssignmentId, "2014-10-01-preview");

            // Create the HttpClient
            var client = CreateManagementClient(uri);
            var content = new StringContent("{\"properties\": {\"roleDefinitionId\":\"" + roleDefinitionId + "\",\"principalId\":\"" + servicePrincipleId + "\"}}");

            content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            // Invoke get request
            var response = client.PutAsync(uri, content).Result;

            if (response.IsSuccessStatusCode)
            {

            }
        }

        public void RevokeContributorAccess(string servicePrincipleId, string subscriptionId, string organizationId)
        {

            // Create role assignment for application on the subscription
            var roleDefinitionId = GetRoleId("Contributor", subscriptionId, organizationId);

            var uri = BuildUri("https://management.azure.com/subscriptions/{0}/providers/microsoft.authorization/roleassignments?api-version={1}&$filter=principalId eq '{2}'", subscriptionId, "2014-10-01-preview", servicePrincipleId);

            // Create the HttpClient
            var client = CreateManagementClient(uri);
            var content = new StringContent("{\"properties\": {\"roleDefinitionId\":\"" + roleDefinitionId + "\",\"principalId\":\"" + servicePrincipleId + "\"}}");

            content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            // Invoke get request
            var response = client.GetAsync("").Result;

            if (response.IsSuccessStatusCode)
            {
                // Endpoint returns JSON with an array of role assignments
                // properties                                  id                                          type                                        name
                // ----------                                  --                                          ----                                        ----
                // @{roleDefinitionId=/subscriptions/e91d47... /subscriptions/e91d47c4-76f3-4271-a796-2... Microsoft.Authorization/roleAssignments     9db2cdc1-2971-42fe-bd21-c7c4ead4b1b8

                var responseContent = response.Content.ReadAsStringAsync().Result;
                var roleAssignmentsResult = (Json.Decode(responseContent)).value;

                //remove all role assignments
                foreach (var roleAssignment in roleAssignmentsResult)
                {
                    uri = BuildUri("https://management.azure.com/{0}?api-version={1}", roleAssignment.id, "2014-10-01-preview");

                    client = CreateManagementClient(uri);
                    var responseDelete = client.DeleteAsync(uri);
                }
            }
        }

        public string GetRoleId(string roleName, string subscriptionId, string organizationId)
        {
            string roleId = null;

            // Get capabilities uri
            var uri = BuildUri("https://management.azure.com/subscriptions/{0}/providers/Microsoft.Authorization/roleDefinitions?api-version={1}", subscriptionId, "2014-07-01-preview");

            // Create the HttpClient
            var client = CreateManagementClient(uri);

            // Invoke get request
            var response = client.GetAsync("").Result;

            if (response.IsSuccessStatusCode)
            {
                // Endpoint returns JSON with an array of roleDefinition Objects
                // properties                                  id                                          type                                        name
                // ----------                                  --                                          ----                                        ----
                // @{roleName=Contributor; type=BuiltInRole... /subscriptions/e91d47c4-76f3-4271-a796-2... Microsoft.Authorization/roleDefinitions     b24988ac-6180-42a0-ab88-20f7382dd24c
                // @{roleName=Owner; type=BuiltInRole; desc... /subscriptions/e91d47c4-76f3-4271-a796-2... Microsoft.Authorization/roleDefinitions     8e3af657-a8ff-443c-a75c-2fe8c4bcb635
                // @{roleName=Reader; type=BuiltInRole; des... /subscriptions/e91d47c4-76f3-4271-a796-2... Microsoft.Authorization/roleDefinitions     acdd72a7-3385-48ef-bd42-f606fba81ae7
                // ...

                var responseContent = response.Content.ReadAsStringAsync().Result;
                var roleDefinitionsResult = (Json.Decode(responseContent)).value;

                foreach (var roleDefinition in roleDefinitionsResult)
                {
                    if ((roleDefinition.properties.roleName as string).Equals(roleName, StringComparison.CurrentCultureIgnoreCase))
                    {
                        roleId = roleDefinition.id;
                        break;
                    }
                }
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }

            return roleId;
        }

        #endregion

        #region - Graph Utilities -

        public string GetOrganizationDisplayName(string organizationId)
        {
            string displayName = null;

            // Get a list of Organizations of which the user is a member
            var requestUrl = new Uri(string.Format("https://graph.windows.net/{0}/tenantDetails?api-version=1.5", organizationId));

            // Create the HttpClient
            var client = CreateManagementClient(requestUrl);

            // Invoke get request
            var response = client.GetAsync("").Result;

            // Endpoint returns JSON with an array of Tenant Objects
            if (response.IsSuccessStatusCode)
            {
                var responseContent = response.Content.ReadAsStringAsync().Result;
                var organizationPropertiesResult = (Json.Decode(responseContent)).value;

                if (organizationPropertiesResult != null && organizationPropertiesResult.Length > 0)
                {
                    displayName = organizationPropertiesResult[0].displayName;

                    if (organizationPropertiesResult[0].verifiedDomains != null)
                    {
                        foreach (var verifiedDomain in organizationPropertiesResult[0].verifiedDomains)
                        {
                            if (verifiedDomain["default"])
                            {
                                displayName += " (" + verifiedDomain.name + ")";
                            }
                        }
                    }
                }
            }

            return displayName;
        }

        public string GetServicePrincipal(string organizationId, string tenantId)
        {
            string objectId = null;

            // Get a list of Organizations of which the user is a member
            var requestUrl = new Uri(string.Format("https://graph.windows.net/{0}/servicePrincipals?api-version=1.5&$filter=appId eq '{1}'", organizationId, tenantId));

            // Create the HttpClient
            var client = CreateManagementClient(requestUrl);

            // Invoke get request
            var response = client.GetAsync("").Result;

            // Endpoint should return JSON with one or none serviePrincipal object
            if (response.IsSuccessStatusCode)
            {
                var responseContent = response.Content.ReadAsStringAsync().Result;
                var servicePrincipalResult = (Json.Decode(responseContent)).value;
                
                if (servicePrincipalResult != null && servicePrincipalResult.Length > 0)
                {
                    objectId = servicePrincipalResult[0].objectId;
                }
            }

            return objectId;
        }

        public string LookupDisplayNameOfAadObject(string organizationId, string servicePrincipleId)
        {
            string objectDisplayName = null;

            var requestUrl = new Uri(string.Format("https://graph.windows.net/{0}/directoryObjects/{1}?api-version=1.5", organizationId, servicePrincipleId));

            // Create the HttpClient
            var client = CreateManagementClient(requestUrl);

            // Invoke get request
            var response = client.GetAsync("").Result;

            if (response.IsSuccessStatusCode)
            {
                var responseContent = response.Content;
                var responseString = responseContent.ReadAsStringAsync().Result;
                var directoryObject = Json.Decode(responseString);

                if (directoryObject != null)
                {
                    objectDisplayName = string.Format("{0} ({1})", directoryObject.displayName, directoryObject.objectType);
                }
            }

            return objectDisplayName;
        }

        #endregion

        #region - Availability Utilities -

        public List<AzureLocation> GetLocations(int day, string subscriptionId)
        {
            // Clean cache of items older than 12 hours
            _cachedLocations.RemoveAll(c => c.CacheDate <= DateTime.Now.AddHours(-12));

            // Check cache for items
            var cacheItem = _cachedLocations.FirstOrDefault(c => c.SubscriptionId == subscriptionId);

            if (cacheItem == null)
            {
                // Add V12 locations for Subscription to Cache
                var allLocations = GetLocations(1);

                cacheItem = new CachedLocations()
                {
                    SubscriptionId = subscriptionId,
                    CacheDate = DateTime.Now,
                    Locations = FilterLocationsToV12Capable(allLocations, subscriptionId)
                };

                _cachedLocations.Add(cacheItem);
            }

            // Filter locations for the Day
            var availableLocationsForDay = GetLocations(day);

            return cacheItem.Locations.Where(l => availableLocationsForDay.Any(a => a.Equals(l.Name))).ToList();
        }

        private IEnumerable<string> GetLocations(int day)
        {
            // Day 2 Locations
            var locationNames = new List<string>()
            {
                "North Europe",
                "West US"
            };

            // Day 1 Locations
            if (day == 1)
            {
                locationNames.Add("West Europe");
                locationNames.Add("East US");
                locationNames.Add("East Asia");
                locationNames.Add("Southeast Asia");
            }

            return locationNames.OrderBy(l => l);
        }

        private List<AzureLocation> FilterLocationsToV12Capable(IEnumerable<string> locations, string subscriptionId)
        {
            var locationsWithV12Capabilities = new List<AzureLocation>();

            foreach (var location in locations)
            {
                // Get capabilities uri
                var uri = BuildUri("https://management.azure.com/subscriptions/{0}/providers/Microsoft.Sql/locations/{1}/capabilities?api-version=2014-04-01-preview", subscriptionId, location);

                // Create the HttpClient
                var client = CreateManagementClient(uri);

                // Invoke get request
                var response = client.GetAsync("").Result;

                if (response.IsSuccessStatusCode)
                {
                    // Read Json response
                    var dataObjects = response.Content.ReadAsStringAsync().Result;
                    dynamic data = Json.Decode(dataObjects);

                    // Build up capable locations
                    foreach (dynamic version in data.SupportedServerVersions)
                    {
                        if (version.Name.Equals("12.0"))
                        {
                            locationsWithV12Capabilities.Add(new AzureLocation()
                            {
                                Code = location,
                                Name = location
                            });
                        }
                    }
                }
                else
                {
                    Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
                }
            }

            return locationsWithV12Capabilities;
        }

        #endregion
    }
    
    #region - CachedLocations Class -

    public class CachedLocations
    {
        public string SubscriptionId { get; set; }
        public List<AzureLocation> Locations { get; set; }
        public DateTime CacheDate { get; set; }

        public CachedLocations()
        {
            Locations = new List<AzureLocation>();
        }
    }

    #endregion
}