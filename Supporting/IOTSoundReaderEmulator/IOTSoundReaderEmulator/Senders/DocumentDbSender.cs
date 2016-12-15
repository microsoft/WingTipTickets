using System;
using System.Linq;
using System.Threading.Tasks;
using IOTSoundReaderEmulator.Interfaces;
using IOTSoundReaderEmulator.Models;
using Microsoft.Azure.Documents;
using Microsoft.Azure.Documents.Client;

namespace IOTSoundReaderEmulator.Senders
{
    public class DocumentDbSender : ISender
    {
        #region - Fields -

        private DocumentClient _documentClient;

        #endregion

        #region - Public Methods -

        public async void SendInfo(SoundRecord soundRecord)
        {
            Uri endpointUri = new Uri(CloudConfiguration.DocumentDbUri);
            string authorizationKey = CloudConfiguration.DocumentDbKey;

            _documentClient = new DocumentClient(endpointUri, authorizationKey);

            var collection = await GetDocumentCollection();

            try
            {
                Console.WriteLine("{0} > Sending message to Document DB: {1}", DateTime.Now, soundRecord);
                var result = await _documentClient.CreateDocumentAsync(collection.SelfLink, soundRecord);
            }
            catch (Exception exception)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("{0} > Exception: {1}", DateTime.Now, exception.Message);
                Console.ResetColor();
            }
        }

        #endregion

        #region - Private Methods -

        private async Task<DocumentCollection> GetDocumentCollection()
        {
            string collectionName = CloudConfiguration.DocumentDbCollectionName;

            var database = await GetDatabase();
            var documentCollection = _documentClient.CreateDocumentCollectionQuery(database.SelfLink)
                .Where(c => c.Id == collectionName)
                .AsEnumerable()
                .FirstOrDefault();

            // If the document collection does not exist, create a new collection
            if (documentCollection == null)
            {
                documentCollection =
                    await _documentClient.CreateDocumentCollectionAsync("dbs/" + database.Id, new DocumentCollection
                    {
                        Id = collectionName
                    });
            }

            return documentCollection;
        }

        private async Task<Database> GetDatabase()
        {
            string databaseName = CloudConfiguration.DocumentDbDatabaseName;

            var database = _documentClient.CreateDatabaseQuery().Where(db => db.Id == databaseName).AsEnumerable().FirstOrDefault();

            // If the database does not exist, create a new database
            if (database == null)
            {
                database = await _documentClient.CreateDatabaseAsync(new Database
                {
                    Id = databaseName
                });
            }

            return database;
        }

        #endregion
    }
}
