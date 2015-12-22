using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Web.Helpers;
using Microsoft.Azure.Management.Resources;
using Microsoft.Azure.Management.Resources.Models;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Provisioners.Base;

namespace TenantProvisioning.Core.Provisioners.Shared
{
    public class SearchService : BaseProvisioner
    {
        #region - Constructors -

        public SearchService(int id, string position, int groupNo, bool waitForCompletion)
            : base(position, groupNo, waitForCompletion)
        {
            Id = id;
            Service = "Search Service";
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
                        ResourceType = "Microsoft.Search"
                    }).Result;

                    return result.Resources.Any(r => r.Name.Equals(Parameters.Tenant.SearchServiceName));
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
                    GetResourceProviders();
                    var resourceLocations = GetSearchDataCenterLocations();

                    var serviceLocation = resourceLocations.Contains(Parameters.Location("primary"))
                                              ? Parameters.Location("primary")
                                              : resourceLocations.First();

                    GetSearchServices(serviceLocation);

                    CreateSearchIndex(GetIndexJson());
                    CreateSearchIndexerDataSource(GetDataSourceJson());
                    CreateSearchIndexer(GetIndexerJson());
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

        private void GetResourceProviders()
        {
            // Get uri
            var uri = BuildUri("https://management.azure.com/subscriptions/{0}/providers?api-version=2015-01-01", Settings.AccountSubscriptionId);

            // Create the HttpClient
            var client = CreateManagementClient(uri);

            // Invoke get request
            var response = client.GetAsync("").Result;

            if (response.IsSuccessStatusCode)
            {
                // Read Xml response
                var dataObjects = response.Content.ReadAsStringAsync().Result;
                dynamic data = Json.Decode(dataObjects);

                foreach (var value in data.Value)
                {
                    if (value.Namespace.Equals("Microsoft.Search") && value.RegistrationState.Equals("NotRegistered"))
                    {
                        RegisterResourceProvider();
                    }
                }
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }
        }

        private void RegisterResourceProvider()
        {
            // Get uri
            var uri = BuildUri("https://management.azure.com/subscriptions/{0}/providers/Microsoft.Search/register?api-version=2015-01-01", Settings.AccountSubscriptionId);

            // Create the HttpClient
            var client = CreateManagementClient(uri);

            // Invoke get request
            var response = client.PostAsync(uri, null).Result;

            if (response.IsSuccessStatusCode)
            {
                // Read Xml response
                var dataObjects = response.Content.ReadAsStringAsync().Result;
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }
        }

        private void CreateSearchIndex(string jsonTemplate)
        {
            // Get uri
            var uri = BuildUri("https://{0}.search.windows.net/indexes?api-version=2015-02-28", Parameters.Tenant.SearchServiceName);

            // Create the HttpClient
            var client = CreateManagementClient(uri);
            client.DefaultRequestHeaders.Add("api-key", Parameters.Tenant.SearchServiceKey);
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            var content = new StringContent(jsonTemplate, Encoding.UTF8, "application/json");

            // Invoke get request
            var response = client.PostAsync(uri, content).Result;

            if (response.IsSuccessStatusCode)
            {
                // Read Xml response
                var dataObjects = response.Content.ReadAsStringAsync().Result;
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }
        }

        private void CreateSearchIndexerDataSource(string jsonTemplate)
        {
            // Get uri
            var uri = BuildUri("https://{0}.search.windows.net/datasources?api-version=2015-02-28", Parameters.Tenant.SearchServiceName);

            // Create the HttpClient
            var client = CreateManagementClient(uri);
            client.DefaultRequestHeaders.Add("api-key", Parameters.Tenant.SearchServiceKey);
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            var content = new StringContent(jsonTemplate, Encoding.UTF8, "application/json");

            // Invoke get request
            var response = client.PostAsync(uri, content).Result;

            if (response.IsSuccessStatusCode)
            {
                // Read Xml response
                var dataObjects = response.Content.ReadAsStringAsync().Result;
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }
        }

        private void CreateSearchIndexer(string jsonTemplate)
        {
            // Get locations uri
            var uri = BuildUri("https://{0}.search.windows.net/indexers?api-version=2015-02-28", Parameters.Tenant.SearchServiceName);

            // Create the HttpClient
            var client = CreateManagementClient(uri);
            client.DefaultRequestHeaders.Add("api-key", Parameters.Tenant.SearchServiceKey);
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            var content = new StringContent(jsonTemplate, Encoding.UTF8, "application/json");

            // Invoke get request
            var response = client.PostAsync(uri, content).Result;

            if (response.IsSuccessStatusCode)
            {
                // Read Xml response
                var dataObjects = response.Content.ReadAsStringAsync().Result;
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }
        }

        private void GetSearchServices(string location)
        {
            // Get uri
            var uri = BuildUri("https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Search/searchServices?api-version=2015-02-28", Settings.AccountSubscriptionId, Parameters.Tenant.SiteName);

            // Create the HttpClient
            var client = CreateManagementClient(uri);

            // Invoke get request
            var response = client.GetAsync("").Result;

            if (response.IsSuccessStatusCode)
            {
                // Read Xml response
                var dataObjects = response.Content.ReadAsStringAsync().Result;
                dynamic data = Json.Decode(dataObjects);

                bool found = false;
                foreach (dynamic service in data.Value)
                {
                    if (service.Name.Equals(Parameters.Tenant.SearchServiceName))
                    {
                        found = true;
                        GetManagementKey();
                    }
                }

                if (!found)
                {
                    CreateSearchService(location);
                    GetManagementKey();
                }
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }
        }

        private void CreateSearchService(string location)
        {
            // Get uri
            var uri = BuildUri("https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Search/searchServices/{2}?api-version=2015-02-28", Settings.AccountSubscriptionId, Parameters.Tenant.SiteName, Parameters.Tenant.SearchServiceName);

            // Create the HttpClient
            var client = CreateManagementClient(uri);
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            var json = ResourceHelper.ReadText(@"Tenant\Search\Create.json");
            json = json.Replace("@Location", location);

            var content = new StringContent(json, Encoding.UTF8, "application/json");

            // Invoke get request
            var response = client.PutAsync(uri, content).Result;

            if (response.IsSuccessStatusCode)
            {
                // Read Xml response
                var dataObjects = response.Content.ReadAsStringAsync().Result;
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }
        }


        private void GetManagementKey()
        {
            // Get uri
            var uri = BuildUri("https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.Search/searchServices/{2}/listAdminKeys?api-version=2015-02-28", Settings.AccountSubscriptionId, Parameters.Tenant.SiteName, Parameters.Tenant.SearchServiceName);

            // Create the HttpClient
            var client = CreateManagementClient(uri);

            // Invoke get request
            var response = client.PostAsync(uri, null).Result;

            if (response.IsSuccessStatusCode)
            {
                // Read Xml response
                var dataObjects = response.Content.ReadAsStringAsync().Result;
                dynamic data = Json.Decode(dataObjects);

                Parameters.Tenant.SearchServiceKey = data.PrimaryKey;
            }
            else
            {
                Console.WriteLine("{0} ({1})", (int)response.StatusCode, response.ReasonPhrase);
            }
        }

        private List<string> GetSearchDataCenterLocations()
        {
            var locations = new List<string>();
            
            // Get uri
            var uri = BuildUri("https://management.azure.com/providers/Microsoft.Search?api-version=2015-01-01");

            // Create the HttpClient
            var client = CreateManagementClient(uri);

            // Invoke get request
            var response = client.GetAsync("").Result;

            if (response.IsSuccessStatusCode)
            {
                // Read Xml response
                var dataObjects = response.Content.ReadAsStringAsync().Result;
                dynamic data = Json.Decode(dataObjects);

                foreach (var type in data.ResourceTypes)
                {
                    if (type.ResourceType.Equals("searchServices"))
                    {
                        foreach (var location in type.Locations)
                        {
                            locations.Add(location);
                        }

                        break;
                    }
                }
            }

            return locations;
        }

        private string GetIndexJson()
        {
            // Load the Template resource file
            var template = ResourceHelper.ReadText(@"Tenant\Search\Index.json");

            return template;
        }

        private string GetDataSourceJson()
        {
            // Load the Template resource file
            var template = ResourceHelper.ReadText(@"Tenant\Search\DataSource.json");

            // Replace the paramater values
            template = template.Replace("@ServerName", Parameters.GetSiteName("primary"));
            template = template.Replace("@DatabaseName", Parameters.Tenant.DatabaseName);
            template = template.Replace("@Username", Parameters.Tenant.UserName);
            template = template.Replace("@Password", Parameters.Tenant.Password);

            return template;
        }

        private string GetIndexerJson()
        {
            // Load the Template resource file
            var template = ResourceHelper.ReadText(@"Tenant\Search\Indexer.json");

            return template;
        }

        #endregion
    }
}
