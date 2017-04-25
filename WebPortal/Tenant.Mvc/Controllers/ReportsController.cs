using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading;
using System.Web;
using System.Web.Mvc;
using Microsoft.PowerBI.Security;
using Microsoft.Rest;
using Tenant.Mvc.Core.Helpers;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Models;
using WingTipTickets;
using Microsoft.PowerBI.Api.V1.Models;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Controllers
{
    public class ReportsController : BaseController
    {
        #region - Fields -

        private const string DefaultReportCode = "DefaultReportId";
        
        private readonly IApplicationDefaultsRepository _defaultsRepository;
        private readonly IVenueRepository _venueRepository;
        private readonly ISeatSectionRepository _seatSectionRepository;
        private readonly IDiscountRepository _discountRepository;
        private string _defaultReportId = null;

        #endregion

        #region - Controllers -

        public ReportsController(IApplicationDefaultsRepository defaultsRepository, IVenueRepository venueRepository, ISeatSectionRepository seatSectionRepository, IDiscountRepository discountRepository)
        {
            // Setup Fields
            _defaultsRepository = defaultsRepository;
            _venueRepository = venueRepository;
            _seatSectionRepository = seatSectionRepository;
            _discountRepository = discountRepository;

            // Setup Callbacks
            _defaultsRepository.StatusCallback = DisplayMessage;

            // Setup Default ReportId
            _defaultReportId = _defaultsRepository.GetApplicationDefault(DefaultReportCode);
        }

        #endregion

        #region - Index View -

        [HttpGet]
        public ActionResult Index()
        {
            ReportsViewModel viewModel;

            // Get the default report
            var reportList = PowerBiHelper.FetchReports(ConfigHelper.SeatMapReportId);
            var reportDefault = PowerBiHelper.FetchReport(_defaultReportId);

            // Build up the view model
            viewModel = reportDefault.Report != null
                ? new ReportsViewModel()
                {
                    SelectedReportId = new Guid(reportDefault.Report.Id),
                    Reports = new SelectList(reportList, "Id", "Name", _defaultReportId),
                    Report = reportDefault.Report,
                    AccessToken = PowerBiHelper.CreatePowerBiToken(reportDefault.Report.Id)
                }
                : new ReportsViewModel()
                {
                    SelectedReportId = Guid.Empty,
                    Reports = new SelectList(reportList, "Id", "Name", _defaultReportId),
                    Report = null,
                    AccessToken = string.Empty
                };

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult Index(ReportsViewModel viewModel)
        {
            // Get the selected report
            var reportList = PowerBiHelper.FetchReports(ConfigHelper.SeatMapReportId);
            var reportResult = PowerBiHelper.FetchReport(viewModel.SelectedReportId.ToString());

            // Build up the view model
            viewModel.Reports = new SelectList(reportList, "Id", "Name", _defaultReportId);
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


        [HttpPost]
        public JsonResult ApplyDiscount(string discount, string seatDescription, string venue)
        {
            var splittedString = seatDescription.Split(new string[] {"Seat"}, StringSplitOptions.None);
            venue = "Conrad Fischer Stands";

            //get venueId
            var venueId = _venueRepository.GetVenueIdByVenueName(venue);

            //get initial price and seat section Id
            var seatSection = _seatSectionRepository.GetSeatSection(venueId, splittedString[0]);

            DiscountModel model = new DiscountModel
            {
                Discount = Convert.ToInt32(discount),
                SeatNumber = Convert.ToInt32(splittedString[1]),
                SeatSectionId = seatSection.SeatSectionId,
                InitialPrice = seatSection.TicketPrice,
                FinalPrice = seatSection.TicketPrice - (seatSection.TicketPrice*(Convert.ToDecimal(discount)/100))
            };

            var discountedModel = _discountRepository.ApplyDiscount(model);

            return Json(discountedModel, JsonRequestBehavior.AllowGet);
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
