using System;
using System.Spatial;

namespace Tenant.Mvc.Core.Models
{
    public class CustomerModel
    {
        #region - Properties -

        public int CustomerId { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Email { get; set; }
        public decimal ContactNumber { get; set; }
        public String Password { get; set; }
        public String CreditCardNumber { get; set; }
        public Geography LastKnownLocation { get; set; }
        public String Address { get; set; }
        public CityModel CityModel { get; set; }
        public String Fax { get; set; }
        public string PhoneNumber { get; set; }

        #endregion
    }
}