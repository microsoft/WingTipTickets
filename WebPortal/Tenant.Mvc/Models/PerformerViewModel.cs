using System;

namespace Tenant.Mvc.Models.ViewModels
{
    public class PerformerViewModel
    {
        public int PerformerId { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Skills { get; set; }
        public Decimal ContactNbr { get; set; }
        public String ShortName { get; set; }
    }
}