using System;

namespace Tenant.Mvc.Models.VenuesDB
{
    /// <summary>
    /// Maps to 'City' table in application database schema
    /// </summary>
    public class City
    {
        #region - Properties -

        public int CityId { get; set; }
        public String CityName { get; set; }
        public String Description { get; set; }
        public State State { get; set; }

        #endregion
    }
}