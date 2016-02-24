using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Azure.Documents;
using Microsoft.Azure.Documents.Client;
using Microsoft.Azure.Documents.Linq;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;
using WingTipTickets;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class VenueMetaDataRepository : BaseRepository, IVenueMetaDataRepository
    {
        #region - Fields -

        private readonly DocumentClient _documentClient;

        #endregion

        #region - Properties -

        private Uri EndpointUri { get; set; }
        private string AuthorizationKey { get; set; }

        #endregion

        #region - Constructors -

        public VenueMetaDataRepository()
            : this(WingtipTicketApp.Config.DocumentDbUri, WingtipTicketApp.Config.DocumentDbKey)
        {
        }

        public VenueMetaDataRepository(string endpointUri, string authorizationKey)
        {
            EndpointUri = new Uri(endpointUri);
            AuthorizationKey = authorizationKey;

            _documentClient = new DocumentClient(EndpointUri, AuthorizationKey);
        }

        #endregion

        #region - Public Methods -

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

        #endregion

        #region - Private Methods -

        private async Task<Database> GetDatabase()
        {
            const string databaseName = "VenueMetaData";

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

        private async Task<DocumentCollection> GetDocumentCollection()
        {
            const string collectionName = "VenueMetaDataCollection";

            var database = await GetDatabase();
            var documentCollection = _documentClient.CreateDocumentCollectionQuery(database.SelfLink).Where(c => c.Id == collectionName).AsEnumerable().FirstOrDefault();

            // If the document collection does not exist, create a new collection
            if (documentCollection == null)
            {
                documentCollection = await _documentClient.CreateDocumentCollectionAsync("dbs/" + database.Id, new DocumentCollection
                {
                    Id = collectionName
                });
            }

            return documentCollection;
        }

        #endregion
    }
}