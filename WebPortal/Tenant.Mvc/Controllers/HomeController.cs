using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Mvc;

using Tenant.Mvc.Core.Helpers;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models;
using Microsoft.Azure.Search.Models;
using WingTipTickets;

namespace Tenant.Mvc.Controllers
{
    public class HomeController : BaseController
    {
        #region - Fields -

        private readonly IConcertRepository _concertRepository;
        private readonly IVenueRepository _venueRepository;

        #endregion

        #region - Constructors -

        public HomeController(IConcertRepository concertRepository, IVenueRepository venueRepository)
            : base(concertRepository, venueRepository)
        {
            // Setup Fields
            _concertRepository = concertRepository;
            _venueRepository = venueRepository;

            // Setup Callbacks
            concertRepository.StatusCallback = DisplayMessage;
            venueRepository.StatusCallback = DisplayMessage;
        }

        #endregion

        #region - Index View -

        public async Task<ActionResult> Index()
        {
            ConcertListViewModel viewModel;

            var search = Request["search"];

            if (string.IsNullOrEmpty(search))
            {
                viewModel = GetConcerts();
            }
            else
            {
                var searchTask = await WingtipTicketApp.SearchIndexClient.Documents.SearchAsync<ConcertSearchHit>(search, new SearchParameters(), CancellationToken.None);
                var searchResults = searchTask.Results;

                viewModel = searchResults.Any(r => r.Document.FullTitle == search) 
                    ? GetSearchedConcert(searchResults, search) 
                    : await GetSearchedConcerts(search);
            }

            return View(viewModel);
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

        public ActionResult Reset(bool fullReset = false)
        {
            var noErrors = DataHelper.RefreshConcerts(fullReset);

            if (noErrors)
            {
                DisplayMessage("Finished Resetting Environment");
            }

            return new RedirectResult("http://" + HttpContext.Request.Url.Host + ":" + HttpContext.Request.Url.Port);
        }

        public ActionResult Reset_RefreshConcerts(bool FullReset = false)
        {
            if (DataHelper.RefreshConcerts(FullReset))
            {
                DisplayMessage("Finished Resetting Environment");
            }

            return new RedirectResult("http://" + HttpContext.Request.Url.Host + ":" + HttpContext.Request.Url.Port);
        }

        #endregion

        #region - Private Methods -

        private ConcertListViewModel GetSearchedConcert(IEnumerable<SearchResult<ConcertSearchHit>> searchResults, string searchValue)
        {
            // If search result matches a single event
            var intConcertId = Convert.ToInt32(searchResults.First(r => r.Document.FullTitle == searchValue).Document.ConcertId);
            var selectedConcert = _concertRepository.GetConcertById(intConcertId);
            var venuesList = _venueRepository.GetVenues();
            var selectedConcertVenue = venuesList.Find(v => v.VenueId.Equals(selectedConcert.VenueId));

            selectedConcert.VenueModel = selectedConcertVenue;

            return new ConcertListViewModel()
            {
                ConcertList = new List<ConcertListViewModel.ConcertViewModel>()
                {
                    new ConcertListViewModel.ConcertViewModel()
                    {
                        ConcertId = selectedConcert.ConcertId,
                        Name = selectedConcert.ConcertName,
                        Date = selectedConcert.ConcertDate,
                        Performer = selectedConcert.PerformerModel.ShortName,
                        Venue = selectedConcert.VenueModel.VenueName
                    }
                },
                VenueList = venuesList.Select(v => new ConcertListViewModel.VenueViewModel()
                {
                    VenueId = v.VenueId,
                    VenueName = v.VenueName,
                    CityId = v.VenueCityModel.CityId,
                    CityName = v.VenueCityModel.CityName,
                    StateId = v.VenueCityModel.StateModel.StateId,
                    StateName = v.VenueCityModel.StateModel.StateName,
                    ConcertCount = v.ConcertQty
                }).ToList()
            };
        }

        private async Task<ConcertListViewModel> GetSearchedConcerts(string searchValue)
        {
            // If search results contains multiple events
            var suggestions = await WingtipTicketApp.SearchIndexClient.Documents.SuggestAsync(searchValue, "sg", new SuggestParameters
            {
                UseFuzzyMatching = true
            }, CancellationToken.None);

            var concertList = new List<ConcertModel>(_concertRepository.GetConcerts());
            var venueList = _venueRepository.GetVenues();

            var viewModel = new ConcertListViewModel()
            {
                ConcertList = new List<ConcertListViewModel.ConcertViewModel>(),
                VenueList = venueList.Select(v => new ConcertListViewModel.VenueViewModel()
                {
                    VenueId = v.VenueId,
                    VenueName = v.VenueName,
                    CityId = v.VenueCityModel.CityId,
                    CityName = v.VenueCityModel.CityName,
                    StateId = v.VenueCityModel.StateModel.StateId,
                    StateName = v.VenueCityModel.StateModel.StateName,
                    ConcertCount = v.ConcertQty
                }).ToList()
            };

            foreach (var suggestion in suggestions)
            {
                var suggestedConcert = concertList.Find(c => c.ConcertId.Equals(Convert.ToInt32(suggestion.Document["ConcertId"])));
                var suggestedConcertVenue = venueList.Find(v => v.VenueId.Equals(suggestedConcert.VenueId));

                suggestedConcert.VenueModel = suggestedConcertVenue;
                viewModel.ConcertList.Add(new ConcertListViewModel.ConcertViewModel()
                {
                    ConcertId = suggestedConcert.ConcertId,
                    Name = suggestedConcert.ConcertName,
                    Date = suggestedConcert.ConcertDate,
                    Performer = suggestedConcert.PerformerModel.ShortName,
                    Venue = suggestedConcert.VenueModel.VenueName
                });
            }

            return viewModel;
        }

        #endregion
    }
}