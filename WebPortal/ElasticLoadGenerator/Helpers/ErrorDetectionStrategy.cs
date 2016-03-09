using System;
using System.Data.SqlClient;
using Microsoft.Practices.EnterpriseLibrary.TransientFaultHandling;

namespace ElasticLoadGenerator.Helpers
{
    public class ErrorDetectionStrategy : ITransientErrorDetectionStrategy
    {
        #region - Public Methods -

        public bool IsTransient(Exception ex)
        {
            return ex is SqlException;
        }

        #endregion
    }
}