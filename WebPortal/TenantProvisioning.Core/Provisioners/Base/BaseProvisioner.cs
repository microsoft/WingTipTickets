using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Threading;
using Microsoft.Azure;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Models;

namespace TenantProvisioning.Core.Provisioners.Base
{
    public abstract class BaseProvisioner
    {
        #region - Fields -

        private ProvisioningParameters _parameters;

        #endregion

        #region - Properties -

        public int Id { get; set; }
        public string Name { get; set; }
        public string Status { get; set; }
        public string Service { get; set; }
        public string Message { get; set; }
        public string Position { get; set; }
        public int GroupNo { get; set; }
        public bool WaitForCompletion { get; set; }
        public bool RollbackRequired { get; set; }

        public ProvisioningParameters Parameters
        {
            get
            {
                return _parameters;
            }
            set
            {
                _parameters = value;

                Name = Service.Equals("Search Service") ? _parameters.GetSiteName(Position).Substring(0, 15) : _parameters.GetSiteName(Position);
            }
        }

        #endregion

        #region - Constructors -

        protected BaseProvisioner(string position, int groupNo = 1, bool waitForCompletion = true)
        {
            Position = position;
            GroupNo = groupNo;
            WaitForCompletion = waitForCompletion;
        }

        #endregion

        #region - Public Methods -

        public bool RunCapabilityCheck()
        {
            Message = "";
            Status = "Checking Capability";

            Thread.Sleep(500);

            var capable = CheckCapability();

            Status = capable ? "Capable" : "Rolling Back";
            Message = capable ? "Attempt Next Automatic Location" : "";

            return capable;
        }

        public bool RunExistenceCheck()
        {
            Message = "";
            Status = "Checking Existence";

            Thread.Sleep(500);

            var exists = CheckExistence();

            if (!Status.Equals("Error"))
            {
                Status = exists ? "Deployed" : "Not Deployed";
            }

            return exists;
        }

        public bool RunCreateOrUpdate()
        {
            Message = "";
            Status = "Deploying";

            Thread.Sleep(500);
            var deployed = CreateOrUpdate();

            Status = deployed ? "Deployed" : "Error";

            return deployed;
        }

        public bool RunRemove(string reason = "")
        {
            Message = reason;
            Status = "Removing";

            Thread.Sleep(500);
            var removed = Remove();

            Status = removed ? "Removed" : "Error";

            return removed;
        }

        #endregion

        #region - Virtual Methods -

        protected virtual bool CheckCapability()
        {
            return true;
        }

        protected virtual bool CheckExistence()
        {
            return Parameters.Properties.ResourceGroupExists;
        }

        protected virtual bool CreateOrUpdate()
        {
            return true;
        }

        protected virtual bool Remove()
        {
            return true;
        }

        #endregion

        #region - Protected Methods -

        protected string BuildConnectionString(string databaseName)
        {
            const string format = "Server=tcp:{0}.database.windows.net; Database={1};User ID={2};Password={3};Trusted_Connection=False;Encrypt=True;";

            return string.Format(format, Parameters.GetSiteName(Position), databaseName, Parameters.Tenant.UserName, Parameters.Tenant.Password);
        }

        protected static Uri BuildUri(string format, params object[] values)
        {
            return new Uri(String.Format(format, values));
        }

        protected TokenCloudCredentials GetCredentials()
        {
            string username;
            string subscriptionId;
            string tenantId;

            // Get Username, Subscription and TenantId
            if (Parameters.Properties.IsRunningFromAdminInterface)
            {
                username =  Parameters.Properties.TargetUsername;
                subscriptionId = Parameters.Properties.TargetSubscription;
                tenantId = Parameters.Properties.TargetTenant;
            }
            else
            {
                username = ClaimsPrincipal.Current.Identity.SplitName();
                subscriptionId = Settings.AccountSubscriptionId;
                tenantId = Settings.AccountOrganizationId;
            }

            // Get auth token and cloud credentials
            var token = GetAuthorizationToken(Settings.ApiEndpointUri, tenantId, username);
            var credentials = new TokenCloudCredentials(subscriptionId, token);

            return credentials;
        }

        protected static string GetAuthorizationToken(string endpoint, string tenantId, string username)
        {
            var clientCredentials = new ClientCredential(Settings.ProvisionerClient, Settings.ProvisionerPassword);

            var context = new AuthenticationContext(string.Format(Settings.LoginUri, tenantId), new AdalTokenCache(username));

            var result = context.AcquireTokenSilent(endpoint, clientCredentials, new UserIdentifier(username, UserIdentifierType.RequiredDisplayableId));

            if (result == null)
            {
                throw new InvalidOperationException("Failed to obtain the JWT token");
            }

            return result.AccessToken;
        }

        protected HttpClient CreateManagementClient(Uri uri)
        {
            return CreateClient(Settings.ApiEndpointUri, uri);
        }

        protected HttpClient CreateGraphClient(Uri uri)
        {
            return CreateClient("https://graph.windows.net/", uri);
        }

        private static HttpClient CreateClient(string authority, Uri uri)
        {
            var username = ClaimsPrincipal.Current.Identity.SplitName();

            var client = new HttpClient
            {
                BaseAddress = new Uri(uri.ToString()),
            };

            // Set headers
            client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("bearer", GetAuthorizationToken(authority, Settings.AccountOrganizationId, username));
            client.DefaultRequestHeaders.Add("x-ms-Version", Settings.ApiVersion);

            return client;
        }

        #endregion
    }
}