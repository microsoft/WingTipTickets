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
        
        public HomeController()
        {
            ticketsRepository = new TicketsRepository(msg => DisplayMessage(msg));
            ViewBag.PrimaryDbServerName = ConfigurationManager.AppSettings["PrimaryDatabaseServer"];
        }

        protected override void Initialize(System.Web.Routing.RequestContext requestContext)
        {
            base.Initialize(requestContext);
            ExtractHostingSite();
        }
        #endregion Private Variables / Functions

        #region Account Login, Registration, and Logout
        [HttpPost]
        public ActionResult CurrentCustomerLogin(string loginUsername, string loginPassword)
        {
            if (string.IsNullOrWhiteSpace(loginUsername) || string.IsNullOrWhiteSpace(loginPassword))
                DisplayMessage("Please type your email and password.");
            else
                ticketsRepository.customerDbContext.Login(loginUsername, loginPassword);

            return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
        }

        [HttpPost]
        public ActionResult NewCustomerRegistration(string firstName, string lastName, string email, string confirmEmail, string password, string confirmPassword)
        {
            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
                DisplayMessage("Please type your email and password.");
            else if (email != confirmEmail || password != confirmPassword)
                DisplayMessage("Confirmation fields need to match for email and password.");
            else
            {
                if (Startup.SessionUsers.Any(a => a.Email == email))
                    DisplayMessage("User already exists in session.");
                else
                    ticketsRepository.customerDbContext.CreateUser(firstName, lastName, email, password);
            }

            return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
        }

        public ActionResult Logout()
        {
            if (Session["SessionUser"] != null)
            {
                if (Startup.SessionUsers.Contains(Session["SessionUser"] as Customer))
                {
                    Startup.SessionUsers.Remove(Session["SessionUser"] as Customer);
                    Session["SessionUser"] = null;
                }
            }

            return RedirectToAction("Index", "Home");
        }
        #endregion Account Login, Registration, and Logout

        #region Event View Pages (Home/City/Venue)

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
                //result = View(EventListView.FromSearchHits(searchResult.Select(r => r.Document)));

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
                    var suggestions = await WingtipTicketApp.SearchIndexClient.Documents.SuggestAsync(search,
                                                                                                    "sg",
                                                                                                    new SuggestParameters { UseFuzzyMatching = true },
                                                                                                    CancellationToken.None);

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
        public ActionResult ViewVenue(int venueId = 0)
        {
            return View(ticketsRepository.GenerateEventListView(venueId));
        }
        public ActionResult ViewCity(int cityId = 0)
        {
            return View(ticketsRepository.GenerateEventListView(0, cityId));
        }
        #endregion Event View Pages (Home/City/Venue)

        #region Ticket Purchases
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

        public ActionResult FindSeats(String concertId)
        {
            int intConcertId = 0;
            Int32.TryParse(concertId, out intConcertId);
            if (intConcertId == 0) return RedirectToAction("Index", "Home");
            Concert selectedConcert = ticketsRepository.concertDbContext.GetConcertById(intConcertId);
            if (selectedConcert == null) return RedirectToAction("Index", "Home");
            selectedConcert.Venue = ticketsRepository.venuesDbContext.GetVenueByVenueId(selectedConcert.VenueId);
            if (selectedConcert.Venue == null) return RedirectToAction("Index", "Home");
            selectedConcert.Venue.VenueSeatSections = new List<SeatSection>();
            selectedConcert.Venue.VenueSeatSections.AddRange(ticketsRepository.venuesDbContext.GetSeatMapForVenue(selectedConcert.VenueId));

            var ticketLevelsForSection = ticketsRepository.concertTicketDbContext.GetTicketLevelById(selectedConcert.ConcertId);
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
            return View(selectedConcert);
        }

        #endregion

        #region View My Events
        public ActionResult ViewMyEvents(string venueName = null)
        {
            Customer customer = Session["SessionUser"] as Customer;
            return View(ticketsRepository.GenerateMyEvents(customer, venueName));
        }    
        #endregion View My Events

        #region Admin Portal Views and Actions
        public ActionResult ViewAdminPortal(int artistId = 0, int cityId = 0, int venueId = 0, int eventId = 0)
        {
            #region Populate City, Venue, Events
            var artistList = new List<Performer> { new Performer { ShortName = "<New Artist>", PerformerId = -1 } };
            artistList.AddRange(ticketsRepository.concertDbContext.GetArtists());
            var cityList = new List<City> { new City { CityName = "<New City>", CityId = -1 } };
            cityList.AddRange(ticketsRepository.venuesDbContext.GetCities());
            var venueList = new List<Venue> { new Venue { VenueName = "<New Venue>", VenueId = -1 } };
            if (cityId > 0) venueList.AddRange(ticketsRepository.venuesDbContext.GetVenues(cityId));
            var eventList = new List<Concert> { new Concert { ConcertName = "<New Event>", ConcertId = -1 } };
            if (venueId > 0) eventList.AddRange(ticketsRepository.concertDbContext.GetConcerts(venueId, true));
            #endregion Populate City, Venue, Events

            #region Prepare Selected IDs for new entry visual (-1 denotes <New>)
            if (artistId == 0) artistId = -1;
            if (cityId == 0) cityId = -1;
            if (venueId == 0) venueId = -1;
            Concert selectedConcert = new Concert();
            if (eventId > 0 && eventList.Any(a=> a.ConcertId == eventId))
            {
                selectedConcert = eventList.First(a => a.ConcertId == eventId);
                artistId = selectedConcert.PerformerId;
                artistList.RemoveAll(a => a.PerformerId != selectedConcert.PerformerId);
            }
            else if (eventId == 0 || eventId == -1)
                selectedConcert.ConcertId = -1;
            #endregion Prepare IDs for new entry visual (-1 denotes <New>)

            DataForAdminPortalPage dataForPage = new DataForAdminPortalPage { Artists = artistList, Cities = cityList, Venues = venueList, Events = eventList, SelectedArtist = artistId, SelectedCity = cityId, SelectedVenue = venueId, SelectedEvent = selectedConcert };
            return View(dataForPage);
        }
        
        [HttpPost]
        public ActionResult AddOrDeleteConcert(String eventName, String eventDescription, String eventVenueName, String eventCity, String eventArtist,
                        String eventDay, String eventMonth, String eventYear, String saveToDatabase, String addEvent, String deleteEvent)
        {
            if ((deleteEvent != null) && (String.IsNullOrEmpty(addEvent)))
            {
                var concertId = Request.Form["slctEvent"];
                if (String.IsNullOrEmpty(concertId))
                {
                    DisplayMessage(" Event name is required to delete. Cannot Continue.");
                    return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
                }
                ticketsRepository.DeleteConcert(concertId);
                return RedirectToAction("Index", "Home");
            }

            var selectedArtistId = Request.Form["slctArtist"];
            if ((String.IsNullOrEmpty(selectedArtistId) || Int32.Parse(selectedArtistId) == -1) && String.IsNullOrEmpty(eventArtist))
            {
                DisplayMessage(" Event Artist is empty. Need Artist to Add. Cannot Continue.");
                return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
            }

            // first add artist if it doesn't exist
            Performer artistFromDb = null;
            if (!String.IsNullOrWhiteSpace(eventArtist))
            {
                eventArtist = eventArtist.Trim();
                artistFromDb = ticketsRepository.concertDbContext.GetArtistByName(eventArtist);
                if (artistFromDb == null)
                {
                    // check to ensure that user entered two words, which denote first and last name.
                    if (eventArtist.Count(a=> a == ' ') != 1)
                    {
                        DisplayMessage(String.Format(" Artist name '{0}' must contain one first name and one last name. Cannot Continue.", eventArtist));
                        return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
                    }
                    artistFromDb = ticketsRepository.concertDbContext.AddNewArtist(eventArtist);
                    if (artistFromDb == null)
                    {
                        DisplayMessage(String.Format(" Failed to add new Artist '{0}'. Cannot Continue.", eventArtist));
                        return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
                    }
                }
            }
            else
                artistFromDb = ticketsRepository.concertDbContext.GetArtistById(Int32.Parse(selectedArtistId));


            var selectedCityId = Request.Form["slctCity"];
            if ((String.IsNullOrEmpty(selectedCityId) || Int32.Parse(selectedCityId) == -1) && String.IsNullOrEmpty(eventCity))
            {
                DisplayMessage(" Event CityName is empty. Need CityName to Add. Cannot Continue.");
                return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
            }

            // then add city if it doesn't exist
            City cityFromDb = null;
            if (!String.IsNullOrWhiteSpace(eventCity))
            {
                eventCity = eventCity.Trim();
                cityFromDb = ticketsRepository.venuesDbContext.GetCityByName(eventCity);
                if (cityFromDb == null)
                {
                    cityFromDb = ticketsRepository.venuesDbContext.AddNewCity(eventCity);
                    if (cityFromDb == null)
                    {
                        DisplayMessage(String.Format(" Failed to add new City '{0}'. Cannot Continue.", eventCity));
                        return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
                    }
                }
            }
            else
                cityFromDb = ticketsRepository.venuesDbContext.GetCityById(Int32.Parse(selectedCityId));

            var selectedVenueId = Request.Form["slctVenue"];
            if ((String.IsNullOrEmpty(selectedVenueId) || Int32.Parse(selectedVenueId) == -1) && String.IsNullOrEmpty(eventVenueName))
            {
                DisplayMessage(" Event VenueName is empty. Need Event VenueName to Add. Cannot Continue.");
                return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
            }

            // try to get the venue
            Venue venueForConcert = null;
            if (!String.IsNullOrWhiteSpace(eventVenueName))
            {
                eventVenueName = eventVenueName.Trim();
                venueForConcert = ticketsRepository.venuesDbContext.GetVenues().Where(ven => String.CompareOrdinal(ven.VenueName, eventVenueName) == 0).SingleOrDefault();
            }
            else
                venueForConcert = ticketsRepository.venuesDbContext.GetVenues().Where(ven => ven.VenueId == Int32.Parse(selectedVenueId)).SingleOrDefault();

            // next, add venue if it doesn't exist
            if (venueForConcert == null)
                venueForConcert = ticketsRepository.venuesDbContext.AddNewVenue(eventVenueName, cityFromDb.CityId);

            if (String.IsNullOrWhiteSpace(eventName) || eventDay == "Day" || eventMonth == "Month" || eventYear == "Year")
            {
                DisplayMessage("Event name or date values are invalid. Cannot Continue.");
                return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
            }

            // last, add concert/event
            eventName = eventName.Trim();
            var saveToShardDb = saveToDatabase == "secondary" ? ShardDbServerTargetEnum.Shard : ShardDbServerTargetEnum.Primary;
            DateTime eventDateTime = new DateTime(Int32.Parse(eventYear), (int)Enum.Parse(typeof(MonthsEnum), eventMonth), Int32.Parse(eventDay), 20, 0, 0);
            if (ticketsRepository.concertDbContext.SaveNewConcert(eventName, eventDescription, eventDateTime, saveToShardDb, venueForConcert.VenueId, artistFromDb.PerformerId) == null)
            {
                DisplayMessage(String.Format(" Failed to add new concert event. \'{0}\'", eventName));
                return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
            }
            else // concert was successfully added
            {                
                DisplayMessage(string.Format("Successfully added new event {0}.", eventName));
                return RedirectToAction("Index", "Home");
            }
        }

        #endregion

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