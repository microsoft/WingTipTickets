using System.Web.Mvc;

namespace Tenant.Mvc
{
    public class FilterConfig
    {
        #region - Public Methods -

        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
            filters.Add(new HandleErrorAttribute());
        }

        #endregion
    }
}
