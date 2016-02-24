using System;

namespace Tenant.Mvc.Models.ViewModels
{
    public class CityViewModel
    {
        public int CityId { get; set; }
        public String CityName { get; set; }
        public String Description { get; set; }
        public StateViewModel State { get; set; }
    }
}