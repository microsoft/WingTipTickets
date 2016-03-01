using System;
using System.ComponentModel.DataAnnotations;
using System.Web.Mvc;
using Newtonsoft.Json;

namespace Tenant.Mvc.Models
{
    public class FindSeatsViewModel
    {
        public ConcertViewModel Concert { get; set; }
        public PurchaseViewModel Purchase { get; set; }
        public VenueMetaDataViewModel VenueMetaData { get; set; }

        public SelectList SeatSections { get; set; }
        public SelectList TicketQuantities { get; set; }
        public SelectList ExpirationMonths { get; set; }
        public SelectList ExpirationYears { get; set; }

        public class ConcertViewModel
        {
            public int ConcertId { get; set; }
            public String ConcertName { get; set; }
            public DateTime ConcertDate { get; set; }

            public int VenueId { get; set; }
            public string VenueName { get; set; }

            [Required]
            public int Quantity { get; set; }

            [Required]
            public int SeatSectionId { get; set; }

            public string PerformerName { get; set; }
        }

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

        public class VenueMetaDataViewModel
        {
            #region - Properties -

            [Display(Name = "Id")]
            [Required]
            [JsonProperty(PropertyName = "venueId")]
            public int VenueId { get; set; }

            public dynamic Data { get; set; }

            #endregion
        }
    }
}