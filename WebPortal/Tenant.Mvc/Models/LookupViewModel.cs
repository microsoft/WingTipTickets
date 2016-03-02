namespace Tenant.Mvc.Models
{
    public class LookupViewModel
    {
        #region - Properties -

        public int? Value { get; set; }
        public string Description { get; set; }

        #endregion

        #region - Constructors -

        public LookupViewModel(int? value, string description)
        {
            Value = value;
            Description = description;
        }

        #endregion
    }
}