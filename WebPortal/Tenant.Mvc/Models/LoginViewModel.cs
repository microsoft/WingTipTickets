using System.ComponentModel.DataAnnotations;

namespace Tenant.Mvc.Core.Models
{
    public class LoginViewModel
    {
        [Required]
        [Display(Name = "User name")]
        public string UserName { get; set; }
    }
}