using Newtonsoft.Json;
using System.ComponentModel.DataAnnotations;

namespace Tenant.Mvc.Models.VenuesDB
{
    public class VenueMetaData
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