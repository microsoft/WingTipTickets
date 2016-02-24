using System;
using System.Data.SqlClient;
using System.Linq;
using System.Threading;
using Microsoft.Azure.Management.Sql;
using Microsoft.Azure.Management.Sql.Models;
using TenantProvisioning.Core.Provisioners.Base;

namespace TenantProvisioning.Core.Provisioners.Shared
{
    public class SqlSchemaDeployment : BaseProvisioner
    {
        #region - Constructors -

        public SqlSchemaDeployment(int id, string position, int groupNo, bool waitForCompletion)
            : base(position, groupNo, waitForCompletion)
        {
            Id = id;
            Service = "Database Schema";
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
                if (!CheckExistence())
                {
                    CreateDatabase();

                    DeploySchema();

                    Parameters.Properties.DeployData = true;
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

        private void CreateDatabase()
        {
            // Deploy Database
            using (var client = new SqlManagementClient(GetCredentials()))
            {
                // Create database
                var createResult = client.Databases.CreateOrUpdateAsync(
                    Parameters.Tenant.SiteName,
                    Parameters.GetSiteName(Position),
                    Parameters.Tenant.DatabaseName,
                    new DatabaseCreateOrUpdateParameters()
                    {
                        Location = Parameters.Location(Position),
                        Properties =
                            new DatabaseCreateOrUpdateProperties()
                    }).Result;
            }
        }

        private void DeploySchema()
        {
            // Give database some to to catch up
            Thread.Sleep(30000);

            // Update Schema
            var connectionString = BuildConnectionString(Parameters.Tenant.DatabaseName);

            var sqlConnection = new SqlConnection(connectionString);
            var sqlCommand = new SqlCommand("", sqlConnection);

            sqlConnection.Open();

            if (Parameters.Properties.HasDatabaseSchema)
            {
                sqlCommand.CommandText = Parameters.Properties.DatabaseSchema;
                sqlCommand.ExecuteNonQuery();
            }

            if (Parameters.Properties.HasDatabaseViews)
            {
                sqlCommand.CommandText = Parameters.Properties.DatabaseViews;
                sqlCommand.ExecuteNonQuery();
            }

            sqlConnection.Close();
        }

        #endregion
    }
}
