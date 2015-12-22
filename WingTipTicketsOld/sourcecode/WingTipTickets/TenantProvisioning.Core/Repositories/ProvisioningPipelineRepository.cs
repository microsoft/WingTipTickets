using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using TenantProvisioning.Core.Models;

namespace TenantProvisioning.Core.Repositories
{
    class ProvisioningPipelineRepository : BaseRepository
    {
        #region - Public Methods -

        public List<ProvisioningPipelineTask> FetchPipelineTasks(int provisioningOptionId)
        {
            // Build up the parameters
            var parameters = new List<SqlParameter>()
            {
                CreateParameter("@ProvisioningOptionId", SqlDbType.Int, provisioningOptionId)
            };

            var dataSet = FetchFilteredData("Sp_Fetch_ProvisioningPipelineTasks", parameters);

            // Check if any data
            if (dataSet.Tables.Count <= 0 || dataSet.Tables[0].Rows.Count <= 0)
            {
                return null;
            }

            // Get the First Table
            var datatable = GetFirstDataSetTable(dataSet);

            // Return rows
            var domainModel =
                (
                    from DataRow tenant in datatable.Rows
                    select new ProvisioningPipelineTask()
                    {
                        Id = Cast<int>(tenant["ProvisioningPipelineId"]),
                        Position = tenant["Position"].ToString(),
                        SequenceNo = Cast<int>(tenant["SequenceNo"]),
                        GroupNo = Cast<int>(tenant["GroupNo"]),
                        TaskCode = tenant["TaskCode"].ToString(),
                        TaskDescription = tenant["TaskDescription"].ToString(),
                        WaitForCompletion =  Cast<bool>(tenant["WaitForCompletion"]),
                    }
                ).ToList();

            return domainModel;
        }

        #endregion
    }
}
