using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;
using Tenant.Mvc.Core.Helpers;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models;
using WingTipTickets;

namespace Tenant.Mvc.Controllers
{
    public class FindSeatsController : BaseController
    {
        #region - Fields -

        private readonly IConcertRepository _concertRepository;
        private readonly ITicketRepository _ticketRepository;
        private readonly IVenueRepository _venueRepository;
        private readonly IFindSeatsRepository _findSeatsRepository;
        private readonly IDiscountRepository _discountRepository;
        private readonly IAllSeatsRepository _allSeatsRepository;
        private readonly ISeatSectionRepository _seatSectionRepository;

        #endregion

        #region - Constructors -

        public FindSeatsController(IConcertRepository concertRepository, ITicketRepository ticketRepository, IVenueRepository venueRepository, IFindSeatsRepository findSeatsRepository, IDiscountRepository discountRepository, IAllSeatsRepository allSeatsRepository, ISeatSectionRepository seatSectionRepository)
        {
            // Setup Fields
            _concertRepository = concertRepository;
            _ticketRepository = ticketRepository;
            _venueRepository = venueRepository;
            _findSeatsRepository = findSeatsRepository;
            _discountRepository = discountRepository;
            _allSeatsRepository = allSeatsRepository;
            _seatSectionRepository = seatSectionRepository;

            // Setup Callbacks
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

            // Add Collections
            viewModel.ExpirationMonths = GetCardExpirationMonths();
            viewModel.ExpirationYears = GetCardExpirationYears();

            // Get SeatMap
            if (!WingtipTicketApp.Config.RunningInDev)
            {
                var seatMap = PowerBiHelper.FetchReport(ConfigHelper.SeatMapReportId);
                viewModel.SeatMap = seatMap.Report;
                viewModel.AccessToken = seatMap.AccessToken;
            }

            //viewModel.SeatMap.EmbedUrl += "&$filter={BookedSeats/ConcertFilterId} eq " + concertId;

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

            var domainModels = new List<PurchaseTicketsModel>();

            var seats = viewModel.Purchase.Seats.Replace(" ", "").Split(',').ToList();
            var seatSectionId = viewModel.Purchase.SeatSectionId;
            var sectionName = _seatSectionRepository.GetSeatSectionDetails(seatSectionId).Description;
            

            //get concert date to calculate number of days prior concert
            var concertId = viewModel.Purchase.ConcertId;
            var selectedConcert = _concertRepository.GetConcertById(concertId);
            var concertDate = selectedConcert.ConcertDate;
            var daysToConcert = (concertDate - DateTime.Now).Days;

            foreach (var seat in seats)
            {
                //verify if seat has discount
                var discountedSeats = _discountRepository.GetDiscountedSeat(seatSectionId, Convert.ToInt32(seat));

                // Map to Domain Model
                var domainModel = new PurchaseTicketsModel()
                {
                    ConcertId = concertId,
                    SeatSectionId = seatSectionId,
                    Quantity = viewModel.Purchase.Quantity,
                    Seat = seat,
                    CustomerId = ((CustomerModel) Session["SessionUser"]).CustomerId,
                    CustomerName = ((CustomerModel) Session["SessionUser"]).FirstName,
                    TMinusDaysToConcert = daysToConcert
                };

                //there is discount on this seat
                if (discountedSeats.Count > 0)
                {
                    var discountSeatAndSeatSection = discountedSeats.First();
                    domainModel.InitialPrice = discountSeatAndSeatSection.InitialPrice;
                    domainModel.FinalPrice = discountSeatAndSeatSection.FinalPrice;
                    domainModel.Discount = discountSeatAndSeatSection.Discount;
                }

                domainModels.Add(domainModel);

                //update allseats table
                var fullSeatDescription = sectionName + " Seat " + seat;

                int tminusDaysToConcert = 0;
                if (daysToConcert >= 0 && daysToConcert <= 5)
                {
                    tminusDaysToConcert = 5;
                }
                if (daysToConcert > 5 && daysToConcert <= 10)
                {
                    tminusDaysToConcert = 10;
                }
                if (daysToConcert > 10 && daysToConcert <= 15)
                {
                    tminusDaysToConcert = 15;
                }
                if (daysToConcert > 15 && daysToConcert <= 20)
                {
                    tminusDaysToConcert = 20;
                }
                if (daysToConcert > 20 && daysToConcert <= 25)
                {
                    tminusDaysToConcert = 25;
                }

                //update only when number of days is less than 25 days as only 0-25 days is required for probability of sales graph
                if (daysToConcert <= 25)
                {
                    var seatDetails = _allSeatsRepository.GetSeatDetails(fullSeatDescription, tminusDaysToConcert);

                    var count = 0;
                    if (domainModel.Discount == 0)
                    {
                        count = seatDetails.DiscountZero;
                        count++;
                    }
                    else if (domainModel.Discount == 10)
                    {
                        count = seatDetails.DiscountTen;
                        count++;
                    }
                    else if (domainModel.Discount == 20)
                    {
                        count = seatDetails.DiscountTwenty;
                        count++;
                    }
                    else if (domainModel.Discount == 30)
                    {
                        count = seatDetails.DiscountThirty;
                        count++;
                    }

                    _allSeatsRepository.UpdateSeatDetails(Convert.ToInt32(domainModel.Discount),
                        seatDetails.SeatDescription, domainModel.TMinusDaysToConcert, count);
                }
            }


            // Purchase Tickets and Display Result
            var ticketsPurchased = _ticketRepository.WriteNewTicketToDb(domainModels);

            DisplayMessage(ticketsPurchased != null 
                ? string.Format("Successfully purchased tickets. You now have {0} tickets for this concert. Confirmation # {1}", ticketsPurchased.Count, ticketsPurchased[0].TicketId) 
                : "Failed to purchase tickets.");

            return RedirectToAction("Index", "Home");
        }

        [HttpGet]
        public JsonResult GetSeatLayout(int concertId, int ticketLevelId)
        {
            var viewModel = _findSeatsRepository.GetSeatSectionLayout(concertId, ticketLevelId);
            
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