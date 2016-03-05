using System;
using Tenant.Mvc.Core.Enums;

namespace Tenant.Mvc.Core.Models
{
    /// <summary>
    /// Maps to 'Concert' table in application database schema
    /// </summary>
    public class ConcertModel
    {
        #region - Properties -

        public int ConcertId { get; set; }
        public int VenueId { get; set; }
        public int PerformerId { get; set; }
        public String ConcertName { get; set; }
        public String Description { get; set; }
        public DateTime ConcertDate { get; set; }
        public int Duration { get; set; }
        public VenueModel VenueModel { get; set; }
        public PerformerModel PerformerModel { get; set; }
        public ServerTargetEnum SaveToDbServer { get; set; }

        #endregion
    }
}