namespace Tenant.Mvc.Models.ViewModels
{
    public class LookupViewModel
    {
        public int? Value { get; set; }
        public string Description { get; set; }

        public LookupViewModel(int? value, string description)
        {
            Value = value;
            Description = description;
        }
    }
}