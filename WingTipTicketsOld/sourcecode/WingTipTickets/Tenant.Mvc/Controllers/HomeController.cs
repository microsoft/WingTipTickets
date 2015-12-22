using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Mvc;
using Microsoft.Azure.Search.Models;
using Tenant.Mvc.Models;
using Tenant.Mvc.Models.ConcertsDB;
using Tenant.Mvc.Repositories;
using WingTipTickets;

namespace Tenant.Mvc.Controllers
{
    public class HomeController : BaseController
    {
        #region - Fields -

        private readonly TicketsRepository _ticketsRepository;

        #endregion

        #region - Controllers -

        public HomeController()
        {
            _ticketsRepository = new TicketsRepository(DisplayMessage);
        }

        #endregion

        #region - Index View -

        public async Task<ActionResult> Index()
        {
            ActionResult result;

            var eventListView = new EventListView();
            var search = Request["search"];

            if (string.IsNullOrEmpty(search))
            {
                result = View(_ticketsRepository.GenerateEventListView());
            }
            else
            {
                var searchResult = await WingtipTicketApp.SearchIndexClient.Documents.SearchAsync<ConcertSearchHit>(search, new SearchParameters(), CancellationToken.None);

                if (searchResult.Results.Any(r => r.Document.FullTitle == search))
                {
                    // If search result matches a single event
                    var intConcertId = Convert.ToInt32(searchResult.Results.First(r => r.Document.FullTitle == search).Document.ConcertId);
                    var selectedConcert = _ticketsRepository.ConcertDbContext.GetConcertById(intConcertId);

                    var venuesList = _ticketsRepository.VenuesDbContext.GetVenues();
                    var selectedConcertVenue = venuesList.Find(v => v.VenueId.Equals(selectedConcert.VenueId));

                    selectedConcert.Venue = selectedConcertVenue;
                    eventListView.ConcertsList.Add(selectedConcert);
                    eventListView.VenuesList = venuesList;

                    result = View("ViewSearchResults", eventListView);
                }
                else
                {
                    // If search results contains multiple events
                    var suggestions = await WingtipTicketApp.SearchIndexClient.Documents.SuggestAsync(search, "sg", new SuggestParameters
                    {
                        UseFuzzyMatching = true
                    }, CancellationToken.None);

                    var concertsList = new List<Concert>(_ticketsRepository.ConcertDbContext.GetConcerts());
                    var venuesList = _ticketsRepository.VenuesDbContext.GetVenues();

                    foreach (var suggestion in suggestions)
                    {
                        var suggestedConcert = concertsList.Find(c => c.ConcertId.Equals(Convert.ToInt32(suggestion.Document["ConcertId"])));
                        var suggestedConcertVenue = venuesList.Find(v => v.VenueId.Equals(suggestedConcert.VenueId));

                        suggestedConcert.Venue = suggestedConcertVenue;
                        eventListView.ConcertsList.Add(suggestedConcert);
                    }

                    result = View("ViewSearchResults", eventListView);
                }
            }

            return result;
        }

        #endregion

        #region - Page Helpers -

        public async Task<ActionResult> AutoCompleteEvents(string term)
        {
            var suggestions = await WingtipTicketApp.SearchIndexClient.Documents.SuggestAsync(term, "sg", new SuggestParameters { UseFuzzyMatching = true }, CancellationToken.None);

            return new JsonResult
            {
                JsonRequestBehavior = JsonRequestBehavior.AllowGet,
                Data = suggestions.Select(s => s.Text)
            };
        }

        public ActionResult ViewSearchResults(EventListView eventListView)
        {
            return View(eventListView);
        }

        //[HttpPost]
        //public ActionResult PurchaseTicketsWithCreditCard(String concertId, String customerId, String ticketPrice, String ticketCount, String seatMapId)
        //{
        //    #region Capture Information
        //    if (String.IsNullOrEmpty(concertId) || String.IsNullOrEmpty(customerId) || String.IsNullOrEmpty(ticketPrice) || String.IsNullOrEmpty(ticketCount) || String.IsNullOrEmpty(seatMapId))
        //        return RedirectToAction("Index", "Home");
        //    if (ticketPrice.IndexOf(".") > 0) ticketPrice = ticketPrice.Substring(0, ticketPrice.IndexOf("."));
        //    #endregion Capture Information

        //    #region Purchase Tickets and Display Result
        //    var ticketsPurchased = _ticketsRepository.concertTicketDbContext.WriteNewTicketToDb(new Customer { CustomerId = Int32.Parse(customerId) },
        //        Int32.Parse(concertId), Int32.Parse(seatMapId), Int32.Parse(ticketPrice), Int32.Parse(ticketCount));
        //    if (ticketsPurchased != null)
        //        DisplayMessage(string.Format("Successfully purchased tickets. You now have {0} tickets for this concert. Confirmation # {1}", ticketsPurchased.Count, ticketsPurchased[0].TicketId));
        //    else
        //        DisplayMessage("Failed to purchase tickets.");
        //    #endregion Purchase Tickets and Display Result

        //    return RedirectToAction("Index", "Home");
        //}

        public ActionResult Reset(bool fullReset = false)
        {
            var noErrors = true;
            var reset = new ResetCode();

            noErrors = reset.RefreshConcerts(fullReset);

            if (noErrors)
            {
                DisplayMessage("Finished Resetting Environment");
            }

            return new RedirectResult("http://" + HttpContext.Request.Url.Host + ":" + HttpContext.Request.Url.Port);
        }

        public ActionResult Reset_RefreshConcerts(bool FullReset = false)
        {
            if (new ResetCode().RefreshConcerts(FullReset))
            {
                DisplayMessage("Finished Resetting Environment");
            }

            return new RedirectResult("http://" + HttpContext.Request.Url.Host + ":" + HttpContext.Request.Url.Port);
        }

        #endregion

        //#region - Private Methods -

        //private string GetSectionFromPrice(int price)
        //{
        //    var ret = string.Empty;

        //    switch (Convert.ToInt32(price))
        //    {
        //        case 55: ret = "219-221"; break;
        //        case 60: ret = "218-214"; break;
        //        case 65: ret = "222-226"; break;
        //        case 70: ret = "210-213"; break;
        //        case 75: ret = "201-204"; break;
        //        case 80: ret = "114-119"; break;
        //        case 85: ret = "120-126"; break;
        //        case 90: ret = "104-110"; break;
        //        case 95: ret = "111-113"; break;
        //        case 100: ret = "101-103"; break;
        //    };

        //    return ret;
        //}

        //#endregion
    }
}