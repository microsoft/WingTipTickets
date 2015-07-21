using System;

namespace Tenant.Mvc.Models.VenuesDB
{
    //Maps to 'City' table in application database schema
    public class City
    {
        public int CityId { get; set; }
        public String CityName { get; set; }
        public String Description {get; set; }
        public State State {get; set; }
    }
}