using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Windows.Documents;
using ElasticPoolLoadGenerator.Models;

namespace ElasticPoolLoadGenerator.Helpers
{
    public static class DatabaseHelper
    {
        #region - Public Methods -

        public static string ConstructConnectionString(string server, string database, string user, string password)
        {
            return String.Format("Server=tcp:{0};Database={1};User ID={2};Password={3};Trusted_Connection=False;", server, database, user, password);
        }

        public static DataTable BuildBatchData(int batchSize)
        {
            // Build up the Customer
            var customerName = string.Format("Ticket ({0} of {1}) for user {2} to concert-{3}", 1, 1, ConfigHelper.CustomerName, ConfigHelper.ConcertId);

            // Create the Table
            var table = new DataTable();

            table.Columns.Add("CustomerId", typeof(int));
            table.Columns.Add("Name", typeof(string));
            table.Columns.Add("TicketLevelId", typeof(int));
            table.Columns.Add("ConcertId", typeof(int));
            table.Columns.Add("PurchaseDate", typeof(DateTime));
            table.Columns.Add("SeatNumber", typeof(int));

            // Add the batch rows
            for (var i = 0; i < batchSize; i++)
            {
                table.Rows.Add(ConfigHelper.CustomerId, customerName, ConfigHelper.TicketLevelId, ConfigHelper.ConcertId, DateTime.Now, -1);
            }

            return table;
        }

        public static string BuildInsertQuery()
        {
            // Build up the Customer
            var customerName = string.Format("Ticket ({0} of {1}) for user {2} to concert-{3}", 1, 1, ConfigHelper.CustomerName, ConfigHelper.ConcertId);

            //  Build the Insert Query
            return string.Format("INSERT INTO TICKETS (CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate, SeatNumber) VALUES ({0}, '{1}', {2}, {3}, GETDATE(), {4})",
                                 ConfigHelper.CustomerId, 
                                 customerName, 
                                 ConfigHelper.TicketLevelId, 
                                 ConfigHelper.ConcertId,
                                 -1);
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

        public static List<LookupViewModel> GetConcerts(string connectionString)
        {
            // Build up the Concert Query
            const string query = "SELECT Id = ConcertId, Description = ConcertName + ' (' + V.VenueName + ')' FROM Concerts C JOIN Venues V ON V.VenueId = C.VenueId";

            return GetLookupData(query, connectionString);
        }

        public static List<LookupViewModel> GetTicketLevels(string connectionString, int concertId)
        {
            // Build up the TicketLevel Query
            string query = "SELECT Id = TicketLevelId, Description = Description FROM TicketLevels WHERE ConcertId = " + concertId;

            return GetLookupData(query, connectionString);
        }

        public static List<LookupViewModel> GetCustomers(string connectionString)
        {
            // Build up the Customer Query
            const string query = "SELECT Id = CustomerId, Description = Firstname + ' ' + LastName FROM Customers";

            return GetLookupData(query, connectionString);
        }

        #endregion

        #region - Private Methods -

        private static List<LookupViewModel> GetLookupData(string query, string connectionString)
        {
            var lookups = new List<LookupViewModel>();

            var connection = new SqlConnection(connectionString);
            var dataset = new DataSet();
            var reader = new SqlDataAdapter(query, connection);

            reader.Fill(dataset);

            if (dataset.Tables.Count > 0 && dataset.Tables[0].Rows.Count > 0)
            {
                lookups.AddRange(
                    from DataRow row in dataset.Tables[0].Rows
                    select new LookupViewModel()
                    {
                        Id = Convert.ToInt32(row["Id"]), 
                        Description = row["Description"].ToString()
                    });
            }

            return lookups;
        }

        #endregion
    }
}