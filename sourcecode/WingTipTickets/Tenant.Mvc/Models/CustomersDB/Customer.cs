using System;
using System.Spatial;
using Tenant.Mvc.Models.VenuesDB;

namespace Tenant.Mvc.Models.CustomersDB
{
    public class Customer
    {
        public int CustomerId { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Email { get; set; }
        public decimal ContactNumber { get; set; }
        public String Password { get; set; }    //TODO: Make this secret
        public String CreditCardNumber { get; set; }
        public Geography LastKnownLocation { get; set; }
        public String Address { get; set; }
        public City City { get; set; }
        public String Fax { get; set; }
        public string PhoneNumber { get; set; }
    }
}