using System.Collections.Generic;

namespace Tenant.Mvc.Models.RatingsDB
{
    public class VenueRating
    {
        public string id;
        public int concertId;
        public double avgScore;
        public int totalReviews;
        public SectionRating reviewsBySection;
    }

    public class SectionRating
    {
        public string section;
        public double avgScore;
        public int totalReviews;
        public List<Rating> recentReviews;
    }
}
