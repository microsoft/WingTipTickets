using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using Tenant.Mvc.Core.Enums;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Controllers
{
    public class EventAdministrationController : BaseController
    {
        #region - Fields -

        private readonly IConcertRepository _concertRepository;
        private readonly IArtistRepository _artistRepository;
        private readonly IVenueRepository _venueRepository;
        private readonly ICityRepository _cityRepository;

        #endregion

        #region - Constructors -

        public EventAdministrationController(IConcertRepository concertRepository, IArtistRepository artistRepository, IVenueRepository venueRepository, ICityRepository cityRepository)
        {
            // Setup Fields
            _concertRepository = concertRepository;
            _artistRepository = artistRepository;
            _venueRepository = venueRepository;
            _cityRepository = cityRepository;

            // Setup Callbacks
            _concertRepository.StatusCallback = DisplayMessage;
            _artistRepository.StatusCallback = DisplayMessage;
            _venueRepository.StatusCallback = DisplayMessage;
            _cityRepository.StatusCallback = DisplayMessage;
        }

        #endregion

        #region - Index View -

        [HttpGet]
        public ActionResult Index(int artistId = 0, int cityId = 0, int venueId = 0, int eventId = 0)
        {
            var artistList = PopulateArtists();
            var cityList = PopulateCities();
            var venueList = PopulateVenues(cityId);
            var eventList = PopulateEvents(venueId);

            var selectedConcert = PrepareData(ref artistId, ref cityId, ref venueId, eventId, eventList, artistList);

            return View(new DataForAdminPortalPage
            {
                Artists = artistList,
                Cities = cityList,
                Venues = venueList,
                Events = eventList,
                SelectedArtist = artistId,
                SelectedCity = cityId,
                SelectedVenue = venueId,
                SelectedEvent = selectedConcert
            });
        }

        [HttpPost]
        public ActionResult Index(String eventName, String eventDescription, String eventVenueName, String eventCity, String eventArtist, String eventDay, String eventMonth, String eventYear, String saveToDatabase, String addEvent, String deleteEvent)
        {
            #region - Delete Event if Requested -

            if ((deleteEvent != null) && (String.IsNullOrEmpty(addEvent)))
            {
                var concertId = Request.Form["slctEvent"];

                if (String.IsNullOrEmpty(concertId))
                {
                    DisplayMessage("Event name is required to delete. Cannot Continue.");

                    return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
                }

                _concertRepository.DeleteConcert(concertId);

                return RedirectToAction("Index", "Home");
            }

            #endregion


            #region - Check Artist -

            var selectedArtistId = Request.Form["slctArtist"];

            if ((String.IsNullOrEmpty(selectedArtistId) || Int32.Parse(selectedArtistId) == -1) && String.IsNullOrEmpty(eventArtist))
            {
                DisplayMessage("Event Artist is empty. Need Artist to Add. Cannot Continue.");
                return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
            }

            #endregion

            #region - Find/Add Artists -

            // First add artist if it doesn't exist
            PerformerModel artistFromDb;

            if (!String.IsNullOrWhiteSpace(eventArtist))
            {
                eventArtist = eventArtist.Trim();
                artistFromDb = _artistRepository.GetArtistByName(eventArtist);

                if (artistFromDb == null)
                {
                    // Check to ensure that user entered two words, which denote first and last name.
                    if (eventArtist.Count(a => a == ' ') != 1)
                    {
                        DisplayMessage(String.Format("Artist name '{0}' must contain one first name and one last name. Cannot Continue.", eventArtist));
                        return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
                    }

                    artistFromDb = _artistRepository.AddNewArtist(eventArtist);

                    if (artistFromDb == null)
                    {
                        DisplayMessage(String.Format("Failed to add new Artist '{0}'. Cannot Continue.", eventArtist));
                        return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
                    }
                }
            }
            else
            {
                artistFromDb = _artistRepository.GetArtistById(Int32.Parse(selectedArtistId));
            }

            #endregion


            #region - Check City -

            var selectedCityId = Request.Form["slctCity"];

            if ((String.IsNullOrEmpty(selectedCityId) || Int32.Parse(selectedCityId) == -1) && String.IsNullOrEmpty(eventCity))
            {
                DisplayMessage(" Event CityName is empty. Need CityName to Add. Cannot Continue.");

                return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
            }

            #endregion

            #region - Find/Add City -

            // Then add city if it doesn't exist
            CityModel cityModelFromDb;

            if (!String.IsNullOrWhiteSpace(eventCity))
            {
                eventCity = eventCity.Trim();
                cityModelFromDb = _cityRepository.GetCityByName(eventCity);

                if (cityModelFromDb == null)
                {
                    cityModelFromDb = _cityRepository.AddNewCity(eventCity);

                    if (cityModelFromDb == null)
                    {
                        DisplayMessage(String.Format(" Failed to add new City '{0}'. Cannot Continue.", eventCity));

                        return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
                    }
                }
            }
            else
            {
                cityModelFromDb = _cityRepository.GetCityById(Int32.Parse(selectedCityId));
            }

            #endregion

            #region - Check Venue -

            var selectedVenueId = Request.Form["slctVenue"];

            if ((String.IsNullOrEmpty(selectedVenueId) || Int32.Parse(selectedVenueId) == -1) && String.IsNullOrEmpty(eventVenueName))
            {
                DisplayMessage(" Event VenueName is empty. Need Event VenueName to Add. Cannot Continue.");

                return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
            }

            #endregion

            #region - Find/Add Venue -

            // Try to get the venue
            VenueModel venueModelForConcert;
            if (!String.IsNullOrWhiteSpace(eventVenueName))
            {
                eventVenueName = eventVenueName.Trim();
                venueModelForConcert = _venueRepository.GetVenues().SingleOrDefault(ven => String.CompareOrdinal(ven.VenueName, eventVenueName) == 0);
            }
            else
            {
                venueModelForConcert = _venueRepository.GetVenues().SingleOrDefault(ven => ven.VenueId == Int32.Parse(selectedVenueId));
            }

            // Next, add venue if it doesn't exist
            if (venueModelForConcert == null)
            {
                venueModelForConcert = _venueRepository.AddNewVenue(eventVenueName, cityModelFromDb.CityId);
            }

            #endregion


            #region - Check Event -

            if (String.IsNullOrWhiteSpace(eventName) || eventDay == "Day" || eventMonth == "Month" || eventYear == "Year")
            {
                DisplayMessage("Event name or date values are invalid. Cannot Continue.");

                return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
            }

            #endregion

            #region - Find/Add Event -

            // Last, add concert/event
            eventName = eventName.Trim();

            var saveToShardDb = saveToDatabase == "secondary" ? ServerTargetEnum.Shard : ServerTargetEnum.Primary;
            var eventDateTime = new DateTime(Int32.Parse(eventYear), (int)Enum.Parse(typeof (MonthsEnum), eventMonth), Int32.Parse(eventDay), 20, 0, 0);

            if (_concertRepository.SaveNewConcert(eventName, eventDescription, eventDateTime, saveToShardDb, venueModelForConcert.VenueId, artistFromDb.PerformerId) == null)
            {
                DisplayMessage(String.Format(" Failed to add new concert event. \'{0}\'", eventName));
                return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
            }

            DisplayMessage(string.Format("Successfully added new event {0}.", eventName));

            return RedirectToAction("Index", "Home");

            #endregion
        }

        #endregion

        #region - Private Methods -

        private List<ConcertModel> PopulateEvents(int venueId)
        {
            var eventList = new List<ConcertModel>
            {
                new ConcertModel
                {
                    ConcertName = "<New Event>", ConcertId = -1
                }
            };

            if (venueId > 0)
            {
                eventList.AddRange(_concertRepository.GetConcerts(venueId, true));
            }

            return eventList;
        }

        private List<CityModel> PopulateCities()
        {
            var cityList = new List<CityModel>
            {
                new CityModel
                {
                    CityName = "<New City>", CityId = -1
                }
            };

            cityList.AddRange(_cityRepository.GetCities());

            return cityList;
        }

        private List<PerformerModel> PopulateArtists()
        {
            var artistList = new List<PerformerModel>
            {
                new PerformerModel
                {
                    ShortName = "<New Artist>", PerformerId = -1
                }
            };

            artistList.AddRange(_artistRepository.GetArtists());

            return artistList;
        }

        private List<VenueModel> PopulateVenues(int cityId)
        {
            var venueList = new List<VenueModel>
            {
                new VenueModel
                {
                    VenueName = "<New Venue>", VenueId = -1
                }
            };

            if (cityId > 0)
            {
                venueList.AddRange(_venueRepository.GetVenues(cityId: cityId));
            }

            return venueList;
        }

        private static ConcertModel PrepareData(ref int artistId, ref int cityId, ref int venueId, int eventId, List<ConcertModel> eventList, List<PerformerModel> artistList)
        {
            #region - Prepare selections -

            if (artistId == 0)
            {
                artistId = -1;
            }

            if (cityId == 0)
            {
                cityId = -1;
            }

            if (venueId == 0)
            {
                venueId = -1;
            }

            #endregion

            var selectedConcert = new ConcertModel();

            if (eventId > 0 && eventList.Any(a => a.ConcertId == eventId))
            {
                selectedConcert = eventList.First(a => a.ConcertId == eventId);
                artistId = selectedConcert.PerformerId;
                artistList.RemoveAll(a => a.PerformerId != selectedConcert.PerformerId);
            }
            else if (eventId == 0 || eventId == -1)
            {
                selectedConcert.ConcertId = -1;
            }

            return selectedConcert;
        }

        #endregion
    }
}
