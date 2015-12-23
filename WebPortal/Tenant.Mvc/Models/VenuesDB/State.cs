using System;

namespace Tenant.Mvc.Models.VenuesDB
{
    /// <summary>
    /// Maps to 'State' table in application database schema
    /// </summary>
    public class State
    {
        #region - Properties -

        public int StateId { get; set; }
        public String StateName { get; set; }
        public String Description { get; set; }
        public Country Country { get; set; }

        #endregion
    }
}