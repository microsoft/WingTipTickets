using System.Collections.Generic;
using Microsoft.Azure.Management.TrafficManager.Models;

namespace TenantProvisioning.Core.Models
{
    public class ProvisioningParameters
    {
        #region - Properties -

        public Tenant Tenant;
        public Properties Properties;

        #endregion

        #region - Constructors -

        public ProvisioningParameters()
        {
            Tenant = new Tenant();
            Properties = new Properties();
        }

        #endregion

        #region - Public Methods -

        public string GetSiteName(string position)
        {
            return Tenant.SiteName + position;
        }

        public string FarmName(string position)
        {
            return Tenant.SiteName + position + "farm";
        }

        public string Location(string position)
        {
            return position.Equals(string.Empty) || position.Equals("primary") ? Properties.LocationPrimary : Properties.LocationSecondary;
        }

        #endregion
    }

    #region - Class Tenant -

    public class Tenant
    {
        public int TenantId { get; set; }
        public string SiteName { get; set; }
        public string Theme { get; set; }
        public string DatabaseName { get; set; }
        public string SqlVersion { get; set; }
        public string UserName { get; set; }
        public string Password { get; set; }
        public string StoragePrimaryKey { get; set; }
        public string SearchServiceKey { get; set; }
        public string DocumentDbKey { get; set; }

        public string SearchServiceName
        {
            get
            {
                return SiteName.Substring(0, 15);
            }
        }
    }

    #endregion

    #region - Class Properties -

    public class Properties
    {
        public Properties()
        {
            Components = new List<AzureComponent>();
            EndPoints = new List<Endpoint>();
            V12Locations = new List<string>();
        }

        public string TargetUsername { get; set; }
        public string TargetSubscription { get; set; }
        public string TargetTenant { get; set; }
        public bool ResourceGroupExists { get; set; }
        public bool IsRunningFromAdminInterface { get; set; }
        public string LocationPrimary { get; set; }
        public string LocationSecondary { get; set; }
        public List<AzureComponent> Components { get; set; }
        public List<Endpoint> EndPoints { get; set; }
        public List<string> V12Locations { get; set; }
        public bool DeployData { get; set; }
        public bool HasDatabaseSchema { get; set; }
        public bool HasDatabaseViews { get; set; }
        public string DatabaseSchema { get; set; }
        public string DatabaseViews { get; set; }
        public string DatabaseInformation { get; set; }
        public byte[] WebSitePackage { get; set; }
        public string WebSitePackageName { get; set; }
    }

    #endregion
}