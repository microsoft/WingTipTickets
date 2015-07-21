using System;

namespace Tenant.Mvc.Models.VenuesDB
{
    //Maps to 'State' table in application database schema
    public class State
    {
        public int StateId { get; set; }
        public String StateName { get; set; }
        public String Description { get; set; }
        public Country Country { get; set; }
    }
}