using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using TenantProvisioning.Core.Models;

namespace TenantProvisioning.Core.Repositories
{
    class CreditCardRepository : BaseRepository
    {
        #region - Public Methods -

        public int Insert(int tenantId, CreateTenantModel.CreditCardModel domainModel)
        {
            // Build up the parameters
            var parameters = new List<SqlParameter>()
            {
                CreateParameter("@TenantId", SqlDbType.Int, tenantId),
                CreateParameter("@CardNumber", SqlDbType.VarChar, domainModel.CreditCardNumber),
                CreateParameter("@ExpirationDate", SqlDbType.VarChar, domainModel.ExpiryDate),
                CreateParameter("@CardVerificationValue", SqlDbType.VarChar, domainModel.CardVerificationValue),
            };

            // Run command
            return InsertData("Sp_Insert_CreditCard", parameters);
        }

        #endregion
    }
}
