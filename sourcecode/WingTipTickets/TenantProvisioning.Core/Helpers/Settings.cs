using System;
using System.Configuration;
using System.Linq;
using System.Security.Claims;
using System.Xml.Linq;
using TenantProvisioning.Core.Models;
using TenantProvisioning.Core.Services;

namespace TenantProvisioning.Core.Helpers
{
    public static class Settings
    {
        // Global
        public static XNamespace Namespace = "http://schemas.microsoft.com/windowsazure";

        #region - Provisioner Properties -

        public static string ProvisionerTenantId
        {
            get
            {
                // Get from the Claims Principle
                return ConfigurationManager.AppSettings["Provisioner_TenantId"];
            }
        }

        public static string ProvisionerClient
        {
            get
            {
                return ConfigurationManager.AppSettings["Provisioner_ClientID"];
            }
        }

        public static string ProvisionerPassword
        {
            get
            {
                return ConfigurationManager.AppSettings["Provisioner_Password"];
            }
        }

        #endregion

        #region - Application Properties -

        public static string ConnectionString
        {
            get
            {
                return ConfigurationManager.ConnectionStrings["ProvisionSiteDb"].ToString();
            }
        }

        public static string LoginUri
        {
            get
            {
                return ConfigurationManager.AppSettings["LoginUri"];
            }
        }

        public static string ApiEndpointUri
        {
            get
            {
                return ConfigurationManager.AppSettings["ApiEndpointUri"];
            }
        }

        public static string ApiVersion
        {
            get
            {
                return ConfigurationManager.AppSettings["ApiVersion"];
            }
        }

        public static string RedirectUri
        {
            get
            {
                return ConfigurationManager.AppSettings["RedirectUri"];
            }
        }

        #endregion

        #region - Account Properties -

        public static string AccountSubscriptionId
        {
            get
            {
                // First, Try from Database if Tenant
                if (ClaimsPrincipal.Current.IsInRole(RoleNames.Tenant))
                {
                    var tenant = GetDay1Tenant();

                    if (tenant != null && tenant.SubscriptionId != null)
                    {
                        return tenant.SubscriptionId;
                    }
                }
                else if (ClaimsPrincipal.Current.IsInRole(RoleNames.Administrator))
                {
                    return AccountOrganizationId;
                }

                throw new Exception("No Subscriptions found for User!");
            }
        }

        public static string AccountOrganizationId
        {
            get
            {
                // Get from the Claims Principle
                return ClaimsPrincipal.Current.FindFirst("http://schemas.microsoft.com/identity/claims/tenantid").Value;
            }
        }

        #endregion

        #region - Tenant Properties -

        public static string TenantDbName
        {
            get
            {
                return ConfigurationManager.AppSettings["Tenant_DbName"];
            }
        }

        public static string TenantDbUsername
        {
            get
            {
                return ConfigurationManager.AppSettings["Tenant_DbUsername"];
            }
        }

        public static string TenantDbPassword
        {
            get
            {
                return ConfigurationManager.AppSettings["Tenant_DbPassword"];
            }
        }

        public static string TenantDbVersion
        {
            get
            {
                return ConfigurationManager.AppSettings["Tenant_DbVersion"];
            }
        }

        #endregion

        #region - ProductRecommendation Properties -

        public static string ProductRecommendationsDbName
        {
            get
            {
                return ConfigurationManager.AppSettings["ProductRecommendations_DbName"];
            }
        }

        public static string ProductRecommendationsDbUsername
        {
            get
            {
                return ConfigurationManager.AppSettings["ProductRecommendations_DbUsername"];
            }
        }

        public static string ProductRecommendationsDbPassword
        {
            get
            {
                return ConfigurationManager.AppSettings["ProductRecommendations_DbPassword"];
            }
        }

        public static string ProductRecommendationsDbVersion
        {
            get
            {
                return ConfigurationManager.AppSettings["ProductRecommendations_DbVersion"];
            }
        }

        #endregion

        #region - Private Methods -

        private static TenantModel GetDay1Tenant()
        {
            var tenantService = new TenantService();
            var tenants = tenantService.FetchByUsername(ClaimsPrincipal.Current.Identity.SplitName());

            return tenants.First(t => t.ProvisioningOptionCode.Equals("S1"));
        }

        #endregion
    }
}
