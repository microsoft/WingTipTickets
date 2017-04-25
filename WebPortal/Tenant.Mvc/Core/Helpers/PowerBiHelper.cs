using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using Microsoft.PowerBI.Api.V1;
using Microsoft.PowerBI.Api.V1.Models;
using Microsoft.PowerBI.Security;
using Microsoft.Rest;
using Tenant.Mvc.Controllers;
using WingTipTickets;

namespace Tenant.Mvc.Core.Helpers
{
    public static class PowerBiHelper
    {
        #region - Properties -

        private static string ApiUrl
        {
            get { return ConfigHelper.PowerbiApiUrl; }
        }

        private static string WorkspaceCollection
        {
            get { return ConfigHelper.PowerbiWorkspaceCollection; }
        }

        private static string WorkspaceId
        {
            get { return ConfigHelper.PowerbiWorkspaceId.ToString(); }
        }

        private static string AccessKey
        {
            get { return ConfigHelper.PowerbiSigningKey.ToString(); }
        }

        #endregion

        #region - Public Methods -

        public static List<Report> FetchReports(string excludeReportId = null)
        {
            using (var client = CreatePowerBiClient())
            {
                var reportsResponse = client.Reports.GetReports(WorkspaceCollection, WorkspaceId);

                if (!string.IsNullOrEmpty(excludeReportId))
                {
                    return reportsResponse.Value.Where(r => !r.Id.Equals(excludeReportId)).ToList();
                }

                return reportsResponse.Value.ToList();
            }
            
        }

        public static ReportsController.FetchReportResult FetchReport(string reportId)
        {
            using (var client = CreatePowerBiClient())
            {
                var reportsResponse =  client.Reports.GetReports(WorkspaceCollection, WorkspaceId);
                var report = reportsResponse.Value.FirstOrDefault(r => r.Id == reportId);

                if (report != null)
                {
                    var embedToken = PowerBIToken.CreateReportEmbedToken(WorkspaceCollection, WorkspaceId, report.Id);

                    return new ReportsController.FetchReportResult
                    {
                        Report = report,
                        AccessToken = embedToken.Generate(AccessKey)
                    };
                }

                return new ReportsController.FetchReportResult
                {
                    Report = null,
                    AccessToken = null
                };
            }
        }

        public static string CreatePowerBiToken(string reportId)
        {
            return PowerBIToken.CreateReportEmbedToken(WorkspaceCollection, WorkspaceId, reportId).Generate(AccessKey);
        }

        public static void UploadReport(HttpPostedFileBase postedFile)
        {
            using (var client = CreatePowerBiClient())
            {
                // Import PBIX file from the file stream
                var import = client.Imports.PostImportWithFile(WorkspaceCollection, WorkspaceId, postedFile.InputStream, Path.GetFileNameWithoutExtension(postedFile.FileName));
                
                // Poll the import to check when succeeded
                while (import.ImportState != "Succeeded" && import.ImportState != "Failed")
                {
                    import = client.Imports.GetImportById(WorkspaceCollection, WorkspaceId, import.Id);
                    Thread.Sleep(1000);
                }

                // Update all DataSet Connections
                foreach (var dataset in import.Datasets)
                {
                    UpdateConnection(dataset.Id);
                }
            }
        }

        public static void UpdateConnection(string datasetId)
        {
            using (var client = CreatePowerBiClient())
            {
                // Update DataSet Connection
                var connectionFormat = "Data source=tcp:{0},1433;initial catalog={1};Persist Security info=True;Encrypt=True;TrustServerCertificate=False";
                var connectionString = string.Format(connectionFormat, WingtipTicketApp.Config.TenantDatabaseServer, WingtipTicketApp.Config.wingtipReporting); //, WingtipTicketApp.Config.DatabaseUser, WingtipTicketApp.Config.DatabasePassword);

                var connectionParameters = new Dictionary<string, object>
                {
                    {
                        "connectionString", connectionString
                    }
                };

                client.Datasets.SetAllConnections(WorkspaceCollection, WorkspaceId, datasetId, connectionParameters);

                // Update DataSource Credentials
                var datasources = client.Datasets.GetGatewayDatasources(WorkspaceCollection, WorkspaceId, datasetId);

                var delta = new GatewayDatasource
                {
                    CredentialType = "Basic",
                    BasicCredentials = new BasicCredentials
                    {
                        Username = WingtipTicketApp.Config.DatabaseUser,
                        Password = WingtipTicketApp.Config.DatabasePassword
                    },
                };

                foreach (var datasource in datasources.Value)
                {
                    // Copy over existent data
                    delta.ConnectionDetails = datasource.ConnectionDetails;
                    delta.GatewayId = datasource.GatewayId;
                    delta.Id = datasource.Id;
                    delta.DatasourceType = datasource.DatasourceType;

                    // Update credentials
                    client.Gateways.PatchDatasource(WorkspaceCollection, WorkspaceId, datasource.GatewayId, datasource.Id, delta);
                }
            }
        }

        #endregion

        #region - Private Methods -

        private static IPowerBIClient CreatePowerBiClient()
        {
            var credentials = new TokenCredentials(AccessKey, "AppKey");

            var client = new PowerBIClient(credentials)
            {
                BaseUri = new Uri(ApiUrl)
            };

            return client;
        }

        #endregion
    }
}