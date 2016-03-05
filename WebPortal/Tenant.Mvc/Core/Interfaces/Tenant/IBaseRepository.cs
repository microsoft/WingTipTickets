using System;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface IBaseRepository
    {
        Action<string> StatusCallback { get; set; }
    }
}