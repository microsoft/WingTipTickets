using System;
namespace Promotions.Repositories
{
    public interface ICustomerRepository
    {
        Customer GetCustomerByName(string customer);
        Customer GetCustomerById(Int64 id);
    }
}
