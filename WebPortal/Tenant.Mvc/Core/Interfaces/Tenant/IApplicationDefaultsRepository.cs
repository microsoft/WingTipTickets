namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface IApplicationDefaultsRepository : IBaseRepository
    {
        string GetApplicationDefault(string code);
        void SetApplicationDefault(string code, string value);
    }
}
