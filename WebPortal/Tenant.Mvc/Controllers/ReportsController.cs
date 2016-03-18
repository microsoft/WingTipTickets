using System;
using System.Linq;
using System.Web.Mvc;
using Microsoft.Ajax.Utilities;
using Microsoft.PowerBI.Api.Beta;
using Microsoft.PowerBI.Api.Beta.Models;
using Microsoft.PowerBI.Security;
using Microsoft.Rest;
using Tenant.Mvc.Core.Helpers;
using Tenant.Mvc.Models;

namespace Tenant.Mvc.Controllers
{
    public class ReportsController : Controller
    {
        #region - Index View -

        [HttpGet]
        public ActionResult Index()
        {
            var viewModel = new ReportsViewModel()
            {
                Reports = FetchReports(null)
            };

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult Index(ReportsViewModel viewModel)
        {
            // Refresh the Available reports
            viewModel.Reports = FetchReports(viewModel.SelectedReportId.ToString());

            // Get the Report
            var reportResult = FetchReport(viewModel.SelectedReportId.ToString());

            viewModel.Report = reportResult.Report;
            viewModel.AccessToken = reportResult.AccessToken;

            return View(viewModel);
        }

        #endregion

        #region - Private Methods -

        private SelectList FetchReports(string reportId)
        {
            var devToken = PowerBIToken.CreateDevToken(ConfigHelper.PowerbiWorkspaceCollection, ConfigHelper.PowerbiWorkspaceId);

            using (var client = CreatePowerBIClient(devToken))
            {
                var reportsResponse = client.Reports.GetReports(ConfigHelper.PowerbiWorkspaceCollection, ConfigHelper.PowerbiWorkspaceId.ToString());

                return new SelectList(reportsResponse.Value.ToList(), "Id", "Name", reportId);
            }
        }

        public FetchReportResult FetchReport(string reportId)
        {
            var devToken = PowerBIToken.CreateDevToken(ConfigHelper.PowerbiWorkspaceCollection, ConfigHelper.PowerbiWorkspaceId);
            using (var client = CreatePowerBIClient(devToken))
            {
                var reports = client.Reports.GetReports(ConfigHelper.PowerbiWorkspaceCollection, ConfigHelper.PowerbiWorkspaceId.ToString());
                var report = reports.Value.FirstOrDefault(r => r.Id == reportId);

                var embedToken = PowerBIToken.CreateReportEmbedToken(ConfigHelper.PowerbiWorkspaceCollection, ConfigHelper.PowerbiWorkspaceId, Guid.Parse(report.Id));

                var result = new FetchReportResult
                {
                    Report = report,
                    AccessToken = embedToken.Generate(ConfigHelper.PowerbiSigningKey)
                };

                return result;
            }
        }

        private IPowerBIClient CreatePowerBIClient(PowerBIToken token)
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

        #region - FetchReportResult Class -

        public class FetchReportResult
        {
            public Report Report { get; set; }
            public string AccessToken { get; set; }
        }

        #endregion
    }
}
