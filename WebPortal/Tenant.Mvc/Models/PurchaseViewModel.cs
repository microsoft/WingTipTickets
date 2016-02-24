using System.ComponentModel.DataAnnotations;

namespace Tenant.Mvc.Models.ViewModels
{
    public class PurchaseViewModel
    {
        [Required]
        public int ConcertId { get; set; }

        [Required]
        public int Quantity { get; set; }

        [Required]
        public int SeatSectionId { get; set; }

        public string CardHolder { get; set; }
        public string CardNumber { get; set; }
        public int? CardExpirationMonth { get; set; }
        public int? CardExpirationYear { get; set; }
    }
}