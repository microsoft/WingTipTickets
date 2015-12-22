using System;
using System.Data.SqlClient;
using System.Linq;
using Microsoft.Azure.Management.Sql;
using TenantProvisioning.Core.Provisioners.Base;

namespace TenantProvisioning.Core.Provisioners.Shared
{
    public class SqlSchemaPopulator : BaseProvisioner
    {
        #region - Constructors -

        public SqlSchemaPopulator(int id, string position, int groupNo, bool waitForCompletion)
            : base(position, groupNo, waitForCompletion)
        {
            Id = id;
            Service = "Database Population";
        }

        #endregion

        #region - Overidden Methods -

        protected override bool CheckExistence()
        {
            if (Parameters.Properties.ResourceGroupExists)
            {
                using (var client = new SqlManagementClient(GetCredentials()))
                {
                    var serverList = client.Servers.ListAsync(Parameters.Tenant.SiteName).Result;
                    var server = serverList.Servers.FirstOrDefault(s => s.Name.Equals(Parameters.GetSiteName(Position)));

                    if (server != null)
                    {
                        var databaseList = client.Databases.ListAsync(Parameters.Tenant.SiteName, Parameters.GetSiteName(Position)).Result;
                        return databaseList.Databases.Any(database => database.Name.Equals(Parameters.Tenant.DatabaseName));
                    }
                }
            }

            return false;
        }

        protected override bool CreateOrUpdate()
        {
            var created = true;

            try
            {
                // Skip if exists
                if (!CheckExistence() && Parameters.Properties.DeployData)
                {
                    PopulateData();
                }
            }
            catch (Exception ex)
            {
                created = false;
                Message = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
            }

            return created;
        }

        #endregion

        #region - Private Methods -

        private void PopulateData()
        {
            // Populate Data
            var connectionString = BuildConnectionString(Parameters.Tenant.DatabaseName);

            var sqlConnection = new SqlConnection(connectionString);
            var sqlCommand = new SqlCommand("", sqlConnection);

            sqlConnection.Open();

            sqlCommand.CommandText = Parameters.Properties.DatabaseInformation;
            sqlCommand.CommandTimeout = 600000;
            sqlCommand.ExecuteNonQuery();

            sqlConnection.Close();
        }

        #endregion
    }
}
