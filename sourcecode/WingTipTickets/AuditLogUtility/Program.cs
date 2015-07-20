using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Auth;
using Microsoft.WindowsAzure.Storage.Table;
namespace AuditLogUtility
{
    class Program
    {
        static int Main(string[] args)
        {
            if ((args == null) || (args.Length < 2))
            {
                Console.WriteLine("Need 'StorageAccountName' and 'StorageAccountKey'");
                return -1;
            }
            int hours = 0;
            if (args.Length > 2)
            {
                hours = Int32.Parse(args[2]);
            }
            DeleteTableRows(args[0], args[1], hours);

            return 0;
        }

        static void DeleteTableRows(String storageAccountName, String storageAccountKey, int hours)
        {
            try 
            {

                String storageConnectionString = String.Format("DefaultEndpointsProtocol=https;AccountName={0};AccountKey={1}",
                                                        storageAccountName, storageAccountKey);
                CloudStorageAccount storageAccount = CloudStorageAccount.Parse(storageConnectionString);

                CloudTableClient tableClient = storageAccount.CreateCloudTableClient();
                String storageTableName = "SQLDBAuditLogs20140928";
                var existingTable = tableClient.GetTableReference(storageTableName);
                DateTime timeStampFilter = DateTime.UtcNow.AddHours((-1)*hours);
                TableQuery query = new TableQuery();
                query.FilterString = string.Format("Timestamp lt datetime'{0:yyyy-MM-ddTHH:mm:ss}'", timeStampFilter);

                Console.WriteLine(String.Format("Querying the AzureStorage '{0}' with filter '{1}'...", storageTableName, query.FilterString));
                Console.WriteLine(" ..This query takes long time to complete, please wait...");
                var items = existingTable.ExecuteQuery(query).ToList();
                int totalItems = items.Count;
                Console.WriteLine(String.Format("  There are '{0}' records to delete...", totalItems));
                Dictionary<string, TableBatchOperation> batches = new Dictionary<string, TableBatchOperation>();

                int count = 1;
                int previousCount = count;
                foreach (var entity in items)
                {
                    TableOperation tableOperation = TableOperation.Delete(entity);

                    // need a new batch?
                    if (!batches.ContainsKey(entity.PartitionKey))
                        batches.Add(entity.PartitionKey, new TableBatchOperation());

                    if (batches[entity.PartitionKey].Count < 100)
                        batches[entity.PartitionKey].Add(tableOperation);
                    else
                    {
                        Console.WriteLine("Deleting rows '{0} to {1}' of '{2}'", previousCount, count, totalItems);
                        DeleteStorageTableRows(existingTable, batches);
                        batches = new Dictionary<string, TableBatchOperation>();
                        previousCount = count;
                    }

                    count++;
                }
                //Delete any leftovers
                DeleteStorageTableRows(existingTable, batches);

            }
            catch (Exception ex)
            {
                Console.WriteLine(string.Format("Delete exception {0}", ex), "Error");
            }
         }

        private static void DeleteStorageTableRows(CloudTable table, Dictionary<string, TableBatchOperation> batches)
        {
            foreach (var batch in batches.Values)
                table.ExecuteBatch(batch);
        }
    }
}
