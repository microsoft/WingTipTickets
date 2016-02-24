using System.ComponentModel.DataAnnotations;
using Newtonsoft.Json;

namespace Tenant.Mvc.Core.Models
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