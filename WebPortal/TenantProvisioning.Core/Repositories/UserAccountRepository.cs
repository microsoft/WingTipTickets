using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using TenantProvisioning.Core.Models;

namespace TenantProvisioning.Core.Repositories
{
    class UserAccountRepository : BaseRepository
    {
        #region - Public Methods -

        public UserAccountModel Fetch(string username)
        {
            // Build up the parameters
            var parameters = new List<SqlParameter>()
            {
                CreateParameter("@Username", SqlDbType.VarChar, username)
            };

            // Run command
            var dataSet = FetchFilteredData("Sp_Fetch_UserAccount", parameters);

            // Check if any data
            if (dataSet.Tables.Count <= 0 || dataSet.Tables[0].Rows.Count <= 0)
            {
                return null;
            }

            // Return the first row
            var user = dataSet.Tables[0].Rows[0];
            var domainModel = new UserAccountModel()
            {
                UserAccountId = Cast<int>(user["UserAccountId"]),
                FirstName = user["Firstname"].ToString(),
                LastName = user["Lastname"].ToString(),
                Username = user["Username"].ToString(),
                Password = user["Password"].ToString(),
                CachedData = Cast<byte[]>(user["CachedData"]),
                UpdateDate = Cast<DateTime>(user["UpdateDate"]),
            };

            return domainModel;
        }

        public int Insert(CreateUserAccountModel domainModel)
        {
            // Build up the parameters
            var parameters = new List<SqlParameter>()
            {
                CreateParameter("@Firstname", SqlDbType.VarChar, domainModel.Firstname),
                CreateParameter("@Lastname", SqlDbType.VarChar, domainModel.Lastname),
                CreateParameter("@Username", SqlDbType.VarChar, domainModel.Username),
                CreateParameter("@CachedData", SqlDbType.VarBinary, domainModel.CachedData),
                CreateParameter("@UpdateDate", SqlDbType.DateTime, domainModel.UpdateDate),
            };

            // Run command
            return InsertData("Sp_Insert_UserAccount", parameters);
        }

        public int UpdatePesonalDetails(string username, string firstname, string lastname)
        {
            // Build up the parameters
            var parameters = new List<SqlParameter>()
            {
                CreateParameter("@Username", SqlDbType.VarChar, username),
                CreateParameter("@Firstname", SqlDbType.VarChar, firstname),
                CreateParameter("@Lastname", SqlDbType.VarChar, lastname)
            };

            // Run command
            return InsertData("Sp_Update_UserAccount", parameters);
        }

        public int UpdateCacheData(UserAccountModel domainModel)
        {
            // Build up the parameters
            var parameters = new List<SqlParameter>()
            {
                CreateParameter("@Username", SqlDbType.VarChar, domainModel.Username),
                CreateParameter("@CachedData", SqlDbType.VarBinary, domainModel.CachedData),
                CreateParameter("@UpdateDate", SqlDbType.DateTime, domainModel.UpdateDate)
            };

            // Run command
            return InsertData("Sp_Update_UserAccount_CacheData", parameters);
        }

        #endregion
    }
}
