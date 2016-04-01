using System;

namespace ElasticPoolLoadGenerator.Helpers
{
    public static class DatabaseHelper
    {
        #region - Public Methods -

        public static string ConstructConnectionString(string server, string database, string user, string password)
        {
            return String.Format("Server=tcp:{0};Database={1};User ID={2};Password={3};Trusted_Connection=False;", server, database, user, password);
        }

        public static string BuildInsertQuery()
        {
            // Build up the Customer
            var customerName = string.Format("Ticket ({0} of {1}) for user {2} to concert-{3}", 1, 1, ConfigHelper.CustomerName, ConfigHelper.ConcertId);

            //  Build the Insert Query
            return string.Format("INSERT INTO TICKETS (CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate) VALUES ({0}, '{1}', {2}, {3}, GETDATE())",
                                 ConfigHelper.CustomerId, 
                                 customerName, 
                                 ConfigHelper.TicketLevelId, 
                                 ConfigHelper.ConcertId);
        }

        public static string BuildBatchQuery(int batchSize, string rootQuery)
        {
            var batchQuery = string.Empty;

            for (var i = 0; i < batchSize; i++)
            {
                batchQuery += rootQuery + ";" + Environment.NewLine;
            }

            return batchQuery;
        }

        #endregion
    }
}