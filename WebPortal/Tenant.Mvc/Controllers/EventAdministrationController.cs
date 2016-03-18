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
            var eventList = PopulateEvents(venueId);

            var viewModel = new EventAdministrationViewModel()
            {
                CityId = cityId,
                VenueId = venueId,
                EventId = eventId,
                ArtistId = artistId,
            };

            PrepareData(ref artistId, ref cityId, ref venueId, eventId, eventList.ToList(), artistList.ToList());
            UpdateLookupValues(viewModel);

            return View(viewModel);
        }

        [HttpPost]
        public ActionResult Index(EventAdministrationViewModel viewModel, String addEvent, String deleteEvent)
        {
            UpdateLookupValues(viewModel);

            // Run operations
            if ((deleteEvent != null) && (String.IsNullOrEmpty(addEvent)))
            {
                if (!DeleteEvent(viewModel))
                {
                    return View(viewModel);
                }
            }
            else
            {
                PerformerModel artistFromDb;
                CityModel cityModelFromDb;
                VenueModel venueModelFromDb;

                // Validate the model
                if (!IsArtistValid(viewModel) || !IsCityValid(viewModel) || !IsVenueValid(viewModel) || !IsEventValid(viewModel))
                {
                    return View(viewModel);
                }

                // Upsert the data
                if (!UpsertArtist(viewModel, out artistFromDb))
                {
                    return View(viewModel);
                }

                if (!UpsertCity(viewModel, out cityModelFromDb))
                {
                    return View(viewModel);
                }

                if (!UpsertVenue(viewModel, cityModelFromDb, out venueModelFromDb))
                {
                    return View(viewModel);
                }

                if (!UpsertEvent(viewModel, venueModelFromDb, artistFromDb))
                {
                    return View(viewModel);
                }
            }

            // Operations succeeded redirect to Home
            return RedirectToAction("Index", "Home");
        }

        #endregion

        #region - Validation Methods -

        private bool IsArtistValid(EventAdministrationViewModel viewModel)
        {
            // Check if New Artist specified
            if (viewModel.ArtistId == -1 && String.IsNullOrEmpty(viewModel.NewArtist))
            {
                DisplayMessage("Event Artist is empty. Need Artist to Add. Cannot Continue.");
                return false;
            }

            // Check to ensure that user entered two words, which denote first and last name
            if (viewModel.ArtistId == -1 && viewModel.NewArtist.Count(a => a == ' ') != 1)
            {
                DisplayMessage(String.Format("Artist name '{0}' must contain one first name and one last name. Cannot Continue.", viewModel.NewArtist));
                return false;
            }

            return true;
        }

        private bool IsCityValid(EventAdministrationViewModel viewModel)
        {
            if (viewModel.CityId == -1 && String.IsNullOrEmpty(viewModel.NewCity))
            {
                DisplayMessage(" Event CityName is empty. Need CityName to Add. Cannot Continue.");
                return false;
            }

            return true;
        }

        private bool IsVenueValid(EventAdministrationViewModel viewModel)
        {
            if (viewModel.VenueId == -1 && String.IsNullOrEmpty(viewModel.NewVenue))
            {
                DisplayMessage(" Event VenueName is empty. Need Event VenueName to Add. Cannot Continue.");
                return false;
            }

            return true;
        }

        private bool IsEventValid(EventAdministrationViewModel viewModel)
        {
            if (string.IsNullOrWhiteSpace(viewModel.NewEvent) || viewModel.Day == -1 || viewModel.Month == -1 || viewModel.Year == -1)
            {
                DisplayMessage("Event name or date values are invalid. Cannot Continue.");
                return false;
            }

            return true;
        }

        #endregion

        #region - Upsert Methods -

        private bool UpsertArtist(EventAdministrationViewModel viewModel, out PerformerModel artistFromDb)
        {
            // Add artist if it doesn't exist
            if (!string.IsNullOrWhiteSpace(viewModel.NewArtist))
            {
                artistFromDb = _artistRepository.GetArtistByName(viewModel.NewArtist.Trim());

                if (artistFromDb == null)
                {
                    artistFromDb = _artistRepository.AddNewArtist(viewModel.NewArtist);

                    if (artistFromDb == null)
                    {
                        DisplayMessage(String.Format("Failed to add new Artist '{0}'. Cannot Continue.", viewModel.NewArtist));
                        return false;
                    }
                }
            }
            else
            {
                artistFromDb = _artistRepository.GetArtistById(viewModel.ArtistId);
            }

            return true;
        }

        private bool UpsertCity(EventAdministrationViewModel viewModel, out CityModel cityModelFromDb)
        {
            // Add city if it doesn't exist
            if (!string.IsNullOrWhiteSpace(viewModel.NewCity))
            {
                cityModelFromDb = _cityRepository.GetCityByName(viewModel.NewCity.Trim());

                if (cityModelFromDb == null)
                {
                    cityModelFromDb = _cityRepository.AddNewCity(viewModel.NewCity);

                    if (cityModelFromDb == null)
                    {
                        DisplayMessage(String.Format(" Failed to add new City '{0}'. Cannot Continue.", viewModel.NewCity));
                        return false;
                    }
                }
            }
            else
            {
                cityModelFromDb = _cityRepository.GetCityById(viewModel.CityId);
            }

            return true;
        }

        private bool UpsertVenue(EventAdministrationViewModel viewModel, CityModel cityModelFromDb, out VenueModel venueModelFromDb)
        {
            // Add venue if it doesn't exist
            if (!string.IsNullOrWhiteSpace(viewModel.NewVenue))
            {
                venueModelFromDb = _venueRepository.GetVenues().FirstOrDefault(ven => String.CompareOrdinal(ven.VenueName, viewModel.NewVenue.Trim()) == 0);

                if (venueModelFromDb == null)
                {
                    venueModelFromDb = _venueRepository.AddNewVenue(viewModel.NewVenue, cityModelFromDb.CityId);

                    if (venueModelFromDb == null)
                    {
                        DisplayMessage(String.Format(" Failed to add new Venue '{0}'. Cannot Continue.", viewModel.NewVenue));
                        return false;
                    }
                }
            }
            else
            {
                venueModelFromDb = _venueRepository.GetVenues().FirstOrDefault(ven => ven.VenueId == viewModel.VenueId);
            }

            return true;
        }

        private bool UpsertEvent(EventAdministrationViewModel viewModel, VenueModel venueModelForConcert, PerformerModel artistFromDb)
        {
            // Add event if it doesn't exist
            const ServerTargetEnum saveToShardDb = ServerTargetEnum.Primary;
            var eventDateTime = new DateTime(viewModel.Year, viewModel.Month, viewModel.Day, 20, 0, 0);

            if (_concertRepository.SaveNewConcert(viewModel.NewEvent, viewModel.Description, eventDateTime, saveToShardDb, venueModelForConcert.VenueId, artistFromDb.PerformerId) == null)
            {
                DisplayMessage(String.Format(" Failed to add new concert event. \'{0}\'", viewModel.NewEvent));
                return false;
            }

            DisplayMessage(string.Format("Successfully added new event {0}.", viewModel.NewEvent));
            return true;
        }

        #endregion

        #region - Delete Methods -

        private bool DeleteEvent(EventAdministrationViewModel viewModel)
        {
            if (viewModel.EventId <= 0)
            {
                DisplayMessage("Event name is required to delete. Cannot Continue.");
                return false;
            }

            _concertRepository.DeleteConcert(viewModel.EventId);
            return true;
        }

        #endregion

        #region - Data Methods -

        private void UpdateLookupValues(EventAdministrationViewModel viewModel)
        {
            viewModel.Artists = new SelectList(PopulateArtists(), "Value", "Description", viewModel.ArtistId);
            viewModel.Cities = new SelectList(PopulateCities(), "Value", "Description", viewModel.CityId);
            viewModel.Venues = new SelectList(PopulateVenues(viewModel.CityId), "Value", "Description", viewModel.VenueId);
            viewModel.Events = new SelectList(PopulateEvents(viewModel.VenueId), "Value", "Description", viewModel.EventId);
            viewModel.Years = GetYears();
            viewModel.Months = GetMonths();
            viewModel.Days = GetDays();
        }

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
                new LookupViewModel (0, "<New Event>")
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
                new LookupViewModel(0, "<New City>")
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
                new LookupViewModel(0, "<New Artist>")
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
                new LookupViewModel(0, "<New Venue>")
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

        #region - Page Helpers -

        
        [HttpGet]
        public JsonResult UpdateLookups(int artistId, int cityId, int venueId, int eventId)
        {
            var viewModel = new EventAdministrationViewModel()
            {
                CityId = cityId,
                VenueId = venueId,
                EventId = eventId,
                ArtistId = artistId,
            };

            UpdateLookupValues(viewModel);

            return Json(new { model = viewModel }, JsonRequestBehavior.AllowGet);
        }

        #endregion
    }
}
