using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using Microsoft.PowerBI.Api.Beta;
using Microsoft.PowerBI.Api.Beta.Models;
using Microsoft.PowerBI.Security;
using Microsoft.Rest;
using Tenant.Mvc.Core.Helpers;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Models;
using WingTipTickets;

namespace Tenant.Mvc.Controllers
{
    public class ReportsController : BaseController
    {
        #region - Fields -

        private const string DefaultReportCode = "DefaultReportId";

        #endregion

        #region - Fields -

        private readonly IApplicationDefaultsRepository _defaultsRepository;

        #endregion

        #region - Controllers -

        public ReportsController(IApplicationDefaultsRepository defaultsRepository)
        {
            // Setup Fields
            _defaultsRepository = defaultsRepository;

            // Setup Callbacks
            _defaultsRepository.StatusCallback = DisplayMessage;
        }

        #endregion

        #region - Index View -

        [HttpGet]
        public ActionResult Index()
        {
            // Get the default report
            var defaultReport = PowerBiHelper.FetchReport(_defaultsRepository.GetApplicationDefault(DefaultReportCode));

            // Build up the view model
            var viewModel = new ReportsViewModel()
            {
                SelectedReportId = new Guid(defaultReport.Report.Id),
                Reports = PowerBiHelper.FetchReports(defaultReport.Report.Id),
                Report = defaultReport.Report,
                AccessToken = defaultReport.AccessToken
            };

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult Index(ReportsViewModel viewModel)
        {
            // Get the selected report
            var reportResult = PowerBiHelper.FetchReport(viewModel.SelectedReportId.ToString());

            // Build up the view model
            viewModel.Reports = PowerBiHelper.FetchReports(viewModel.SelectedReportId.ToString());
            viewModel.Report = reportResult.Report;
            viewModel.AccessToken = reportResult.AccessToken;

            return View(viewModel);
        }

        #endregion

        #region - Upload View -

        [HttpGet]
        public ActionResult Upload()
        {
            return View();
        }

        [HttpPost]
        public JsonResult UploadFiles()
        {
            var results = new List<UploadFileViewModel>();

            foreach (string file in Request.Files)
            {
                var postedFile = Request.Files[file];

                if (postedFile == null || postedFile.ContentLength == 0)
                {
                    continue;
                }

                PowerBiHelper.UploadReport(postedFile);
                PowerBiHelper.UpdateConnection();

                results.Add(new UploadFileViewModel()
                {
                    Name = postedFile.FileName,
                    Length = postedFile.ContentLength,
                    Type = postedFile.ContentType
                });
            }

            return Json(results, JsonRequestBehavior.AllowGet);
        }

        #endregion

        #region - Private Methods -

        #endregion

        #region - Page Helpers -

        [HttpPost]
        public JsonResult UpdateDefaultReport(string reportId)
        {
            _defaultsRepository.SetApplicationDefault(DefaultReportCode, reportId);

            return Json(new { succeeded = true }, JsonRequestBehavior.AllowGet);
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
