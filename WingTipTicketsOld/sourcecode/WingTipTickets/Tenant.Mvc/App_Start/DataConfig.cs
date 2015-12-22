using System.Diagnostics;
using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Azure.Search;
using Microsoft.Azure.Search.Models;
using WingTipTickets;

namespace Tenant.Mvc
{
    public class DataConfig
    {
        public static void Configure()
        {
            var searchServiceClient = new SearchServiceClient(WingtipTicketApp.Config.SearchServiceName,
                                                              new SearchCredentials(WingtipTicketApp.Config.SearchServiceKey));

            // CreateIndex(searchServiceClient);
            // CreateIndexer(searchServiceClient);
            //searchServiceClient.Indexers.Run("fromsql");

            WingtipTicketApp.SearchIndexClient = searchServiceClient.Indexes.GetClient("concerts");
        }

        private static void CreateIndex(SearchServiceClient searchServiceClient)
        {
            if (!searchServiceClient.Indexes.Exists("concerts"))
            {
                searchServiceClient.Indexes.Create(new Index
                {
                    Name = "concerts",
                    Fields = new List<Field>
                        {
                            new Field { Name = "ConcertId", Type = DataType.String, IsKey = true, IsFilterable = true, IsRetrievable = true },
                            new Field { Name = "ConcertName", Type = DataType.String, IsRetrievable = true },
                            new Field { Name = "ConcertDate", Type = DataType.DateTimeOffset, IsFilterable = true, IsFacetable = true, IsSortable = true, IsRetrievable = true },
                            new Field { Name = "VenueId", Type = DataType.Int32, IsFilterable = true, IsRetrievable = true },
                            new Field { Name = "VenueName", Type = DataType.String, IsFilterable = true, IsFacetable = true },
                            new Field { Name = "VenueCity", Type = DataType.String, IsFilterable = true, IsFacetable = true },
                            new Field { Name = "VenueState", Type = DataType.String, IsFilterable = true, IsFacetable = true },
                            new Field { Name = "VenueCountry", Type = DataType.String, IsFilterable = true, IsFacetable = true },
                            new Field { Name = "PerformerId", Type = DataType.Int32, IsFilterable = true, IsRetrievable = true },
                            new Field { Name = "PeformerName", Type = DataType.String, IsFilterable = true, IsFacetable = true },
                            new Field { Name = "FullTitle", Type = DataType.String, IsRetrievable = true, IsSearchable = true }
                        },
                    Suggesters = new List<Suggester>
                        {
                            new Suggester
                            {
                                Name = "sg",
                                SearchMode = SuggesterSearchMode.AnalyzingInfixMatching,
                                SourceFields = { "FullTitle" }
                            }
                        }
                });
            }
        }

        private static void CreateIndexer(SearchServiceClient searchServiceClient)
        {
            if (!searchServiceClient.DataSources.List().Any(d => d.Name == "concertssql"))
            {
                int test2 = searchServiceClient.DataSources.List().Count();
                Debug.WriteLine(test2);
                bool test3 = searchServiceClient.DataSources.List().Any(d => d.Name == "concertssql");
                Debug.WriteLine(test3);
                string connectionString = WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer,
                                                                               WingtipTicketApp.Config.TenantDbName);
                searchServiceClient.DataSources.CreateOrUpdate(new DataSource
                {
                    Name = "concertssql",
                    Type = "azuresql",
                    Container = new DataContainer { Name = "ConcertSearch" },
                    Credentials = new DataSourceCredentials { ConnectionString = connectionString },
                    DataChangeDetectionPolicy = new HighWaterMarkChangeDetectionPolicy("RowVersion")
                });
            }

            if (!searchServiceClient.Indexers.List().Any(i => i.Name == "fromsql"))
            {
                searchServiceClient.Indexers.CreateOrUpdate(new Indexer
                {
                    Name = "fromsql",
                    DataSourceName = "concertssql",
                    TargetIndexName = "concerts",
                    Schedule = new IndexingSchedule { Interval = TimeSpan.FromMinutes(5), StartTime = DateTimeOffset.Now }
                });
            }
        }
    }
}
