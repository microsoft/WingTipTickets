using System.Collections.Generic;

namespace Tenant.Mvc.Models.RatingsDB
{
    public class SectionRating
    {
        #region - Properties -

        public string Section { get; set; }
        public double AvgScore { get; set; }
        public int TotalReviews { get; set; }
        public List<Rating> RecentReviews { get; set; }

        #endregion
    }
}