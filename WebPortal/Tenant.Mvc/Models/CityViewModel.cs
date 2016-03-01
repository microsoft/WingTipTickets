using System;
using Tenant.Mvc.Models.ViewModels;

namespace Tenant.Mvc.Models
{
    public class CityViewModel
    {
        public int CityId { get; set; }
        public String CityName { get; set; }
        public String Description { get; set; }
        public StateViewModel State { get; set; }
    }
}