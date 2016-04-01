using System;
using System.Collections.Generic;
using System.Data.Entity.Core.EntityClient;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Tenant.Mvc.Core.Contexts
{
    public partial class WingTipTicketsEntities
    {
        #region - Constructors -

        public WingTipTicketsEntities(string connectionString)
            : base(GenerateConnectionString(connectionString))
        {
        }

        #endregion

        #region - Private Methods -

        private static string GenerateConnectionString(string connectionString)
        {
            // Create the connection string builder
            var sqlBuilder = new SqlConnectionStringBuilder(connectionString);

            // Build the connection string
            var providerString = sqlBuilder.ToString();

            // Initialize the connection string builder
            var entityBuilder = new EntityConnectionStringBuilder
            {
                ProviderConnectionString = providerString,
                Provider = "System.Data.SqlClient",
                Metadata = @"res://*/Core.Contexts.WingTipTicketModel.csdl|
							 res://*/Core.Contexts.WingTipTicketModel.ssdl|
							 res://*/Core.Contexts.WingTipTicketModel.msl"
            };

            return entityBuilder.ToString();
        }

        #endregion
    }
}