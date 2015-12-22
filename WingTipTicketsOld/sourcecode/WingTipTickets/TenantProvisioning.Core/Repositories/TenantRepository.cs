using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using TenantProvisioning.Core.Models;

namespace TenantProvisioning.Core.Repositories
{
    class TenantRepository : BaseRepository
    {
        #region - Public Methods -

        public TenantModel FetchById(int tenantId)
        {
            // Build up the parameters
            var parameters = new List<SqlParameter>()
            {
                CreateParameter("@TenantId", SqlDbType.Int, tenantId)
            };

            var dataSet = FetchFilteredData("Sp_Fetch_Tenant_ById", parameters);

            // Check if any data
            if (dataSet.Tables.Count <= 0 || dataSet.Tables[0].Rows.Count <= 0)
            {
                return null;
            }

            // Return the first row
            var tenant = dataSet.Tables[0].Rows[0];

            var domainModel = new TenantModel()
            {
                TenantId = Cast<int>(tenant["TenantId"]),
                ProvisioningOptionId = Cast<int?>(tenant["ProvisioningOptionId"]),
                ThemeId = Cast<int?>(tenant["ThemeId"]),
                SiteName = tenant["SiteName"].ToString(),
                DataCenter = tenant["DataCenter"].ToString(),
                AzureServicesProvisioned = Cast<bool>(tenant["AzureServicesProvisioned"]),

                ProvisioningOption = tenant["ProvisioningOption"].ToString(),
                ProvisioningOptionCode = tenant["ProvisioningOptionCode"].ToString(),
                Theme = tenant["Theme"].ToString(),
                ThemeCode = tenant["ThemeCode"].ToString(),

                OrganizationId = tenant["OrganizationId"].ToString(),
                SubscriptionId = tenant["SubscriptionId"].ToString(),
                Username = tenant["Username"].ToString(),
            };

            return domainModel;
        }

        public List<TenantModel> FetchByUsername(string username)
        {
            // Build up the parameters
            var parameters = new List<SqlParameter>()
            {
                CreateParameter("@Username", SqlDbType.VarChar, username)
            };

            var dataSet = FetchFilteredData("Sp_Fetch_Tenants_ByUsername", parameters);

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
                    select new TenantModel()
                    {
                        TenantId = Cast<int>(tenant["TenantId"]),
                        ProvisioningOptionId = Cast<int?>(tenant["ProvisioningOptionId"]),
                        ThemeId = Cast<int?>(tenant["ThemeId"]),
                        SiteName = tenant["SiteName"].ToString(),
                        DataCenter = tenant["DataCenter"].ToString(),
                        AzureServicesProvisioned = Cast<bool>(tenant["AzureServicesProvisioned"]),

                        ProvisioningOption = tenant["ProvisioningOption"].ToString(),
                        ProvisioningOptionCode = tenant["ProvisioningOptionCode"].ToString(),
                        Theme = tenant["Theme"].ToString(),
                        ThemeCode = tenant["ThemeCode"].ToString(),

                        OrganizationId = tenant["OrganizationId"].ToString(),
                        SubscriptionId = tenant["SubscriptionId"].ToString(),
                    }
                ).ToList();

            return domainModel;
        }

        public List<TenantModel> FetchAll()
        {
            // Build up the parameters
            var parameters = new List<SqlParameter>();
            var dataSet = FetchFilteredData("Sp_Fetch_Tenants", parameters);

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
                    select new TenantModel()
                    {
                        TenantId = Cast<int>(tenant["TenantId"]),
                        ProvisioningOptionId = Cast<int>(tenant["ProvisioningOptionId"]),
                        ThemeId = Cast<int>(tenant["ThemeId"]),
                        SiteName = tenant["SiteName"].ToString(),
                        DataCenter = tenant["DataCenter"].ToString(),
                        AzureServicesProvisioned = Cast<bool>(tenant["AzureServicesProvisioned"]),

                        ProvisioningOption = tenant["ProvisioningOption"].ToString(),
                        ProvisioningOptionCode = tenant["ProvisioningOptionCode"].ToString(),
                        Theme = tenant["Theme"].ToString(),
                        Username = tenant["Username"].ToString()
                    }
                ).ToList();

            return domainModel;
        }

        public int Create(int userAccountId, CreateTenantModel.TenantModel domainModel)
        {
            // Build up the parameters
            var parameters = new List<SqlParameter>()
            {
                CreateParameter("@UserAccountId", SqlDbType.Int, userAccountId),
                CreateParameter("@ProvisioningOptionId", SqlDbType.VarChar, domainModel.ProvisioningOptionId),
                CreateParameter("@ThemeId", SqlDbType.VarChar, domainModel.ThemeId),
                CreateParameter("@SiteName", SqlDbType.VarChar, domainModel.SiteName),
                CreateParameter("@DataCenter", SqlDbType.VarChar, domainModel.DataCenter),
                CreateParameter("@OrganizationId", SqlDbType.VarChar, domainModel.OrganizationId),
                CreateParameter("@SubscriptionId", SqlDbType.VarChar, domainModel.SubscriptionId)
            };

            // Run command
            return InsertData("Sp_Insert_Tenant", parameters);
        }

        public int SetProvisioningStatus(int tenantId, bool azureServicesProvisioned)
        {
            // Build up the parameters
            var parameters = new List<SqlParameter>()
            {
                CreateParameter("@TenantId", SqlDbType.Int, tenantId),
                CreateParameter("@AzureServicesProvisioned", SqlDbType.Bit, azureServicesProvisioned),
            };

            // Run command
            return UpdateData("Sp_Update_Tenant_AzureServicesProvisioned", parameters);
        }

        public int Delete(string username)
        {
            // Build up the parameters
            var parameters = new List<SqlParameter>()
            {
                CreateParameter("@Username", SqlDbType.VarChar, username),
            };

            // Run command
            return UpdateData("Sp_Delete_Tenant", parameters);
        }

        #endregion
    }
}
