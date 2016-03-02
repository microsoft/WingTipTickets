using System;
using Tenant.Mvc.Models.VenuesDB;

namespace Tenant.Mvc.Models.ConcertsDB
{
    /// <summary>
    /// Maps to 'Concert' table in application database schema
    /// </summary>
    public class Concert
    {
        #region - Properties -

        public int ConcertId { get; set; }
        public int VenueId { get; set; }
        public int PerformerId { get; set; }
        public String ConcertName { get; set; }
        public String Description { get; set; }
        public DateTime ConcertDate { get; set; }
        public int Duration { get; set; }
        public Venue Venue { get; set; }
        public Performer Performer { get; set; }
        public ShardDbServerTargetEnum SaveToDbServer { get; set; }

        #endregion
    }
}