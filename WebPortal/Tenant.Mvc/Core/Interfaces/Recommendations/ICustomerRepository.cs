using System;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models.DomainModels;

namespace Tenant.Mvc.Core.Interfaces.Recommendations
{
    public interface ICustomerRepository
    {
        CustomerRec GetCustomerByName(string customer);
        CustomerRec GetCustomerById(Int64 id);
    }
}
