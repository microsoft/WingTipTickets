using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using Microsoft.Azure.Management.DataFactories.Models;
using Microsoft.DataFactories.Runtime;

using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;

namespace ProductRecDataGenerator
{
    public class DataGenerator : IDotNetActivity
    {
        public IDictionary<string, string> Execute(
            IEnumerable<ResolvedTable> inputTables,
            IEnumerable<ResolvedTable> outputTables,
            IDictionary<string, string> extendedProperties,
            IActivityLogger logger)
        {
            var directoryName = new FileInfo(typeof(DataGenerator).Assembly.Location).DirectoryName;
            if (directoryName != null)
            {
                string sampleFilePath = Path.Combine(directoryName, @"SampleDataFiles");
            
                logger.Write(TraceEventType.Information, "SampleFilePath is the following: {0}", sampleFilePath);

                logger.Write(TraceEventType.Information, "Printing dictionary entities if any...");
                foreach (KeyValuePair<string, string> entry in extendedProperties)
                {
                    logger.Write(TraceEventType.Information, "<key:{0}> <value:{1}>", entry.Key, entry.Value);
                }

                foreach (ResolvedTable outputTable in outputTables)
                {
                    string storageConnectionString = GetConnectionString(outputTable.LinkedService);
                    string folderPath = GetFolderPath(outputTable.Table);
                    
                    if (String.IsNullOrEmpty(storageConnectionString))
                    {
                        logger.Write(TraceEventType.Error, "Null or Empty Connection string for output table: {0}", outputTable);
                        throw new Exception(string.Format("Null or Empty Connection string for output table: {0}", outputTable));
                    }
                    if (String.IsNullOrEmpty(folderPath))
                    {
                        logger.Write(TraceEventType.Error, "Null or Empty folderpath for output table: {0}", outputTable);
                        throw new Exception(string.Format("Null or Empty folder path for output table: {0}", outputTable));
                    }

                    logger.Write(TraceEventType.Information, "Writing blob to: {0}", folderPath);

                    CloudStorageAccount outputStorageAccount = CloudStorageAccount.Parse(storageConnectionString);
                    ProcessFiles(sampleFilePath, outputStorageAccount, folderPath, outputTable.Table.Name, logger);
                }
            }
            return new Dictionary<string, string>();
        }

        private static string GetConnectionString(LinkedService asset)
        {
            AzureStorageLinkedService storageAsset;
            if (asset == null)
            {
                return null;
            }

            storageAsset = asset.Properties as AzureStorageLinkedService;
            if (storageAsset == null)
            {
                return null;
            }

            return storageAsset.ConnectionString;
        }

        private static string GetFolderPath(Table dataArtifact)
        {
            AzureBlobLocation blobLocation;
            if (dataArtifact == null || dataArtifact.Properties == null)
            {
                return null;
            }

            blobLocation = dataArtifact.Properties.Location as AzureBlobLocation;
            if (blobLocation == null)
            {
                return null;
            }

            return blobLocation.FolderPath;
        }

        /// <summary>
        /// Process sample Files for generating test data
        /// </summary>
        /// <param name="path"></param>
        /// <param name="outputStorageAccount"></param>
        /// <param name="folderPath"></param>
        /// <param name="outputTableName"></param>
        /// <param name="logger"></param>
        public static void ProcessFiles(string path, CloudStorageAccount outputStorageAccount, string folderPath, string outputTableName, IActivityLogger logger)
        {
            string[] files = Directory.GetFiles(path);

            foreach (var file in files)
            {
                if (file.Contains(@"artist_data.txt") && outputTableName.ToLower().Contains(@"catalog"))
                {
                    Uri outputBlobUri = new Uri(outputStorageAccount.BlobEndpoint, folderPath + "artist_data.txt");
                    CloudBlockBlob outputBlob = new CloudBlockBlob(outputBlobUri, outputStorageAccount.Credentials);
                    if (outputBlob.Exists())
                    {
                        outputBlob.Delete();
                    }
                    outputBlob.UploadFromFile(path + "/artist_data.txt", FileMode.Open);
                }
                if (file.Contains(@"customers.txt") && outputTableName.ToLower().Contains(@"customers"))
                {
                    Uri outputBlobUri = new Uri(outputStorageAccount.BlobEndpoint, folderPath + "customers.txt");
                    CloudBlockBlob outputBlob = new CloudBlockBlob(outputBlobUri, outputStorageAccount.Credentials);
                    if (outputBlob.Exists())
                    {
                        outputBlob.Delete();
                    }
                    outputBlob.UploadFromFile(path + "/customers.txt", FileMode.Open);
                }
                else if (file.Contains(@"artist_customer_data.txt") && outputTableName.ToLower().Contains(@"rawproducts"))
                {
                    Uri outputBlobUri = new Uri(outputStorageAccount.BlobEndpoint, folderPath + "artist_customer_data.txt");
                    CloudBlockBlob outputBlob = new CloudBlockBlob(outputBlobUri, outputStorageAccount.Credentials);
                    List<string> lines = File.ReadAllLines(path + "/artist_customer_data.txt").ToList();
                    int index = 0;

                    if (outputBlob.Exists() && index == 0)
                    {
                        outputBlob.Delete();
                    }

                    //add new column value for each row.
                    lines.Skip(0).ToList().ForEach(line =>
                    {
                        if (index >= 0 & index <= 1000)
                        {
                            lines[index] += "," + DateTime.UtcNow.AddMonths(-1).ToString("yyyy-MM-dd");
                            UploadBlobStream(outputBlob, lines[index]);
                            index++;
                        }
                        else if (index >= 1001 & index <= 2000)
                        {
                            lines[index] += "," + DateTime.UtcNow.AddMonths(-2).ToString("yyyy-MM-dd");
                            UploadBlobStream(outputBlob, lines[index]);
                            index++;
                        }
                        else if (index >= 2001 & index <= 3000)
                        {
                            lines[index] += "," + DateTime.UtcNow.AddMonths(-3).ToString("yyyy-MM-dd");
                            UploadBlobStream(outputBlob, lines[index]);
                            index++;
                        }
                        else if (index >= 3001 & index <= 4000)
                        {
                            lines[index] += "," + DateTime.UtcNow.AddMonths(-4).ToString("yyyy-MM-dd");
                            UploadBlobStream(outputBlob, lines[index]);
                            index++;
                        }
                        else if (index >= 4001 & index <= 5000)
                        {
                            lines[index] += "," + DateTime.UtcNow.AddMonths(-5).ToString("yyyy-MM-dd");
                            UploadBlobStream(outputBlob, lines[index]);
                            index++;
                        }
                        else if (index >= 5001 & index <= 6000)
                        {
                            lines[index] += "," + DateTime.UtcNow.AddMonths(-6).ToString("yyyy-MM-dd");
                            UploadBlobStream(outputBlob, lines[index]);
                            index++;
                        }
                        else if (index >= 6001 & index <= 7000)
                        {
                            lines[index] += "," + DateTime.UtcNow.AddMonths(-7).ToString("yyyy-MM-dd");
                            UploadBlobStream(outputBlob, lines[index]);
                            index++;
                        }
                        else if (index >= 7001 & index <= 8000)
                        {
                            lines[index] += "," + DateTime.UtcNow.AddMonths(-8).ToString("yyyy-MM-dd");
                            UploadBlobStream(outputBlob, lines[index]);
                            index++;
                        }
                        else if (index >= 8001 & index <= 9000)
                        {
                            lines[index] += "," + DateTime.UtcNow.AddMonths(-9).ToString("yyyy-MM-dd");
                            UploadBlobStream(outputBlob, lines[index]);
                            index++;
                        }
                        else if (index >= 9001 & index <= 10000)
                        {
                            lines[index] += "," + DateTime.UtcNow.AddMonths(-10).ToString("yyyy-MM-dd");
                            UploadBlobStream(outputBlob, lines[index]);
                            index++;
                        }
                        else if (index >= 10001 & index <= 11000)
                        {
                            lines[index] += "," + DateTime.UtcNow.AddMonths(-11).ToString("yyyy-MM-dd");
                            UploadBlobStream(outputBlob, lines[index]);
                            index++;
                        }
                        else if (index >= 11001 & index <= 12000)
                        {
                            lines[index] += "," + DateTime.UtcNow.AddMonths(-12).ToString("yyyy-MM-dd");
                            UploadBlobStream(outputBlob, lines[index]);
                            index++;
                        }
                        Console.WriteLine("Writing blob number: {0}", index);
                        logger.Write(TraceEventType.Information, "Writing blob number: {0}", index);
                    });
                }
            }
        }

        /// <summary>
        /// Uploads Memory Stream to Blob
        /// </summary>
        /// <param name="outputBlob"></param>
        /// <param name="line"></param>
        private static void UploadBlobStream(CloudBlockBlob outputBlob, string line)
        {
            using (MemoryStream ms = new MemoryStream())
            {
                if (outputBlob.Exists())
                {
                    outputBlob.DownloadToStream(ms);
                }
                byte[] dataToWrite = Encoding.UTF8.GetBytes(line + "\r\n");
                ms.Write(dataToWrite, 0, dataToWrite.Length);
                ms.Position = 0;
                outputBlob.UploadFromStream(ms);
            }
        }

    }
}
