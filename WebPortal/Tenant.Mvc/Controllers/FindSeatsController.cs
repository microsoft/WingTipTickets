using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Core.Repositories.Tenant;
using Tenant.Mvc.Models;
using WingTipTickets;

namespace Tenant.Mvc.Controllers
{
    public class FindSeatsController : BaseController
    {
        #region - Fields -

        private readonly IVenueMetaDataRepository _venueMetaDataRepository;
        private readonly IConcertRepository _concertRepository;
        private readonly ITicketRepository _ticketRepository;
        private readonly IVenueRepository _venueRepository;
        private readonly IFindSeatsRepository _findSeatsRepository;

        #endregion

        #region - Constructors -

        public FindSeatsController(IVenueMetaDataRepository venueMetaDataRepository, IConcertRepository concertRepository, ITicketRepository ticketRepository, IVenueRepository venueRepository, IFindSeatsRepository findSeatsRepository)
        {
            // Setup Fields
            _venueMetaDataRepository = venueMetaDataRepository;
            _concertRepository = concertRepository;
            _ticketRepository = ticketRepository;
            _venueRepository = venueRepository;
            _findSeatsRepository = findSeatsRepository;

            // Setup Callbacks
            _venueMetaDataRepository.StatusCallback = DisplayMessage;
            _concertRepository.StatusCallback = DisplayMessage;
            _ticketRepository.StatusCallback = DisplayMessage;
            _venueRepository.StatusCallback = DisplayMessage;
        }

        #endregion

        #region - Index View -

        public async Task<ActionResult> Index(int concertId)
        {
            if (concertId == 0)
            {
                return RedirectToAction("Index", "Home");
            }

            // Map to ViewModel
            var viewModel = _findSeatsRepository.GetFindSeatsData(concertId);

            // Collections
            viewModel.ExpirationMonths = GetCardExpirationMonths();
            viewModel.ExpirationYears = GetCardExpirationYears();

            // Switch off DocumentDb when running in the Development environment
            VenueMetaData metaData = null;
            if (!WingtipTicketApp.Config.RunningInDev)
            {
                metaData = await _venueMetaDataRepository.GetVenueMetaData(viewModel.Concert.VenueId);
            }

            viewModel.VenueMetaData = 
                metaData != null ? 
                new FindSeatsViewModel.VenueMetaDataViewModel()
                {
                    VenueId = metaData.VenueId,
                    Data = metaData.Data,
                } : null;

            return View(viewModel);
        }

        #endregion

        #region - Page Helpers -

        [HttpPost]
        public ActionResult PurchaseTicketsWithCreditCard(FindSeatsViewModel viewModel)
        {
            // Check Information
            if (!ModelState.IsValid)
            {
                return RedirectToAction("Index", "Home");
            }
            
            // Map to Domain Model
            var domainModel = new PurchaseTicketsModel()
            {
                ConcertId = viewModel.Purchase.ConcertId,
                SeatSectionId = viewModel.Purchase.SeatSectionId,
                Quantity = viewModel.Purchase.Quantity,
                Seats = viewModel.Purchase.Seats.Replace(" ", "").Split(',').ToList(),

                CustomerId = ((CustomerModel)Session["SessionUser"]).CustomerId,
                CustomerName = ((CustomerModel)Session["SessionUser"]).FirstName
            };

            // Purchase Tickets and Display Result
            var ticketsPurchased = _ticketRepository.WriteNewTicketToDb(domainModel);

            DisplayMessage(ticketsPurchased != null 
                ? string.Format("Successfully purchased tickets. You now have {0} tickets for this concert. Confirmation # {1}", ticketsPurchased.Count, ticketsPurchased[0].TicketId) 
                : "Failed to purchase tickets.");

            return RedirectToAction("Index", "Home");
        }

        [HttpGet]
        public JsonResult GetSeatLayout(int ticketLevelId)
        {
            var viewModel = _findSeatsRepository.GetSeatSectionLayout(ticketLevelId);
            
            return Json(new { model = viewModel }, JsonRequestBehavior.AllowGet);
        }

        #endregion

        #region - Private Methods -

        private SelectList GetCardExpirationMonths()
        {
            var items = new List<LookupViewModel>()
            {
                new LookupViewModel(null, "Month")
            };

            for (var i = 1; i <= 12; i++)
            {
                items.Add(new LookupViewModel(i, i.ToString()));
            }

            return new SelectList(items, "Value", "Description", null);
        }

        private SelectList GetCardExpirationYears()
        {
            var items = new List<LookupViewModel>()
            {
                new LookupViewModel(null, "Year")
            };

            for (var i = DateTime.Now.Year; i <= DateTime.Now.Year + 20; i++)
            {
                items.Add(new LookupViewModel(i, i.ToString()));
            }

            return new SelectList(items, "Value", "Description", null);
        }

        #endregion
    }
}