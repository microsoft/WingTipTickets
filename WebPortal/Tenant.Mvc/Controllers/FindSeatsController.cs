using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Mvc;
using Tenant.Mvc.Models.CustomersDB;
using Tenant.Mvc.Models.VenuesDB;
using Tenant.Mvc.Repositories;

namespace Tenant.Mvc.Controllers
{
    public class FindSeatsController : BaseController
    {
        #region - Fields -

        private readonly VenueMetaDataRepository _venueMetaData;
        private readonly TicketsRepository _mainRepository;

        #endregion

        #region - Constructors -

        public FindSeatsController()
        {
            _venueMetaData = new VenueMetaDataRepository();
            _mainRepository = new TicketsRepository(DisplayMessage);
        }

        #endregion

        #region - Index View -

        public async Task<ActionResult> Index(String concertId)
        {
            // Check ConcertId
            int intConcertId;
            Int32.TryParse(concertId, out intConcertId);

            if (intConcertId == 0)
            {
                return RedirectToAction("Index", "Home");
            }

            // Check Concert Found
            var selectedConcert = _mainRepository.ConcertDbContext.GetConcertById(intConcertId);
            if (selectedConcert == null)
            {
                return RedirectToAction("Index", "Home");
            }

            // Check Venue
            selectedConcert.Venue = _mainRepository.VenuesDbContext.GetVenueByVenueId(selectedConcert.VenueId);
            if (selectedConcert.Venue == null)
            {
                return RedirectToAction("Index", "Home");
            }

            // Build Venue Seat Sections
            selectedConcert.Venue.VenueSeatSections = new List<SeatSection>();
            selectedConcert.Venue.VenueSeatSections.AddRange(_mainRepository.VenuesDbContext.GetSeatMapForVenue(selectedConcert.VenueId));

            // Get Ticket Levels
            var ticketLevelsForSection = _mainRepository.ConcertTicketDbContext.GetTicketLevelById(selectedConcert.ConcertId);
            foreach (var seatSection in selectedConcert.Venue.VenueSeatSections)
            {
                var ticketLevel = ticketLevelsForSection.FirstOrDefault(tl => tl.SeatSectionId == seatSection.SeatSectionId);

                if (ticketLevel != null)
                {
                    seatSection.TicketLevelId = ticketLevel.TicketLevelId;
                    seatSection.TicketPrice = ticketLevel.TicketPrice;

                    switch (Convert.ToInt32(seatSection.TicketPrice))
                    {
                        case 55:
                            seatSection.TicketLevelDescription = "Sections 219-221";
                            break;
                        case 60:
                            seatSection.TicketLevelDescription = "Sections 218-214";
                            break;
                        case 65:
                            seatSection.TicketLevelDescription = "Sections 222-226";
                            break;
                        case 70:
                            seatSection.TicketLevelDescription = "Sections 210-213";
                            break;
                        case 75:
                            seatSection.TicketLevelDescription = "Sections 201-204";
                            break;
                        case 80:
                            seatSection.TicketLevelDescription = "Sections 114-119";
                            break;
                        case 85:
                            seatSection.TicketLevelDescription = "Sections 120-126";
                            break;
                        case 90:
                            seatSection.TicketLevelDescription = "Sections 104-110";
                            break;
                        case 95:
                            seatSection.TicketLevelDescription = "Sections 111-113";
                            break;
                        case 100:
                            seatSection.TicketLevelDescription = "Sections 101-103";
                            break;
                    }
                }
            }

            ViewBag.VenueMetaData = await _venueMetaData.GetVenueMetaData(selectedConcert.VenueId);

            return View(selectedConcert);
        }

        #endregion

        #region - Page Helpers -

        [HttpPost]
        public ActionResult PurchaseTicketsWithCreditCard(String concertId, String customerId, String ticketPrice, String ticketCount, String seatMapId)
        {
            // Check Information
            if (String.IsNullOrEmpty(concertId) || String.IsNullOrEmpty(customerId) || String.IsNullOrEmpty(ticketPrice) || String.IsNullOrEmpty(ticketCount) || String.IsNullOrEmpty(seatMapId))
            {
                return RedirectToAction("Index", "Home");
            }

            if (ticketPrice.IndexOf(".") > 0)
            {
                ticketPrice = ticketPrice.Substring(0, ticketPrice.IndexOf("."));
            }

            // Purchase Tickets and Display Result
            var ticketsPurchased = _mainRepository.ConcertTicketDbContext.WriteNewTicketToDb(new Customer()
            {
                CustomerId = Int32.Parse(customerId)
            },
            Int32.Parse(concertId), Int32.Parse(seatMapId), Int32.Parse(ticketPrice), Int32.Parse(ticketCount));

            DisplayMessage(ticketsPurchased != null 
                ? string.Format("Successfully purchased tickets. You now have {0} tickets for this concert. Confirmation # {1}", ticketsPurchased.Count, ticketsPurchased[0].TicketId) 
                : "Failed to purchase tickets.");

            return RedirectToAction("Index", "Home");
        }

        #endregion
    }
}