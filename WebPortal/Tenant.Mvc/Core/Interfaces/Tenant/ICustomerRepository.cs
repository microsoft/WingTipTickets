using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface ICustomerRepository : IBaseRepository
    {
        bool Login(string email, string password);
        bool CreateUser(string firstName, string lastName, string email, string phonenumber, string password);
        CustomerEventsModel GetCustomerEvents(CustomerModel customerModel, int? venueId = null);
    }
}