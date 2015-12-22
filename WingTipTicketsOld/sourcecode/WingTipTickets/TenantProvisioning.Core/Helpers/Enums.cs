namespace TenantProvisioning.Core.Helpers
{
    public class ProvisioningStatus
    {
        public const string Queued = "Queued";
        public const string CheckingExistence = "Checking Existence";
        public const string NotDeployed = "Not Deployed";
        public const string Provisioning = "Provisioning";
        public const string Deployed = "Deployed";
        public const string Removing = "Removing";
        public const string Removed = "Removed";
        public const string Failed = "Failed";
        public const string Warning = "Warning";
    }

    public class RoleNames
    {
        public const string None = "None";
        public const string Administrator = "Administrator";
        public const string Tenant = "Tenant";
    }

    public class Provisioner
    {
        public const string Shared_ResourceGroup = "Shared_ResourceGroup";       
        public const string Shared_SqlServerSchema = "Shared_SqlServerSchema";
        public const string Shared_SqlServerPopulate = "Shared_SqlServerPopulate";
        public const string Shared_WebHostingPlan = "Shared_WebHostingPlan";
        public const string Shared_Website = "Shared_Website";
        public const string Shared_TrafficManager = "Shared_TrafficManager";
        public const string Shared_SqlAuditing = "Shared_SqlAuditing";
        public const string Shared_DocumentDb = "Shared_DocumentDb";
        public const string Shared_SearchService = "Shared_SearchService";

        // Day 1 Components
        public const string Day1_StorageAccount = "Day1_StorageAccount";
        public const string Day1_SqlServer = "Day1_SqlServer";
        public const string Day1_WebsiteDeployment = "Day1_WebsiteDeployment";

        // Day 2 Components
        public const string Day2_StorageAccount = "Day2_StorageAccount";
        public const string Day2_SqlServer = "Day2_SqlServer";
        public const string Day2_DataFactory = "Day2_DataFactory";
        public const string Day2_WebsiteDeployment = "Day2_WebsiteDeployment";
    }
}