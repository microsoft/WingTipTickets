using System;
using System.ComponentModel.DataAnnotations;

namespace Tenant.Mvc.Models.ViewModels
{
    public class ConcertViewModel
    {
        // New
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
        // Old
        
        //public int VenueId { get; set; }
        //public int PerformerId { get; set; }
        
        //public String Description { get; set; }
        //public DateTime ConcertDate { get; set; }
        //public int Duration { get; set; }
        //public VenueViewModel Venue { get; set; }
        //public PerformerViewModel Performer { get; set; }
        //public ShardDbServerTargetEnum SaveToDbServer { get; set; }
    }
}