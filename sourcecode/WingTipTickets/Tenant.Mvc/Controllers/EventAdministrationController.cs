using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Tenant.Mvc.Models;
using Tenant.Mvc.Models.ConcertsDB;
using Tenant.Mvc.Models.VenuesDB;
using Tenant.Mvc.Repositories;

namespace Tenant.Mvc.Controllers
{
    public class EventAdministrationController : Controller
    {

        private readonly TicketsRepository ticketsRepository;
        private readonly VenueMetaDataRepository venueMetaDataRepository;

        public EventAdministrationController()
        {
            venueMetaDataRepository = new VenueMetaDataRepository();
            ticketsRepository = new TicketsRepository(msg => DisplayMessage(msg));          
        }

        private void DisplayMessage(string msg)
        {

        }

        [HttpGet]
        public ActionResult Index(int artistId = 0, int cityId = 0, int venueId = 0, int eventId = 0)
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
            if (eventId > 0 && eventList.Any(a => a.ConcertId == eventId))
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
        public ActionResult Index(String eventName, String eventDescription, String eventVenueName, String eventCity, String eventArtist,
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
                    if (eventArtist.Count(a => a == ' ') != 1)
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
    }
}