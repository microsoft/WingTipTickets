using System;

namespace Tenant.Mvc.Models.ConcertsDB
{
    //Maps to 'Performer' table in application database schema
    public class Performer
    {
        public int PerformerId { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Skills { get; set; }
        public Decimal ContactNbr { get; set; }
        public String ShortName { get; set; }
    }
}