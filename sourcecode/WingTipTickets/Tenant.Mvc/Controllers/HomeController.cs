using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Mvc;
using Microsoft.Azure.Search.Models;
using Tenant.Mvc.Models;
using Tenant.Mvc.Models.ConcertsDB;
using Tenant.Mvc.Models.CustomersDB;
using Tenant.Mvc.Models.VenuesDB;
using Tenant.Mvc.Repositories;
using WingTipTickets;

namespace Tenant.Mvc.Controllers
{
    public class HomeController : Controller
    {
        #region Private Variables / Functions

        private readonly TicketsRepository ticketsRepository;
        private readonly VenueMetaDataRepository venueMetaDataRepository;

        public HomeController()
        {
            venueMetaDataRepository = new VenueMetaDataRepository();
            ticketsRepository = new TicketsRepository(msg => DisplayMessage(msg));
            ViewBag.PrimaryDbServerName = ConfigurationManager.AppSettings["PrimaryDatabaseServer"];
        }

        protected override void Initialize(System.Web.Routing.RequestContext requestContext)
        {
            base.Initialize(requestContext);
            ExtractHostingSite();
        }
        #endregion Private Variables / Functions

        public async Task<ActionResult> Index()
        {
            EventListView eventListView = new EventListView();
            ActionResult result;
            string search = Request["search"];
            if (string.IsNullOrEmpty(search))
            {
                result = View(ticketsRepository.GenerateEventListView());
            }
            else
            {
                var searchResult = await WingtipTicketApp.SearchIndexClient.Documents.SearchAsync<ConcertSearchHit>(search, new SearchParameters(), CancellationToken.None);

                //If search result matches a single event
                if (searchResult.Results.Any(r => r.Document.FullTitle == search))
                {
                    var intConcertId = Convert.ToInt32(searchResult.Results.First(r => r.Document.FullTitle == search).Document.ConcertId);
                    Concert selectedConcert = ticketsRepository.concertDbContext.GetConcertById(intConcertId);

                    List<Venue> venuesList = ticketsRepository.venuesDbContext.GetVenues();
                    Venue selectedConcertVenue = venuesList.Find(v => v.VenueId.Equals(selectedConcert.VenueId));
                    selectedConcert.Venue = selectedConcertVenue;

                    eventListView.ConcertsList.Add(selectedConcert);
                    eventListView.VenuesList = venuesList;

                    result = View("ViewSearchResults", eventListView);
                }

                //If search results contains multiple events
                else
                {
                    var suggestions = await WingtipTicketApp.SearchIndexClient.Documents.SuggestAsync(search, "sg", new SuggestParameters { UseFuzzyMatching = true }, CancellationToken.None);

                    Concert suggestedConcert;
                    Venue suggestedConcertVenue;
                    List<Concert> concertsList = new List<Concert>(ticketsRepository.concertDbContext.GetConcerts());
                    List<Venue> venuesList = ticketsRepository.venuesDbContext.GetVenues();

                    foreach (var suggestion in suggestions)
                    {
                        suggestedConcert = concertsList.Find(c => c.ConcertId.Equals(Convert.ToInt32(suggestion.Document["ConcertId"])));
                        suggestedConcertVenue = venuesList.Find(v => v.VenueId.Equals(suggestedConcert.VenueId));
                        suggestedConcert.Venue = suggestedConcertVenue;

                        eventListView.ConcertsList.Add(suggestedConcert);
                    }

                    result = View("ViewSearchResults", eventListView);
                }
            }
            return result;
        }

        public async Task<ActionResult> AutoCompleteEvents(string term)
        {
            var suggestions = await WingtipTicketApp.SearchIndexClient.Documents.SuggestAsync(term,
                                                                                              "sg",
                                                                                              new SuggestParameters { UseFuzzyMatching = true },
                                                                                              CancellationToken.None);

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

        [HttpPost]
        public ActionResult PurchaseTicketsWithCreditCard(String concertId, String customerId, String ticketPrice, String ticketCount, String seatMapId)
        {
            #region Capture Information
            if (String.IsNullOrEmpty(concertId) || String.IsNullOrEmpty(customerId) || String.IsNullOrEmpty(ticketPrice) || String.IsNullOrEmpty(ticketCount) || String.IsNullOrEmpty(seatMapId))
                return RedirectToAction("Index", "Home");
            if (ticketPrice.IndexOf(".") > 0) ticketPrice = ticketPrice.Substring(0, ticketPrice.IndexOf("."));
            #endregion Capture Information

            #region Purchase Tickets and Display Result
            var ticketsPurchased = ticketsRepository.concertTicketDbContext.WriteNewTicketToDb(new Customer { CustomerId = Int32.Parse(customerId) },
                Int32.Parse(concertId), Int32.Parse(seatMapId), Int32.Parse(ticketPrice), Int32.Parse(ticketCount));
            if (ticketsPurchased != null)
                DisplayMessage(string.Format("Successfully purchased tickets. You now have {0} tickets for this concert. Confirmation # {1}", ticketsPurchased.Count, ticketsPurchased[0].TicketId));
            else
                DisplayMessage("Failed to purchase tickets.");
            #endregion Purchase Tickets and Display Result

            return RedirectToAction("Index", "Home");
        }

        #region Reset Environment
        #region Web Calls
        public ActionResult Reset(bool FullReset = false)
        {
            bool NoErrors = true;
            ResetCode reset = new ResetCode();
            NoErrors = reset.RefreshConcerts(FullReset);
            if (NoErrors == true) DisplayMessage("Finished Resetting Environment");
            return new RedirectResult("http://" + HttpContext.Request.Url.Host + ":" + HttpContext.Request.Url.Port);
        }
        public ActionResult Reset_RefreshConcerts(bool FullReset = false)
        {
            if (new ResetCode().RefreshConcerts(FullReset))
                DisplayMessage("Finished Resetting Environment");
            return new RedirectResult("http://" + HttpContext.Request.Url.Host + ":" + HttpContext.Request.Url.Port);
        }
        #endregion Web Calls
        #endregion Reset Environment

        #region Misc
        private string GetSectionFromPrice(int price)
        {
            string ret = string.Empty;

            switch (Convert.ToInt32(price))
            {
                case 55: ret = "219-221"; break;
                case 60: ret = "218-214"; break;
                case 65: ret = "222-226"; break;
                case 70: ret = "210-213"; break;
                case 75: ret = "201-204"; break;
                case 80: ret = "114-119"; break;
                case 85: ret = "120-126"; break;
                case 90: ret = "104-110"; break;
                case 95: ret = "111-113"; break;
                case 100: ret = "101-103"; break;
            };

            return ret;
        }
        /// <summary> Display alert on page
        /// </summary>
        /// <param name="content"></param>
        private void DisplayMessage(string content)
        {
            if (!string.IsNullOrWhiteSpace(content))
                TempData["msg"] = string.Format("<script>alert(\"{0}\");</script>", content);
        }

        private void ExtractHostingSite()
        {
            var requestUrl = Request.Url;
            var resolvedHostName = new System.Net.IPHostEntry();

            if (!requestUrl.Host.Contains("trafficmanager.net"))
                ViewBag.SiteHostName = requestUrl.Host;
            else
            {
                try
                {
                    resolvedHostName = Dns.GetHostEntry(requestUrl.Host);
                    if (resolvedHostName.HostName.ToString().Contains("waws"))
                    {
                        ViewBag.SiteHostName = Environment.ExpandEnvironmentVariables("%WEBSITE_SITE_NAME%") + ".azurewebsites.net";
                    }
                    else
                    {
                        ViewBag.SiteHostName = resolvedHostName.HostName;
                    }
                }
                catch
                {
                    ViewBag.SiteHostName = String.Format("Unable to resolve host for {0}", requestUrl.Host);
                }
            }
        }
        #endregion
    }
}