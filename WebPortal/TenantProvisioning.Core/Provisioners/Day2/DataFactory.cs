using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Microsoft.Azure.Management.DataFactories;
using Microsoft.Azure.Management.DataFactories.Common.Models;
using Microsoft.Azure.Management.DataFactories.Models;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Provisioners.Base;

namespace TenantProvisioning.Core.Provisioners.Day2
{
    public class DataFactory111 : BaseProvisioner
    {
        #region - Fields -

        private readonly DateTime _pipelineStartDate;
        private readonly DateTime _pipelineEndDate;

        #endregion

        #region - Constructors -

        public DataFactory111(int id, string position, int groupNo, bool waitForCompletion)
            : base(position, groupNo, waitForCompletion)
        {
            Id = id;
            Service = "Data Factory";

            _pipelineEndDate = Convert.ToDateTime(DateTime.Now.ToUniversalTime().ToString("yyyy-MM-01T00:00:00Z"));
            _pipelineStartDate = Convert.ToDateTime(_pipelineEndDate.AddDays(-365).ToString("yyyy-MM-01T00:00:00Z"));
        }

        #endregion

        #region - Overidden Methods -

        protected override bool CheckExistence()
        {
            var found = false;

            if (Parameters.Properties.ResourceGroupExists)
            {
                using (var client = new DataFactoryManagementClient(GetCredentials()))
                {
                    var result = client.DataFactories.ListAsync(Parameters.Tenant.SiteName).Result;

                    found =  result.DataFactories.Any(d => d.Name.Equals(Parameters.Tenant.SiteName));
                }
            }

            return found;
        }

        protected override bool CreateOrUpdate()
        {
            var created = true;

            try
            {
                using (var client = new DataFactoryManagementClient(GetCredentials()))
                {
                    // Create Containers
                    CreateProductRecommendations();

                    // Skip if exists
                    if (!CheckExistence())
                    {
                        // Setup DataFactory Parameters
                        var parameters = new DataFactoryCreateOrUpdateParameters()
                        {
                            DataFactory = new DataFactory()
                            {
                                Location = Parameters.Properties.LocationPrimary,
                                Name = Parameters.Tenant.SiteName
                            }
                        };

                        // Create DataFactory
                        var res1 = client.DataFactories.CreateOrUpdateAsync(Parameters.Tenant.SiteName, parameters).Result;

                        // Upload Resources
                        UploadScripts();
                        UploadJars();
                        UploadPackages();
                    }

                    // Create Linked Services
                    CreateLinkedService_Sql(client);
                    CreateLinkedService_Storage(client);
                    CreateLinkedService_HdInsight(client);

                    // Create DataSets
                    CreateDataSet_RawProductsUsage(client);
                    CreateDataSet_ProductsSimilaritySql(client);
                    CreateDataSet_ProductsSimilarityOutput(client);
                    CreateDataSet_ProductsSimilarity(client);
                    CreateDataSet_ProductsRecommendationSql(client);
                    CreateDataSet_ProductsRecommendationOutput(client);
                    CreateDataSet_ProductsRecommendation(client);
                    CreateDataSet_PartitionedProductsUsage(client);
                    CreateDataSet_MahoutInputProductsUsage(client);

                    // Create Pipelines
                    CreatePipeline_ProductsSimilarityMahout(client);
                    CreatePipeline_ProductsRecommenderMahout(client);
                    CreatePipeline_PrepareSampleData(client);
                    CreatePipeline_PrepareMahoutUsage(client);
                    CreatePipeline_PartitionProductUsage(client);
                    CreatePipeline_MapSimilarProducts(client);
                    CreatePipeline_MapRecommendedProducts(client);
                    CreatePipeline_EgressSimilarProductsSql(client);
                    CreatePipeline_EgressRecommendedProductsSql(client);
                }
            }
            catch (Exception ex)
            {
                created = false;
                Message = ex.InnerException != null ? ex.InnerException.Message : ex.Message;
            }

            return created;
        }

        #endregion

        #region - Upload Methods -

        private CloudBlobContainer CreateContainer(string containerName)
        {
            // Retrieve storage account
            var storageAccount = CloudStorageAccount.Parse(string.Format("DefaultEndpointsProtocol=https;AccountName={0};AccountKey={1}", Parameters.Tenant.SiteName, Parameters.Tenant.StoragePrimaryKey));

            // Create the blob client
            var blobClient = storageAccount.CreateCloudBlobClient();

            // Retrieve container reference
            var container = blobClient.GetContainerReference(containerName);

            // Create container if it doesn't already exist
            container.CreateIfNotExists();

            // Set permissions
            container.SetPermissions(
            new BlobContainerPermissions
            {
                PublicAccess = BlobContainerPublicAccessType.Blob
            });

            return container;
        }

        private void CreateFile(CloudBlobContainer container, string blobname, byte[] data)
        {
            // Retrieve reference to a blob
            var blockBlob = container.GetBlockBlobReference(blobname);

            // Create or overwrite the blob with contents from resource
            using (var fileStream = new MemoryStream(data))
            {
                blockBlob.UploadFromStream(fileStream);
            }
        }

        private void CreateProductRecommendations()
        {
            CreateContainer("productrec");
        }

        private void UploadScripts()
        {
            // Create Container
            var container = CreateContainer("scripts");

            // Upload the File
            CreateFile(container, @"partitionproductusage.hql", ResourceHelper.ReadBytes(@"ProductRecommendations\Scripts\PartitionProductUsage.hql"));
            CreateFile(container, @"preparemahoutinput.hql", ResourceHelper.ReadBytes(@"ProductRecommendations\Scripts\PrepareMahoutInput.hql"));
            CreateFile(container, @"recommendedproducts.hql", ResourceHelper.ReadBytes(@"ProductRecommendations\Scripts\RecommendedProducts.hql"));
            CreateFile(container, @"selectsimilarproducts.hql", ResourceHelper.ReadBytes(@"ProductRecommendations\Scripts\SelectSimilarProducts.hql"));
        }

        private void UploadJars()
        {
            // Create Container
            var container = CreateContainer("jars");

            // Upload the File
            CreateFile(container, @"mahout\mahout-core-0.9.0.2.1.12.0-2329-job.jar", ResourceHelper.ReadBytes(@"ProductRecommendations\Packages\Mahout.jar"));
        }

        private void UploadPackages()
        {
            // Create Container
            var container = CreateContainer("packages");

            // Upload the File
            CreateFile(container, "ProductRecDataGenerator.zip", ResourceHelper.ReadBytes(@"ProductRecommendations\Packages\DataGenerator.zip"));
        }

        private string UpdateParameters(string text)
        {
            text = text.Replace("<account name>", Parameters.Tenant.SiteName);
            text = text.Replace("<account key>", Parameters.Tenant.StoragePrimaryKey);
            text = text.Replace("<azuredbname>", Parameters.GetSiteName("primary"));
            text = text.Replace("<dbname>", Parameters.Tenant.DatabaseName);
            text = text.Replace("<userid>", Parameters.Tenant.UserName);
            text = text.Replace("<password>", Parameters.Tenant.Password);

            return text;
        }

        #endregion

        #region - LinkedServices -

        private void CreateLinkedService_Sql(DataFactoryManagementClient client)
        {
            // Setup LinkedService Parameters
            var parameters = new LinkedServiceCreateOrUpdateParameters()
            {
                LinkedService = new LinkedService()
                {
                    Name = "AzureSqlLinkedService",
                    Properties = new LinkedServiceProperties(
                        new AzureSqlDatabaseLinkedService()
                        {
                            ConnectionString = string.Format("Server=tcp:{0}.database.windows.net,1433;Database={1};User ID={2}@{0};Password={3};Trusted_Connection=False;Encrypt=True;Connection Timeout=30", Parameters.GetSiteName("primary"), Parameters.Tenant.DatabaseName, Parameters.Tenant.UserName, Parameters.Tenant.Password)
                        })
                }
            };

            // Create LinkedService
            client.LinkedServices.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreateLinkedService_Storage(DataFactoryManagementClient client)
        {
            // Setup LinkedService Parameters
            var parameters = new LinkedServiceCreateOrUpdateParameters()
            {
                LinkedService = new LinkedService()
                {
                    Name = "StorageLinkedService",
                    Properties = new LinkedServiceProperties(
                        new AzureStorageLinkedService()
                        {
                            ConnectionString = string.Format("DefaultEndpointsProtocol=https;AccountName={0};AccountKey={1}", Parameters.Tenant.SiteName, Parameters.Tenant.StoragePrimaryKey)
                        })
                }
            };

            // Create LinkedService
            client.LinkedServices.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreateLinkedService_HdInsight(DataFactoryManagementClient client)
        {
            // Setup LinkedService Parameters
            var properties = new HDInsightOnDemandLinkedService()
            {
                ClusterSize = 4,
                TimeToLive = new TimeSpan(0, 4, 0, 0),
                Version = "3.1",
                LinkedServiceName = "StorageLinkedService"
            };

            var parameters = new LinkedServiceCreateOrUpdateParameters()
            {
                LinkedService = new LinkedService()
                {
                    Name = "HDInsightLinkedService",
                    Properties = new LinkedServiceProperties(properties)
                }
            };

            // Create LinkedService
            client.LinkedServices.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        #endregion

        #region - DataSets -

        private void CreateDataSet_RawProductsUsage(DataFactoryManagementClient client)
        {
            // Setup DataSet Parameters
            var parameters = new DatasetCreateOrUpdateParameters()
            {
                Dataset =
                    new Dataset("RawProductsUsageTable", new DatasetProperties()
                    {
                        Structure = new List<DataElement>()
                        {
                            new DataElement()
                            {
                                Name = "UserId",
                                Type = "String"
                            },
                            new DataElement()
                            {
                                Name = "ProductId",
                                Type = "String"
                            },
                            new DataElement()
                            {
                                Name = "Rating",
                                Type = "Int"
                            },
                            new DataElement()
                            {
                                Name = "Timestamp",
                                Type = "String"
                            },
                        },
                        LinkedServiceName = "StorageLinkedService",
                        TypeProperties = new AzureBlobDataset()
                        {
                            FolderPath = "productrec/rawusageevents/",
                            Format = new TextFormat()
                            {
                                ColumnDelimiter = "\t"
                            },
                        },
                        Availability = new Availability()
                        {
                            Frequency = "month",
                            Interval = 24,
                            Style = "StartOfInterval"
                        }
                    })
            };

            // Create DataSet
            client.Datasets.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreateDataSet_ProductsSimilaritySql(DataFactoryManagementClient client)
        {
            // Setup DataSet Parameters
            var parameters = new DatasetCreateOrUpdateParameters()
            {
                Dataset =
                    new Dataset("ProductsSimilaritySQLTable", new DatasetProperties()
                    {
                        Structure = new List<DataElement>()
                        {
                            new DataElement()
                            {
                                Name = "ProductId",
                                Type = "Int"
                            },
                            new DataElement()
                            {
                                Name = "SimilarProductId",
                                Type = "Int"
                            },
                        },
                        LinkedServiceName = "AzureSqlLinkedService",
                        TypeProperties = new AzureSqlTableDataset()
                        {
                            TableName = "SimilarProducts"
                        },
                        Availability = new Availability()
                        {
                            Frequency = "month",
                            Interval = 1,
                        }
                    })
            };

            // Create DataSet
            client.Datasets.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreateDataSet_ProductsSimilarityOutput(DataFactoryManagementClient client)
        {
            // Setup DataSet Parameters
            var parameters = new DatasetCreateOrUpdateParameters()
            {
                Dataset =
                    new Dataset("ProductsSimilarityOutputTable", new DatasetProperties()
                    {
                        Structure = new List<DataElement>()
                        {
                            new DataElement()
                            {
                                Name = "ProductId",
                                Type = "Int"
                            },
                            new DataElement()
                            {
                                Name = "SimilarProductId",
                                Type = "Int"
                            },
                        },
                        LinkedServiceName = "StorageLinkedService",
                        TypeProperties = new AzureBlobDataset()
                        {
                            FolderPath = "productrec/itemsimilarityoutput/yearno={Year}/monthno={Month}/",
                            PartitionedBy = new List<Partition>()
                            {
                                new Partition() { Name = "Year", Value = new DateTimePartitionValue() { Date = "SliceStart", Format = "yyyy" }},
                                new Partition() { Name = "Month", Value = new DateTimePartitionValue() { Date = "SliceStart", Format = "%M" }}
                            },
                            Format = new TextFormat()
                            {
                                ColumnDelimiter = "\t"
                            }  
                        },
                        Availability = new Availability()
                        {
                            Frequency = "month",
                            Interval = 1,
                        }
                    })
            };

            // Create DataSet
            client.Datasets.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreateDataSet_ProductsSimilarity(DataFactoryManagementClient client)
        {
            // Setup DataSet Parameters
            var parameters = new DatasetCreateOrUpdateParameters()
            {
                Dataset =
                    new Dataset("ProductsSimilarityTable", new DatasetProperties()
                    {
                        Structure = new List<DataElement>()
                        {
                            new DataElement()
                            {
                                Name = "Product1Id",
                                Type = "String"
                            },
                            new DataElement()
                            {
                                Name = "Product2Id",
                                Type = "String"
                            },
                            new DataElement()
                            {
                                Name = "Similarity",
                                Type = "String"
                            },
                        },
                        LinkedServiceName = "StorageLinkedService",
                        TypeProperties = new AzureBlobDataset()
                        {
                            FolderPath = "productrec/itemsimilarity/yearno={Year}/monthno={Month}/",
                            PartitionedBy = new List<Partition>()
                            {
                                new Partition() { Name = "Year", Value = new DateTimePartitionValue() { Date = "SliceStart", Format = "yyyy" }},
                                new Partition() { Name = "Month", Value = new DateTimePartitionValue() { Date = "SliceStart", Format = "%M" }}
                            },
                            Format = new TextFormat()
                            {
                                ColumnDelimiter = "\t"
                            }
                        },
                        Availability = new Availability()
                        {
                            Frequency = "month",
                            Interval = 1,
                        }
                    })
            };

            // Create DataSet
            client.Datasets.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreateDataSet_ProductsRecommendationSql(DataFactoryManagementClient client)
        {
            // Setup DataSet Parameters
            var parameters = new DatasetCreateOrUpdateParameters()
            {
                Dataset =
                    new Dataset("ProductsRecommendationSQLTable", new DatasetProperties()
                    {
                        Structure = new List<DataElement>()
                        {
                            new DataElement()
                            {
                                Name = "CustomerId",
                                Type = "Int"
                            },
                            new DataElement()
                            {
                                Name = "RecommendedProductId",
                                Type = "Int"
                            },
                        },
                        LinkedServiceName = "AzureSqlLinkedService",
                        TypeProperties = new AzureSqlTableDataset()
                        {
                            TableName = "PersonalizedRecommendations"
                        },
                        Availability = new Availability()
                        {
                            Frequency = "month",
                            Interval = 1
                        }
                    })
            };

            // Create DataSet
            client.Datasets.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreateDataSet_ProductsRecommendationOutput(DataFactoryManagementClient client)
        {
            // Setup DataSet Parameters
            var parameters = new DatasetCreateOrUpdateParameters()
            {
                Dataset =
                    new Dataset("ProductsRecommendationOutputTable", new DatasetProperties()
                    {
                        Structure = new List<DataElement>()
                        {
                            new DataElement()
                            {
                                Name = "CustomerId",
                                Type = "Int"
                            },
                            new DataElement()
                            {
                                Name = "RecommendedProductId",
                                Type = "Int"
                            },
                        },
                        LinkedServiceName = "StorageLinkedService",
                        TypeProperties = new AzureBlobDataset()
                        {
                            FolderPath = "productrec/recommendationsoutput/yearno={Year}/monthno={Month}/",
                            PartitionedBy = new List<Partition>()
                            {
                                new Partition() { Name = "Year", Value = new DateTimePartitionValue() { Date = "SliceStart", Format = "yyyy" }},
                                new Partition() { Name = "Month", Value = new DateTimePartitionValue() { Date = "SliceStart", Format = "%M" }}
                            },
                            Format = new TextFormat()
                            {
                                ColumnDelimiter = "\t"
                            }
                        },
                        Availability = new Availability()
                        {
                            Frequency = "month",
                            Interval = 1
                        }
                    })
            };

            // Create DataSet
            client.Datasets.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreateDataSet_ProductsRecommendation(DataFactoryManagementClient client)
        {
            // Setup DataSet Parameters
            var parameters = new DatasetCreateOrUpdateParameters()
            {
                Dataset =
                    new Dataset("ProductsRecommendationTable", new DatasetProperties()
                    {
                        Structure = new List<DataElement>()
                        {
                            new DataElement()
                            {
                                Name = "UserId",
                                Type = "String"
                            },
                            new DataElement()
                            {
                                Name = "RecommendedProducts",
                                Type = "String"
                            },
                        },
                        LinkedServiceName = "StorageLinkedService",
                        TypeProperties = new AzureBlobDataset()
                        {
                            FolderPath = "productrec/recommendations/yearno={Year}/monthno={Month}/",
                            PartitionedBy = new List<Partition>()
                            {
                                new Partition() { Name = "Year", Value = new DateTimePartitionValue() { Date = "SliceStart", Format = "yyyy" }},
                                new Partition() { Name = "Month", Value = new DateTimePartitionValue() { Date = "SliceStart", Format = "%M" }}
                            },
                            Format = new TextFormat()
                            {
                                ColumnDelimiter = "\t"
                            }
                        },
                        Availability = new Availability()
                        {
                            Frequency = "month",
                            Interval = 1
                        }
                    })
            };

            // Create DataSet
            client.Datasets.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreateDataSet_PartitionedProductsUsage(DataFactoryManagementClient client)
        {
            // Setup DataSet Parameters
            var parameters = new DatasetCreateOrUpdateParameters()
            {
                Dataset =
                    new Dataset("PartitionedProductsUsageTable", new DatasetProperties()
                    {
                        Structure = new List<DataElement>()
                        {
                            new DataElement()
                            {
                                Name = "UserId",
                                Type = "String"
                            },
                            new DataElement()
                            {
                                Name = "ProductId",
                                Type = "String"
                            },
                            new DataElement()
                            {
                                Name = "Timestamp",
                                Type = "String"
                            },
                        },
                        LinkedServiceName = "StorageLinkedService",
                        TypeProperties = new AzureBlobDataset()
                        {
                            FolderPath = "productrec/partitionedusageevents/yearno={Year}/monthno={Month}/",
                            PartitionedBy = new List<Partition>()
                            {
                                new Partition() { Name = "Year", Value = new DateTimePartitionValue() { Date = "SliceStart", Format = "yyyy" }},
                                new Partition() { Name = "Month", Value = new DateTimePartitionValue() { Date = "SliceStart", Format = "%M" }}
                            }
                        },
                        Availability = new Availability()
                        {
                            Frequency = "month",
                            Interval = 1
                        }
                    })
            };

            // Create DataSet
            client.Datasets.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreateDataSet_MahoutInputProductsUsage(DataFactoryManagementClient client)
        {
            // Setup DataSet Parameters
            var parameters = new DatasetCreateOrUpdateParameters()
            {
                Dataset =
                    new Dataset("MahoutInputProductsUsageTable", new DatasetProperties()
                    {
                        Structure = new List<DataElement>()
                        {
                            new DataElement()
                            {
                                Name = "UserId",
                                Type = "String"
                            },
                            new DataElement()
                            {
                                Name = "ProductId",
                                Type = "String"
                            },
                        },
                        LinkedServiceName = "StorageLinkedService",
                        TypeProperties = new AzureBlobDataset()
                        {
                            FolderPath = "productrec/mahoutinput/yearno={Year}/monthno={Month}/",
                            PartitionedBy = new List<Partition>()
                            {
                                new Partition() { Name = "Year", Value = new DateTimePartitionValue() { Date = "SliceStart", Format = "yyyy" }},
                                new Partition() { Name = "Month", Value = new DateTimePartitionValue() { Date = "SliceStart", Format = "%M" }}
                            }
                        },
                        Availability = new Availability()
                        {
                            Frequency = "month",
                            Interval = 1
                        },
                        
                    })
            };

            // Create DataSet
            client.Datasets.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        #endregion

        #region - Pipelines -

        private void CreatePipeline_ProductsSimilarityMahout(DataFactoryManagementClient client)
        {
            // Setup Pipeline Parameters
            var parameters = new PipelineCreateOrUpdateParameters()
            {
                Pipeline = new Pipeline()
                {
                    Name = "ProductsSimilarityMahoutPipeline",
                    Properties = new PipelineProperties()
                    {
                        Description = "Pipeline to Run a Mahout Custom Map Reduce Jar. This job calculates an Item Similarity Matrix to determine the similarity between 2 items",
                        Start = _pipelineStartDate,
                        End = _pipelineEndDate,
                        Activities = new List<Activity>()
                        {
                            new Activity()
                            {
                                Name = "MahoutActivity",
                                Description = "Custom Map Reduce to generate Mahout result",
                                Inputs = new List<ActivityInput>()
                                {
                                    new ActivityInput("MahoutInputProductsUsageTable")
                                },
                                Outputs = new List<ActivityOutput>()
                                {
                                    new ActivityOutput("ProductsSimilarityTable")  
                                },
                                LinkedServiceName = "HDInsightLinkedService",
                                TypeProperties = new HDInsightMapReduceActivity()
                                {
                                    ClassName = "org.apache.mahout.cf.taste.hadoop.similarity.item.ItemSimilarityJob",
                                    JarFilePath = "jars/mahout/mahout-core-0.9.0.2.1.12.0-2329-job.jar",
                                    JarLinkedService = "StorageLinkedService",
                                    Arguments = new List<string>()
                                    {
                                        UpdateParameters("-s"),
                                        UpdateParameters("SIMILARITY_LOGLIKELIHOOD"),
                                        UpdateParameters("--input"),
                                        UpdateParameters("$$Text.Format('wasb://productrec@<account name>.blob.core.windows.net/mahoutinput/yearno={0:yyyy}/monthno={0:%M}/', SliceStart)"),
                                        UpdateParameters("--output"),
                                        UpdateParameters("$$Text.Format('wasb://productrec@<account name>.blob.core.windows.net/itemsimilarity/yearno={0:yyyy}/monthno={0:%M}/', SliceStart)"),
                                        UpdateParameters("--maxSimilaritiesPerItem"),
                                        UpdateParameters("500"),
                                        UpdateParameters("--tempDir"),
                                        UpdateParameters("$$Text.Format('wasb://productrec@<account name>.blob.core.windows.net/tempitemsimilaritydir/yearno={0:yyyy}/monthno={0:%M}/', SliceStart)")
                                    },
                                },
                                Policy = new ActivityPolicy()
                                {
                                    Concurrency = 1,
                                    ExecutionPriorityOrder = "NewestFirst",
                                    Retry = 1,
                                    Timeout = new TimeSpan(0, 1, 0, 0)
                                }
                            }
                        },
                    }
                }
            };

            // Create PipeLine
            client.Pipelines.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreatePipeline_ProductsRecommenderMahout(DataFactoryManagementClient client)
        {
            // Setup Pipeline Parameters
            var parameters = new PipelineCreateOrUpdateParameters()
            {
                Pipeline = new Pipeline()
                {
                    Name = "ProductsRecommenderMahoutPipeline",
                    Properties = new PipelineProperties()
                    {
                        Description = "Pipeline to Run a Mahout Custom Map Reduce Jar to generate Recommendations.",
                        Start = _pipelineStartDate,
                        End = _pipelineEndDate,
                        Activities = new List<Activity>()
                        {
                            new Activity()
                            {
                                Name = "MahoutActivity",
                                Description = "Custom Map Reduce to generate Mahout result",
                                Inputs = new List<ActivityInput>()
                                {
                                    new ActivityInput("MahoutInputProductsUsageTable")
                                },
                                Outputs = new List<ActivityOutput>()
                                {
                                    new ActivityOutput("ProductsRecommendationTable")  
                                },
                                LinkedServiceName = "HDInsightLinkedService",
                                TypeProperties = new HDInsightMapReduceActivity()
                                {
                                    ClassName = "org.apache.mahout.cf.taste.hadoop.similarity.item.ItemSimilarityJob",
                                    JarFilePath = "jars/mahout/mahout-core-0.9.0.2.1.12.0-2329-job.jar",
                                    JarLinkedService = "StorageLinkedService",
                                    Arguments = new List<string>()
                                    {
                                        UpdateParameters("-s"),
                                        UpdateParameters("SIMILARITY_COOCCURRENCE"),
                                        UpdateParameters("--input"),
                                        UpdateParameters("$$Text.Format('wasb://productrec@<account name>.blob.core.windows.net/mahoutinput/yearno={0:yyyy}/monthno={0:%M}/', SliceStart)"),
                                        UpdateParameters("--output"),
                                        UpdateParameters("$$Text.Format('wasb://productrec@<account name>.blob.core.windows.net/recommendations/yearno={0:yyyy}/monthno={0:%M}/', SliceStart)"),
                                        UpdateParameters("--tempDir"),
                                        UpdateParameters("$$Text.Format('wasb://productrec@<account name>.blob.core.windows.net/temprecommendationsdir/yearno={0:yyyy}/monthno={0:%M}/', SliceStart)")
                                    },
                                },
                                Policy = new ActivityPolicy()
                                {
                                    Concurrency = 1,
                                    ExecutionPriorityOrder = "NewestFirst",
                                    Retry = 1,
                                    Timeout = new TimeSpan(0, 1, 0, 0)
                                }
                            }
                        },
                    }
                }
            };

            // Create PipeLine
            client.Pipelines.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreatePipeline_PrepareSampleData(DataFactoryManagementClient client)
        {
            // Setup Pipeline Parameters
            var parameters = new PipelineCreateOrUpdateParameters()
            {
                Pipeline = new Pipeline()
                {
                    Name = "PrepareSampleDataPipeline",
                    Properties = new PipelineProperties()
                    {
                        Description = "Prepare Sample Data for Personalized Product Recommendation Use Case",
                        Start = _pipelineStartDate,
                        End = _pipelineEndDate,
                        Activities = new List<Activity>()
                        {
                            new Activity()
                            {
                                Name = "PrepareSampleDataActivity",
                                Description = "Prepare Sample Data for Personalized Product Recommendation Use Case",
                                Outputs = new List<ActivityOutput>()
                                {
                                    new ActivityOutput("RawProductsUsageTable")  
                                },
                                LinkedServiceName = "HDInsightLinkedService",
                                TypeProperties = new DotNetActivity()
                                {
                                    AssemblyName = "ProductRecDataGenerator.dll",
                                    EntryPoint = "ProductRecDataGenerator.DataGenerator",
                                    PackageLinkedService = "StorageLinkedService",
                                    PackageFile = "packages/ProductRecDataGenerator.zip",
                                    ExtendedProperties = new Dictionary<string, string>()
                                    {
                                        { "sliceStart", "$$Text.Format('{0:yyyyMMddHHmm}', Time.AddMinutes(SliceStart, 0))" }
                                    }
                                },
                                Policy = new ActivityPolicy()
                                {
                                    Concurrency = 1,
                                    ExecutionPriorityOrder = "NewestFirst",
                                    Retry = 1,
                                    Timeout = new TimeSpan(0, 2, 0, 0)
                                }
                            }
                        },
                    }
                }
            };

            // Create PipeLine
            client.Pipelines.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreatePipeline_PrepareMahoutUsage(DataFactoryManagementClient client)
        {
            // Setup Pipeline Parameters
            var parameters = new PipelineCreateOrUpdateParameters()
            {
                Pipeline = new Pipeline()
                {
                    Name = "PrepareMahoutUsagePipeline",
                    Properties = new PipelineProperties()
                    {
                        Description = "This is a pipeline to prepare the data for feeding into the Mahout engine",
                        Start = _pipelineStartDate,
                        End = _pipelineEndDate,
                        Activities = new List<Activity>()
                        {
                            new Activity()
                            {
                                Name = "PrepareMahoutInputHiveActivity",
                                Description = "Prepare Mahout Input Hive Activity",
                                Inputs = new List<ActivityInput>()
                                {
                                    new ActivityInput("PartitionedProductsUsageTable")
                                },
                                Outputs = new List<ActivityOutput>()
                                {
                                    new ActivityOutput("MahoutInputProductsUsageTable")  
                                },
                                LinkedServiceName = "HDInsightLinkedService",
                                TypeProperties = new HDInsightHiveActivity()
                                {
                                    ScriptPath = "scripts\\preparemahoutinput.hql",
                                    ScriptLinkedService = "StorageLinkedService",
                                    Defines = new Dictionary<string, string>()
                                    {
                                        { "MAHOUTINPUT", UpdateParameters("$$Text.Format('wasb://productrec@<account name>.blob.core.windows.net/mahoutinput/yearno={0:yyyy}/monthno={0:%M}/', SliceStart)") },
                                        { "PARTITIONEDOUTPUT", UpdateParameters("$$Text.Format('wasb://productrec@<account name>.blob.core.windows.net/partitionedusageevents/yearno={0:yyyy}/monthno={0:%M}/', SliceStart)") }
                                    },
                                },
                                Policy = new ActivityPolicy()
                                {
                                    Concurrency = 1,
                                    ExecutionPriorityOrder = "NewestFirst",
                                    Retry = 1,
                                    Timeout = new TimeSpan(0, 1, 0, 0)
                                }
                            }
                        },
                    }
                }
            };

            // Create PipeLine
            client.Pipelines.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreatePipeline_PartitionProductUsage(DataFactoryManagementClient client)
        {
            // Setup Pipeline Parameters
            var parameters = new PipelineCreateOrUpdateParameters()
            {
                Pipeline = new Pipeline()
                {
                    Name = "PartitionProductsUsagePipeline",
                    Properties = new PipelineProperties()
                    {
                        Description = "This is a pipeline to prepare the raw Products Usage data for further processing (v1.0)",
                        Start = _pipelineStartDate,
                        End = _pipelineEndDate,
                        Activities = new List<Activity>()
                        {
                            new Activity()
                            {
                                Name = "BlobPartitionHiveActivity",
                                Description = "Blob Partition Hive Activity",
                                Inputs = new List<ActivityInput>()
                                {
                                    new ActivityInput("RawProductsUsageTable")
                                },
                                Outputs = new List<ActivityOutput>()
                                {
                                    new ActivityOutput("PartitionedProductsUsageTable")  
                                },
                                LinkedServiceName = "HDInsightLinkedService",
                                TypeProperties = new HDInsightHiveActivity()
                                {
                                    ScriptPath = "scripts\\partitionproductusage.hql",
                                    ScriptLinkedService = "StorageLinkedService",
                                    Defines = new Dictionary<string, string>()
                                    {
                                        { "RAWINPUT", UpdateParameters("wasb://productrec@<account name>.blob.core.windows.net/rawusageevents/") },
                                        { "PARTITIONEDOUTPUT", UpdateParameters("wasb://productrec@<account name>.blob.core.windows.net/partitionedusageevents/") },
                                        { "Year", "$$Text.Format('{0:yyyy}',SliceStart)" },
                                        { "Month", "$$Text.Format('{0:%M}',SliceStart)" },
                                        { "Day", "$$Text.Format('{0:%d}',SliceStart)" }
                                    },
                                },
                                Policy = new ActivityPolicy()
                                {
                                    Concurrency = 1,
                                    ExecutionPriorityOrder = "NewestFirst",
                                    Retry = 2,
                                    Timeout = new TimeSpan(0, 1, 0, 0)
                                }
                            }
                        },
                    }
                }
            };

            // Create PipeLine
            client.Pipelines.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreatePipeline_MapSimilarProducts(DataFactoryManagementClient client)
        {
            // Setup Pipeline Parameters
            var parameters = new PipelineCreateOrUpdateParameters()
            {
                Pipeline = new Pipeline()
                {
                    Name = "MapSimilarProductsPipeline",
                    Properties = new PipelineProperties()
                    {
                        Description = "This is a pipeline to map the similar productids generated as part of Mahout recommendations to the product name",
                        Start = _pipelineStartDate,
                        End = _pipelineEndDate,
                        Activities = new List<Activity>()
                        {
                            new Activity()
                            {
                                Name = "MapSimilarProductsHiveActivity",
                                Description = "Map Similar Hive Activity",
                                Inputs = new List<ActivityInput>()
                                {
                                    new ActivityInput("ProductsSimilarityTable")
                                },
                                Outputs = new List<ActivityOutput>()
                                {
                                    new ActivityOutput("ProductsSimilarityOutputTable")  
                                },
                                LinkedServiceName = "HDInsightLinkedService",
                                TypeProperties = new HDInsightHiveActivity()
                                {
                                    ScriptPath = "scripts\\selectsimilarproducts.hql",
                                    ScriptLinkedService = "StorageLinkedService",
                                    Defines = new Dictionary<string, string>()
                                    {
                                        { "MAHOUTOUTPUT", UpdateParameters("$$Text.Format('wasb://productrec@<account name>.blob.core.windows.net/itemsimilarity/yearno={0:yyyy}/monthno={0:%M}/', SliceStart)") },
                                        { "SIMILARPRODUCTSOUTPUT", UpdateParameters("$$Text.Format('wasb://productrec@<account name>.blob.core.windows.net/itemsimilarityoutput/yearno={0:yyyy}/monthno={0:%M}/', SliceStart)") }
                                    },
                                },
                                Policy = new ActivityPolicy()
                                {
                                    Concurrency = 1,
                                    ExecutionPriorityOrder = "NewestFirst",
                                    Retry = 0,
                                    Timeout = new TimeSpan(0, 1, 0, 0)
                                }
                            }
                        },
                    }
                }
            };

            // Create PipeLine
            client.Pipelines.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreatePipeline_MapRecommendedProducts(DataFactoryManagementClient client)
        {
            // Setup Pipeline Parameters
            var parameters = new PipelineCreateOrUpdateParameters()
            {
                Pipeline = new Pipeline()
                {
                    Name = "MapRecommendedProductsPipeline",
                    Properties = new PipelineProperties()
                    {
                        Description = "This is a pipeline to map the recommended products generated as part of Mahout recommendations to the product name",
                        Start = _pipelineStartDate,
                        End = _pipelineEndDate,
                        Activities = new List<Activity>()
                        {
                            new Activity()
                            {
                                Name = "MapRecommendedProductsHiveActivity",
                                Description = "Map Recommendations Hive Activity",
                                Inputs = new List<ActivityInput>()
                                {
                                    new ActivityInput("ProductsRecommendationTable")
                                },
                                Outputs = new List<ActivityOutput>()
                                {
                                    new ActivityOutput("ProductsRecommendationOutputTable")  
                                },
                                LinkedServiceName = "HDInsightLinkedService",
                                TypeProperties = new HDInsightHiveActivity()
                                {
                                    ScriptPath = "scripts\\recommendedproducts.hql",
                                    ScriptLinkedService = "StorageLinkedService",
                                    Defines = new Dictionary<string, string>()
                                    {
                                        { "MAHOUTOUTPUT", UpdateParameters("$$Text.Format('wasb://productrec@<account name>.blob.core.windows.net/recommendations/yearno={0:yyyy}/monthno={0:%M}/', SliceStart)") },
                                        { "RECOMMENDATIONSOUTPUT", UpdateParameters("$$Text.Format('wasb://productrec@<account name>.blob.core.windows.net/recommendationsoutput/yearno={0:yyyy}/monthno={0:%M}/', SliceStart)") }
                                    },
                                },
                                Policy = new ActivityPolicy()
                                {
                                    Concurrency = 1,
                                    ExecutionPriorityOrder = "NewestFirst",
                                    Retry = 0,
                                    Timeout = new TimeSpan(0, 1, 0, 0)
                                }
                            }
                        },
                    }
                }
            };

            // Create PipeLine
            client.Pipelines.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreatePipeline_EgressSimilarProductsSql(DataFactoryManagementClient client)
        {
            // Setup Pipeline Parameters
            var parameters = new PipelineCreateOrUpdateParameters()
            {
                Pipeline = new Pipeline()
                {
                    Name = "EgressSimilarProductsSqlPipeline",
                    Properties = new PipelineProperties()
                    {
                        Description = "Egress Similar Products Matrix to Sql Azure",
                        Start = _pipelineStartDate,
                        End = _pipelineEndDate,
                        Activities = new List<Activity>()
                        {
                            new Activity()
                            {
                                Name = "EgressSqlAzure",
                                Description = "Move Similar Products Matrix to Sql Azure",
                                Inputs = new List<ActivityInput>()
                                {
                                    new ActivityInput("ProductsSimilarityOutputTable")
                                },
                                Outputs = new List<ActivityOutput>()
                                {
                                    new ActivityOutput("ProductsSimilaritySQLTable")  
                                },
                                TypeProperties = new CopyActivity()
                                {
                                    Source = new BlobSource()
                                    {
                                        TreatEmptyAsNull = true
                                    },
                                    Sink = new SqlSink()
                                    {
                                        WriteBatchTimeout = new TimeSpan(0, 1, 0, 0)
                                    },
                                },
                                Policy = new ActivityPolicy()
                                {
                                    Concurrency = 1,
                                    ExecutionPriorityOrder = "NewestFirst",
                                    Retry = 1,
                                    Timeout = new TimeSpan(0, 10, 0, 0)
                                }
                            }
                        },
                    }
                }
            };

            // Create PipeLine
            client.Pipelines.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        private void CreatePipeline_EgressRecommendedProductsSql(DataFactoryManagementClient client)
        {
            // Setup Pipeline Parameters
            var parameters = new PipelineCreateOrUpdateParameters()
            {
                Pipeline = new Pipeline()
                {
                    Name = "EgressRecommendedProductsSqlPipeline",
                    Properties = new PipelineProperties()
                    {
                        Description = "Egress Recommendations to Sql Azure",
                        Start = _pipelineStartDate,
                        End = _pipelineEndDate,
                        Activities = new List<Activity>()
                        {
                            new Activity()
                            {
                                Name = "EgressSqlAzure",
                                Description = "Move Recommendations to Sql Azure",
                                Inputs = new List<ActivityInput>()
                                {
                                    new ActivityInput("ProductsRecommendationOutputTable")
                                },
                                Outputs = new List<ActivityOutput>()
                                {
                                    new ActivityOutput("ProductsRecommendationSQLTable")  
                                },
                                TypeProperties = new CopyActivity()
                                {
                                    Source = new BlobSource()
                                    {
                                        TreatEmptyAsNull = true
                                    },
                                    Sink = new SqlSink()
                                    {
                                        WriteBatchTimeout = new TimeSpan(0, 1, 0, 0)
                                    },
                                },
                                Policy = new ActivityPolicy()
                                {
                                    Concurrency = 1,
                                    ExecutionPriorityOrder = "NewestFirst",
                                    Retry = 1,
                                    Timeout = new TimeSpan(0, 10, 0, 0)
                                }
                            }
                        },
                    }
                }
            };

            // Create PipeLine
            client.Pipelines.CreateOrUpdateAsync(Parameters.Tenant.SiteName, Parameters.Tenant.SiteName, parameters).Wait();
        }

        #endregion
    }
}
