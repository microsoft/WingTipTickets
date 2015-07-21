using System;

namespace Tenant.Mvc.Models.VenuesDB
{
    //Maps to 'Country' table in application database schema
    public class Country
    {
        public int CountryId { get; set; }
        public String CountryName { get; set; }
        public String Description { get; set; }
    }
}