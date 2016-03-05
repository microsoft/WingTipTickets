using System;

namespace Tenant.Mvc.Core.Models
{
    /// <summary>
    /// Maps to 'State' table in application database schema
    /// </summary>
    public class StateModel
    {
        #region - Properties -

        public int StateId { get; set; }
        public String StateName { get; set; }
        public String Description { get; set; }
        public Country Country { get; set; }

        #endregion
    }
}