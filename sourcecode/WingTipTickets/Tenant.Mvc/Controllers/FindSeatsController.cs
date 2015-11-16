using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using Tenant.Mvc.Models.ConcertsDB;
using Tenant.Mvc.Models.CustomersDB;
using Tenant.Mvc.Models.VenuesDB;
using Tenant.Mvc.Repositories;

namespace Tenant.Mvc.Controllers
{
    public class FindSeatsController : Controller
    {

        public VenueMetaDataRepository VenueMetaData { get; private set; }
        public TicketsRepository MainRepository { get; private set; }

        public FindSeatsController()
        {
            VenueMetaData = new VenueMetaDataRepository();
            MainRepository = new TicketsRepository(msg => DisplayMessage(msg));
        }

        private void DisplayMessage(string msg)
        {

        }
        // GET: FindSeats
        public async Task<ActionResult> Index(String concertId)
        {
            int intConcertId = 0;
            Int32.TryParse(concertId, out intConcertId);
            if (intConcertId == 0) return RedirectToAction("Index", "Home");
            Concert selectedConcert = MainRepository.concertDbContext.GetConcertById(intConcertId);
            if (selectedConcert == null) return RedirectToAction("Index", "Home");
            selectedConcert.Venue = MainRepository.venuesDbContext.GetVenueByVenueId(selectedConcert.VenueId);
            if (selectedConcert.Venue == null) return RedirectToAction("Index", "Home");
            selectedConcert.Venue.VenueSeatSections = new List<SeatSection>();
            selectedConcert.Venue.VenueSeatSections.AddRange(MainRepository.venuesDbContext.GetSeatMapForVenue(selectedConcert.VenueId));

            var ticketLevelsForSection = MainRepository.concertTicketDbContext.GetTicketLevelById(selectedConcert.ConcertId);
            foreach (var seatSection in selectedConcert.Venue.VenueSeatSections)
            {
                var ticketLevel = ticketLevelsForSection.FirstOrDefault(tl => tl.SeatSectionId == seatSection.SeatSectionId);
                if (ticketLevel != null)
                {
                    seatSection.TicketLevelId = ticketLevel.TicketLevelId;
                    seatSection.TicketPrice = ticketLevel.TicketPrice;
                    switch (Convert.ToInt32(seatSection.TicketPrice))
                    {
                        case 55: seatSection.TicketLevelDescription = "Sections 219-221"; break;
                        case 60: seatSection.TicketLevelDescription = "Sections 218-214"; break;
                        case 65: seatSection.TicketLevelDescription = "Sections 222-226"; break;
                        case 70: seatSection.TicketLevelDescription = "Sections 210-213"; break;
                        case 75: seatSection.TicketLevelDescription = "Sections 201-204"; break;
                        case 80: seatSection.TicketLevelDescription = "Sections 114-119"; break;
                        case 85: seatSection.TicketLevelDescription = "Sections 120-126"; break;
                        case 90: seatSection.TicketLevelDescription = "Sections 104-110"; break;
                        case 95: seatSection.TicketLevelDescription = "Sections 111-113"; break;
                        case 100: seatSection.TicketLevelDescription = "Sections 101-103"; break;
                    }
                }
            }


            ViewBag.VenueMetaData = await VenueMetaData.GetVenueMetaData(selectedConcert.VenueId);
           
            return View(selectedConcert);
        }


        [HttpPost]
        public ActionResult PurchaseTicketsWithCreditCard(String concertId, String customerId, String ticketPrice, String ticketCount, String seatMapId)
        {
            #region Capture Information
            if (String.IsNullOrEmpty(concertId) || String.IsNullOrEmpty(customerId) || String.IsNullOrEmpty(ticketPrice) || String.IsNullOrEmpty(ticketCount) || String.IsNullOrEmpty(seatMapId))
                return RedirectToAction("Index", "Home");
            if (ticketPrice.IndexOf(".") > 0) ticketPrice = ticketPrice.Substring(0, ticketPrice.IndexOf("."));
            #endregion Capture Information

            #region Purchase Tickets and Display Result
            var ticketsPurchased = MainRepository.concertTicketDbContext.WriteNewTicketToDb(new Customer { CustomerId = Int32.Parse(customerId) },
                Int32.Parse(concertId), Int32.Parse(seatMapId), Int32.Parse(ticketPrice), Int32.Parse(ticketCount));
            if (ticketsPurchased != null)
                DisplayMessage(string.Format("Successfully purchased tickets. You now have {0} tickets for this concert. Confirmation # {1}", ticketsPurchased.Count, ticketsPurchased[0].TicketId));
            else
                DisplayMessage("Failed to purchase tickets.");
            #endregion Purchase Tickets and Display Result

            return RedirectToAction("Index", "Home");
        }
    }
}