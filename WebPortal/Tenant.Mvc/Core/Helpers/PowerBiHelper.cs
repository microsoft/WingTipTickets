using System;
using System.IO;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using Microsoft.PowerBI.Api.Beta;
using Microsoft.PowerBI.Api.Beta.Models;
using Microsoft.PowerBI.Security;
using Microsoft.Rest;
using Tenant.Mvc.Controllers;
using WingTipTickets;

namespace Tenant.Mvc.Core.Helpers
{
    public static class PowerBiHelper
    {
        #region - Properties -

        private static string WorkspaceCollection
        {
            get { return ConfigHelper.PowerbiWorkspaceCollection; }
        }

        private static string WorkspaceId
        {
            get { return ConfigHelper.PowerbiWorkspaceId.ToString(); }
        }

        #endregion

        #region - Public Methods -

        public static SelectList FetchReports(string reportId, string exclude = null)
        {
            // Create a dev token for fetch
            var devToken = PowerBIToken.CreateDevToken(WorkspaceCollection, WorkspaceId);

            using (var client = CreatePowerBiClient(devToken))
            {
                var reportsResponse = ReportsExtensions.GetReports(client.Reports, WorkspaceCollection, WorkspaceId);

                if (!string.IsNullOrEmpty(exclude))
                {
                    reportsResponse.Value = reportsResponse.Value.Where(r => !r.Name.Equals(exclude)).ToList();
                }

                return new SelectList(reportsResponse.Value.ToList(), "Id", "Name", reportId);
            }
        }

        public static ReportsController.FetchReportResult FetchReport(string reportId)
        {
            // Create a dev token for fetch
            var devToken = PowerBIToken.CreateDevToken(WorkspaceCollection, WorkspaceId);

            using (var client = CreatePowerBiClient(devToken))
            {
                var reports = ReportsExtensions.GetReports(client.Reports, WorkspaceCollection, WorkspaceId);
                var report = reports.Value.FirstOrDefault(r => r.Id == reportId);

                if (report != null)
                {
                    var embedToken = PowerBIToken.CreateReportEmbedToken(WorkspaceCollection, WorkspaceId, report.Id);

                    var result = new ReportsController.FetchReportResult
                    {
                        Report = report,
                        AccessToken = embedToken.Generate(ConfigHelper.PowerbiSigningKey)
                    };

                    return result;
                }

                return new ReportsController.FetchReportResult()
                {
                    AccessToken = string.Empty,
                    Report = null
                };

            }
        }

        public static void UploadReport(HttpPostedFileBase postedFile)
        {
            // Create a dev token for import
            var devToken = PowerBIToken.CreateDevToken(WorkspaceCollection, WorkspaceId);

            using (var client = CreatePowerBiClient(devToken))
            {
                // Import PBIX file from the file stream
                var import = ImportsExtensions.PostImportWithFile(client.Imports, WorkspaceCollection, WorkspaceId, postedFile.InputStream, Path.GetFileNameWithoutExtension(postedFile.FileName));
                
                // Poll the import to check when succeeded
                while (import.ImportState != "Succeeded" && import.ImportState != "Failed")
                {
                    import = ImportsExtensions.GetImportById(client.Imports, WorkspaceCollection, WorkspaceId, import.Id);
                    Thread.Sleep(1000);
                }
            }
        }

        public static void UpdateConnection()
        {
            // Create a dev token for update
            var devToken = PowerBIToken.CreateDevToken(WorkspaceCollection, WorkspaceId);

            using (var client = CreatePowerBiClient(devToken))
            {
                // Get DataSets
                var dataset = DatasetsExtensions.GetDatasets(client.Datasets, WorkspaceCollection, WorkspaceId).Value.Last();
                var datasources = DatasetsExtensions.GetGatewayDatasources(client.Datasets, WorkspaceCollection, WorkspaceId, dataset.Id).Value;

                // Build Credentials
                var delta = new GatewayDatasource
                {
                    CredentialType = "Basic",
                    
                    BasicCredentials = new BasicCredentials
                    {
                        Username = WingtipTicketApp.Config.DatabaseUser,
                        Password = WingtipTicketApp.Config.DatabasePassword
                    }
                };

                // Update each DataSource
                foreach (var datasource in datasources)
                {
                    // Update the datasource with the specified credentials
                    GatewaysExtensions.PatchDatasource(client.Gateways, WorkspaceCollection, WorkspaceId, datasource.GatewayId, datasource.Id, delta);
                }
            }
        }

        #endregion

        #region - Private Methods -

        private static IPowerBIClient CreatePowerBiClient(PowerBIToken token)
        {
            var jwt = token.Generate(ConfigHelper.PowerbiSigningKey);
            var credentials = new TokenCredentials(jwt, "AppToken");

            var client = new PowerBIClient(credentials)
            {
                BaseUri = new Uri(ConfigHelper.PowerbiApiUrl)
            };

            return client;
        }

        #endregion
    }
}