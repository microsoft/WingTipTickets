using System;

namespace Tenant.Mvc.Core.Models
{
    /// <summary>
    /// Maps to 'City' table in application database schema
    /// </summary>
    public class CityModel
    {
        #region - Properties -

        public int CityId { get; set; }
        public String CityName { get; set; }
        public String Description { get; set; }
        public StateModel StateModel { get; set; }

        #endregion
    }
}