using System.Data;

namespace TenantProvisioning.Core.Repositories
{
    class ProvisioningOptionRepository : BaseRepository
    {
        #region - Public Methods -

        public DataTable FetchAll()
        {
            // Run command
            var dataset = FetchAllData("[ProvisioningOption]");

            return GetFirstDataSetTable(dataset);
        }

        #endregion
    }
}
