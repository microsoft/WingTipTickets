using System;
using Tenant.Mvc.Core.Contexts;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class BaseRepository
    {
        #region - Properties -

        public DatabaseContext Context { get; set; }
        public Action<string> StatusCallback { get; set; }

        #endregion

        #region - Constructors -

        public BaseRepository()
        {
            Context = new DatabaseContext();
        }

        #endregion

        #region - Protected Methods -

        protected void UpdateStatus(string message)
        {
            if (StatusCallback != null)
            {
                StatusCallback(message);
            }
        }

        #endregion
    }
}