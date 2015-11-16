using Microsoft.Azure.Documents;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace Tenant.Mvc.Models.VenuesDB
{
    public class VenueMetaData
    {
        [Display(Name = "Id")]
        [Required]
        [JsonProperty(PropertyName = "venueId")]
        public int VenueId { get; set; }

        public dynamic Data { get; set; }
    }
}