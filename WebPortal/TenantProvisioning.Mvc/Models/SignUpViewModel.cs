using System.ComponentModel.DataAnnotations;

namespace TenantProvisioning.Mvc.Models
{
    public class SignUpViewModel
    {
        [Required]
        [MaxLength(150)]
        [Display(Name = "Firstname")]
        public string FirstName { get; set; }

        [Required]
        [MaxLength(150)]
        [Display(Name = "Lastname")]
        public string LastName { get; set; }

        [Required]
        [Display(Name = "Theme")]
        public int ThemeId { get; set; }

        [Required]
        [Display(Name = "Site Name")]
        public string SiteName { get; set; }

        [Display(Name = "Data Center (Day1)")]
        public string Day1DataCenter { get; set; }

        [Display(Name = "Data Center (Day2)")]
        public string Day2DataCenter { get; set; }

        [MaxLength(20)]
        [Display(Name = "Credit Card Number")]
        public string CreditCardNumber { get; set; }

        [MaxLength(20)]
        [Display(Name = "Expiry Date")]
        public string ExpiryDate { get; set; }

        [MaxLength(3)]
        [Display(Name = "CVV")]
        public string CardVerificationValue { get; set; }

        [Required]
        [Display(Name = "Subscription")]
        public string SubscriptionId { get; set; }

        public string ProvisioningOptionTitle { get; set; }
    }
}