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
            using (var client = CreatePowerBiClient())
            {
                var reportsResponse = client.Reports.GetReports(WorkspaceCollection, WorkspaceId);

                if (!string.IsNullOrEmpty(exclude))
                {
                    reportsResponse.Value = reportsResponse.Value.Where(r => !r.Name.Equals(exclude)).ToList();
                }

                return new SelectList(reportsResponse.Value.ToList(), "Id", "Name", reportId);
            }
        }

        public static ReportsController.FetchReportResult FetchReport(string reportId)
        {
            using (var client = CreatePowerBiClient())
            {
                var reports = client.Reports.GetReports(WorkspaceCollection, WorkspaceId);
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
            }
        }

        public static void UpdateConnection()
        {
            using (var client = CreatePowerBiClient())
            {
                // Get DataSets
                var dataset = client.Datasets.GetDatasets(WorkspaceCollection, WorkspaceId).Value.Last();

                var connectionString =
                    $"Data Source=tcp:{WingtipTicketApp.Config.TenantDatabaseServer}.database.windows.net,1433;Initial Catalog={WingtipTicketApp.Config.TenantDatabase1};User ID={WingtipTicketApp.Config.DatabaseUser};Password={WingtipTicketApp.Config.DatabasePassword};";

                // udpate the connectionstring details 
                var connectionParameters = new Dictionary<string, object>
                {
                    {"connectionString", connectionString}
                };
                client.Datasets.SetAllConnections(WorkspaceCollection, WorkspaceId, dataset.Id, connectionParameters);


                var datasources =
                    client.Datasets.GetGatewayDatasources(WorkspaceCollection, WorkspaceId, dataset.Id).Value;

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
                    client.Gateways.PatchDatasource(WorkspaceCollection, WorkspaceId, datasource.GatewayId,
                        datasource.Id, delta);
                }
            }
        }

        #endregion

        #region - Private Methods -

        private static IPowerBIClient CreatePowerBiClient()
        {
            var jwt = ConfigHelper.PowerbiSigningKey;
            var credentials = new TokenCredentials(jwt, "AppKey");

            var client = new PowerBIClient(credentials)
            {
                BaseUri = new Uri(ConfigHelper.PowerbiApiUrl)
            };

            return client;
        }


        #endregion
    }
}