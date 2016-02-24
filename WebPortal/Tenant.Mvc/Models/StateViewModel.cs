using System;

namespace Tenant.Mvc.Models.ViewModels
{
    public class StateViewModel
    {
        public int StateId { get; set; }
        public String StateName { get; set; }
        public String Description { get; set; }
        public CountryViewModel Country { get; set; }
    }
}