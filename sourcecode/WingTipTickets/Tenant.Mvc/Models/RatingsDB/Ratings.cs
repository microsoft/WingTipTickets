namespace Tenant.Mvc.Models.RatingsDB
{
     public class Rating
    {
        public string id;
        public int concertId;
        public int venue;
        public int performer;
        public string section;
        public string seat;
        public int customerId;
        public string comment;
        public int score;
        public string date;
    }
}