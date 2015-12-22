using System.Data;

namespace TenantProvisioning.Core.Repositories
{
    class ThemeRepository : BaseRepository
    {
        #region - Public Methods -

        public DataTable FetchAll()
        {
            // Run command
            var dataset = FetchAllData("[Theme]");

            return GetFirstDataSetTable(dataset);
        }

        #endregion
    }
}
