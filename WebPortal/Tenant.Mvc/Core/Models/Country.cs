using System;

namespace Tenant.Mvc.Core.Models
{
    /// <summary>
    /// Maps to 'Country' table in application database schema
    /// </summary>
    public class Country
    {
        #region - Properties -

        public int CountryId { get; set; }
        public String CountryName { get; set; }
        public String Description { get; set; }

        #endregion
    }
}