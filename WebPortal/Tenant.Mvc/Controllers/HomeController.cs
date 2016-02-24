using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Web.Mvc;
using Microsoft.Azure.Search.Models;
using Tenant.Mvc.Core.Helpers;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models.DomainModels;
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
        {
            // Setup Fields
            _concertRepository = concertRepository;
            _venueRepository = venueRepository;

            // Setup Callbacks
            _concertRepository.StatusCallback = DisplayMessage;
            _venueRepository.StatusCallback = DisplayMessage;
        }

        #endregion

        #region - Index View -

        private ConcertListViewModel GetConcerts()
        {
            var domainModel = _concertRepository.GetConcertList();

            return new ConcertListViewModel()
            {
                ConcertsList = domainModel.ConcertsList.Select(c => new ConcertListViewModel.ConcertViewModel()
                {
                    ConcertId = c.ConcertId,
                    Name = c.ConcertName,
                    Date = c.ConcertDate,
                    Performer = c.PerformerModel.ShortName,
                    Venue = c.VenueModel.VenueName
                    
                }).ToList()
            };
        }

        private ConcertListViewModel GetSearchedConcert(IEnumerable<SearchResult<ConcertSearchHit>> searchResults, string searchValue)
        {
            // If search result matches a single event
            var intConcertId = Convert.ToInt32(searchResults.First(r => r.Document.FullTitle == searchValue).Document.ConcertId);
            var selectedConcert = _concertRepository.GetConcertById(intConcertId);

            var venuesList = _venueRepository.GetVenues();
            var selectedConcertVenue = venuesList.Find(v => v.VenueId.Equals(selectedConcert.VenueId));

            selectedConcert.VenueModel = selectedConcertVenue;
            //eventListView.VenuesList = venuesList;

            return new ConcertListViewModel()
            {
                ConcertsList = new List<ConcertListViewModel.ConcertViewModel>()
                {
                    new ConcertListViewModel.ConcertViewModel()
                    {
                        ConcertId = selectedConcert.ConcertId,
                        Name = selectedConcert.ConcertName,
                        Date = selectedConcert.ConcertDate,
                        Performer = selectedConcert.PerformerModel.ShortName,
                        Venue = selectedConcert.VenueModel.VenueName
                    }
                }
            };
        }

        private async Task<ConcertListViewModel> GetSearchedConcerts(string searchValue)
        {
            // If search results contains multiple events
            var suggestions = await WingtipTicketApp.SearchIndexClient.Documents.SuggestAsync(searchValue, "sg", new SuggestParameters
            {
                UseFuzzyMatching = true
            }, CancellationToken.None);

            var concertsList = new List<ConcertModel>(_concertRepository.GetConcerts());
            var venuesList = _venueRepository.GetVenues();

            var viewModel = new ConcertListViewModel()
            {
                ConcertsList = new List<ConcertListViewModel.ConcertViewModel>()
            };

            foreach (var suggestion in suggestions)
            {
                var suggestedConcert = concertsList.Find(c => c.ConcertId.Equals(Convert.ToInt32(suggestion.Document["ConcertId"])));
                var suggestedConcertVenue = venuesList.Find(v => v.VenueId.Equals(suggestedConcert.VenueId));

                suggestedConcert.VenueModel = suggestedConcertVenue;
                viewModel.ConcertsList.Add(new ConcertListViewModel.ConcertViewModel()
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

        public async Task<ActionResult> Index()
        {
            var search = Request["search"];
            ConcertListViewModel viewModel;

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

        public ActionResult ViewSearchResults(ConcertListModel concertListModel)
        {
            return View(concertListModel);
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
    }
}