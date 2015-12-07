using System;

namespace TenantProvisioning.Core.Models
{
    public class CreateTenantModel
    {
        public UserAccountModel UserAccount { get; set; }
        public TenantModel Tenant { get; set; }
        public CreditCardModel CreditCard { get; set; }

        public class UserAccountModel
        {
            public string Username { get; set; }
            public string Firstname { get; set; }
            public string Lastname { get; set; }
        }

        public class TenantModel
        {
            public int ThemeId { get; set; }
            public int ProvisioningOptionId { get; set; }
            public string DataCenter { get; set; }
            public string SiteName { get; set; }
            public string OrganizationId { get; set; }
            public string SubscriptionId { get; set; }
        }

        public class CreditCardModel
        {
            public string CreditCardNumber { get; set; }
            public string ExpiryDate { get; set; }
            public string CardVerificationValue { get; set; }
        }
    }
}