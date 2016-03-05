using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using Tenant.Mvc.Core.Enums;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models;

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

            PrepareData(ref artistId, ref cityId, ref venueId, eventId, eventList.ToList(), artistList.ToList());

            return View(new EventAdministrationViewModel
            {
                CityId = cityId,
                VenueId = venueId,
                EventId = eventId,
                ArtistId = artistId,

                Artists = new SelectList(artistList, "Value", "Description", artistId),
                Cities = new SelectList(cityList, "Value", "Description", cityId),
                Venues = new SelectList(venueList, "Value", "Description", venueId),
                Events = new SelectList(eventList, "Value", "Description", eventId),
                Years = GetYears(),
                Months = GetMonths(),
                Days = GetDays(),
            });
        }

        [HttpPost]
        public ActionResult Index(EventAdministrationViewModel viewModel, String addEvent, String deleteEvent)
        {
            #region - Update lookups  -

            viewModel.Artists = new SelectList(PopulateArtists(), "Value", "Description", viewModel.ArtistId);
            viewModel.Cities = new SelectList(PopulateCities(), "Value", "Description", viewModel.CityId);
            viewModel.Venues = new SelectList(PopulateVenues(viewModel.CityId), "Value", "Description", viewModel.VenueId);
            viewModel.Events = new SelectList(PopulateEvents(viewModel.VenueId), "Value", "Description", viewModel.EventId);
            viewModel.Years = GetYears();
            viewModel.Months = GetMonths();
            viewModel.Days = GetDays();

            #endregion

            #region - Delete Event if Requested -

            if ((deleteEvent != null) && (String.IsNullOrEmpty(addEvent)))
            {
                //var concertId = Request.Form["slctEvent"];

                if (viewModel.EventId <= 0)
                {
                    DisplayMessage("Event name is required to delete. Cannot Continue.");

                    return View(viewModel);
                }

                _concertRepository.DeleteConcert(viewModel.EventId);

                return RedirectToAction("Index", "Home");
            }

            #endregion


            #region - Check Artist -

            //var selectedArtistId = Request.Form["slctArtist"];

            if (viewModel.ArtistId == -1 && String.IsNullOrEmpty(viewModel.NewArtist))
            {
                DisplayMessage("Event Artist is empty. Need Artist to Add. Cannot Continue.");
                return View(viewModel);
            }

            #endregion

            #region - Find/Add Artists -

            // First add artist if it doesn't exist
            PerformerModel artistFromDb;

            if (!String.IsNullOrWhiteSpace(viewModel.NewArtist))
            {
                artistFromDb = _artistRepository.GetArtistByName(viewModel.NewArtist.Trim());

                if (artistFromDb == null)
                {
                    // Check to ensure that user entered two words, which denote first and last name.
                    if (viewModel.NewArtist.Count(a => a == ' ') != 1)
                    {
                        DisplayMessage(String.Format("Artist name '{0}' must contain one first name and one last name. Cannot Continue.", viewModel.NewArtist));
                        return View(viewModel);
                    }

                    artistFromDb = _artistRepository.AddNewArtist(viewModel.NewArtist);

                    if (artistFromDb == null)
                    {
                        DisplayMessage(String.Format("Failed to add new Artist '{0}'. Cannot Continue.", viewModel.NewArtist));
                        return View(viewModel);
                    }
                }
            }
            else
            {
                artistFromDb = _artistRepository.GetArtistById(viewModel.ArtistId);
            }

            #endregion


            #region - Check City -

            //var selectedCityId = Request.Form["slctCity"];

            if (viewModel.CityId == -1 && String.IsNullOrEmpty(viewModel.NewCity))
            {
                DisplayMessage(" Event CityName is empty. Need CityName to Add. Cannot Continue.");
                return View(viewModel);
            }

            #endregion

            #region - Find/Add City -

            // Then add city if it doesn't exist
            CityModel cityModelFromDb;

            if (!String.IsNullOrWhiteSpace(viewModel.NewCity))
            {
                cityModelFromDb = _cityRepository.GetCityByName(viewModel.NewCity.Trim());

                if (cityModelFromDb == null)
                {
                    cityModelFromDb = _cityRepository.AddNewCity(viewModel.NewCity);

                    if (cityModelFromDb == null)
                    {
                        DisplayMessage(String.Format(" Failed to add new City '{0}'. Cannot Continue.", viewModel.NewCity));
                        return View(viewModel);
                    }
                }
            }
            else
            {
                cityModelFromDb = _cityRepository.GetCityById(viewModel.CityId);
            }

            #endregion

            #region - Check Venue -

            //var selectedVenueId = Request.Form["slctVenue"];

            if (viewModel.VenueId == -1 && String.IsNullOrEmpty(viewModel.NewVenue))
            {
                DisplayMessage(" Event VenueName is empty. Need Event VenueName to Add. Cannot Continue.");
                return View(viewModel);
            }

            #endregion

            #region - Find/Add Venue -

            // Try to get the venue
            var venueModelForConcert = (!String.IsNullOrWhiteSpace(viewModel.NewVenue) 
                ? _venueRepository.GetVenues().FirstOrDefault(ven => String.CompareOrdinal(ven.VenueName, viewModel.NewVenue.Trim()) == 0) 
                : _venueRepository.GetVenues().FirstOrDefault(ven => ven.VenueId == viewModel.VenueId)) ?? _venueRepository.AddNewVenue(viewModel.NewVenue, cityModelFromDb.CityId);


            #endregion


            #region - Check Event -

            if (String.IsNullOrWhiteSpace(viewModel.NewEvent) || viewModel.Day == -1 || viewModel.Month == -1 || viewModel.Year == -1)
            {
                DisplayMessage("Event name or date values are invalid. Cannot Continue.");
                return View(viewModel);
            }

            #endregion

            #region - Find/Add Event -

            // Last, add concert/event
            const ServerTargetEnum saveToShardDb = ServerTargetEnum.Primary;
            var eventDateTime = new DateTime(viewModel.Year, viewModel.Month, viewModel.Day, 20, 0, 0);

            if (_concertRepository.SaveNewConcert(viewModel.NewEvent, viewModel.Description, eventDateTime, saveToShardDb, venueModelForConcert.VenueId, artistFromDb.PerformerId) == null)
            {
                DisplayMessage(String.Format(" Failed to add new concert event. \'{0}\'", viewModel.NewEvent));
                return View(viewModel);
            }

            DisplayMessage(string.Format("Successfully added new event {0}.", viewModel.NewEvent));

            return RedirectToAction("Index", "Home");

            #endregion
        }

        #endregion

        #region - Private Methods -

        private SelectList GetYears()
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

        private SelectList GetMonths()
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

        private SelectList GetDays(int? year = null, int? month = null)
        {
            // Get days available in month
            var daysInMonth = year != null && month != null 
                ? DateTime.DaysInMonth((int)year, (int)month) 
                : 31;

            var items = new List<LookupViewModel>()
            {
                new LookupViewModel(null, "Day")
            };

            for (var i = 1; i <= daysInMonth; i++)
            {   
                items.Add(new LookupViewModel(i, i.ToString()));
            }

            return new SelectList(items, "Value", "Description", null);
        }

        private IEnumerable<LookupViewModel> PopulateEvents(int venueId)
        {
            var eventList = new List<LookupViewModel>()
            {
                new LookupViewModel (-1, "<New Event>")
            };

            foreach (var venue in _concertRepository
                .GetConcerts(venueId, true)
                .Select(c => new LookupViewModel(c.ConcertId, c.ConcertName)))
            {
                if (eventList.All(v => v.Value != venue.Value))
                {
                    eventList.Add(venue);
                }
            }

            return eventList;
        }

        private IEnumerable<LookupViewModel> PopulateCities()
        {
            var cityList = new List<LookupViewModel>()
            {
                new LookupViewModel(-1, "<New City>")
            };

            foreach (var venue in _cityRepository
                .GetCities()
                .Select(c => new LookupViewModel(c.CityId, c.CityName)))
            {
                if (cityList.All(v => v.Value != venue.Value))
                {
                    cityList.Add(venue);
                }
            }

            return cityList;
        }

        private IEnumerable<LookupViewModel> PopulateArtists()
        {
            var artistList = new List<LookupViewModel>()
            {
                new LookupViewModel(-1, "<New Artist>")
            };

            foreach (var venue in _artistRepository
                .GetArtists()
                .Select(a => new LookupViewModel(a.PerformerId, a.ShortName)))
            {
                if (artistList.All(v => v.Value != venue.Value))
                {
                    artistList.Add(venue);
                }
            }

            return artistList;
        }

        private IEnumerable<LookupViewModel> PopulateVenues(int cityId)
        {
            var venueList = new List<LookupViewModel>()
            {
                new LookupViewModel(-1, "<New Venue>")
            };

            foreach (var venue in _venueRepository
                    .GetVenues(cityId: cityId)
                    .Select(v => new LookupViewModel(v.VenueId, v.VenueName)))
            {
                if (venueList.All(v => v.Value != venue.Value))
                {
                    venueList.Add(venue);
                }
            }

            return venueList.Distinct();
        }

        private void PrepareData(ref int artistId, ref int cityId, ref int venueId, int eventId, List<LookupViewModel> eventList, List<LookupViewModel> artistList)
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

            if (eventId > 0 && eventList.Any(a => a.Value != null && (int)a.Value == eventId))
            {
                selectedConcert = _concertRepository.GetConcerts(venueId, true).First(a => a.ConcertId == eventId);

                artistId = selectedConcert.PerformerId;

                artistList.RemoveAll(a => a.Value != selectedConcert.PerformerId);
            }
            else if (eventId == 0 || eventId == -1)
            {
                selectedConcert.ConcertId = -1;
            }
        }

        #endregion
    }
}
