using System;
using System.Linq;
using Microsoft.Azure.Documents;
using Microsoft.Azure.Documents.Client;
using Microsoft.Azure.Documents.Linq;
using WingTipTickets;
using Tenant.Mvc.Models.VenuesDB;
using System.Threading.Tasks;

namespace Tenant.Mvc.Repositories
{
    public class VenueMetaDataRepository
    {
        private Uri EndpointUri { get; set; }
        private string AuthorizationKey { get; set; }

        private readonly DocumentClient _documentClient;

        public VenueMetaDataRepository() : this(
            WingtipTicketApp.Config.DocumentDbServiceEndpointUri,
            WingtipTicketApp.Config.DocumentDbServiceAuthorizationKey)
        {
        }

        public VenueMetaDataRepository(string endpointUri, string authorizationKey)
        {
            EndpointUri = new Uri(endpointUri);
            AuthorizationKey = authorizationKey;
            _documentClient = new DocumentClient(EndpointUri, AuthorizationKey);
        }

        private async Task<Database> GetDatabase()
        {
            var databaseName = "VenueMetaData";

            Database database = _documentClient.CreateDatabaseQuery().Where(db => db.Id == databaseName).AsEnumerable().FirstOrDefault();

            // If the database does not exist, create a new database
            if (database == null)
            {
                database = await _documentClient.CreateDatabaseAsync(
                    new Database
                    {
                        Id = databaseName
                    });
            }
            return database;
        }

        private async Task<DocumentCollection> GetDocumentCollection()
        {
            var collectionName = "VenueMetaDataCollection";

            var database = await GetDatabase();

            DocumentCollection documentCollection = _documentClient.CreateDocumentCollectionQuery(database.SelfLink).Where(c => c.Id == collectionName).AsEnumerable().FirstOrDefault();

            // If the document collection does not exist, create a new collection
            if (documentCollection == null)
            {
                documentCollection = await _documentClient.CreateDocumentCollectionAsync("dbs/" + database.Id,
                    new DocumentCollection
                    {
                        Id = collectionName
                    });
            }

            return documentCollection;
        }


        public async Task<VenueMetaData> GetVenueMetaData(int venueId)
        {
            var collection = await GetDocumentCollection();

            var venueMetaData = _documentClient.CreateDocumentQuery<VenueMetaData>(collection.SelfLink).Where(d => d.VenueId == venueId).AsEnumerable().LastOrDefault();
            
            return venueMetaData;
        }

        public async Task SetVenueMetaData(int venueId, dynamic metaData)
        {
            var collection = await GetDocumentCollection();

            var venueMetaData = new VenueMetaData();
            venueMetaData.VenueId = venueId;
            venueMetaData.Data = metaData;

            var response = await _documentClient.CreateDocumentAsync(collection.SelfLink, venueMetaData);
        }
    }
}