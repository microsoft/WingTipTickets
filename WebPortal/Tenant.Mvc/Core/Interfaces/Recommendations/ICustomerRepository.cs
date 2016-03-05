using System;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Interfaces.Recommendations
{
    public interface ICustomerRepository
    {
        CustomerRec GetCustomerByName(string customer);
        CustomerRec GetCustomerById(Int64 id);
    }
}
