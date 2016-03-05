using System.Data.SqlClient;

namespace Tenant.Mvc.Core.Helpers
{
    public static class SqlDataReaderExtensions
    {
        public static string GetString(this SqlDataReader reader, string fieldName)
        {
            var ordinal = reader.GetOrdinal(fieldName);

            return !reader.IsDBNull(ordinal) ? reader.GetString(ordinal) : string.Empty;
        }
    }
}