using System;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Web.Mvc;
using System.Web.Routing;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Models;

namespace Tenant.Mvc.Controllers
{
    public class BaseController : Controller
    {
        #region - Fields -

        private readonly IConcertRepository _concertRepository;
        private readonly IVenueRepository _venueRepository;

        #endregion

        #region - Controllers -

        public BaseController()
        {
            // Set up ViewBag data displayed on screen
            ViewBag.PrimaryDbServerName = ConfigurationManager.AppSettings["PrimaryDatabaseServer"];
        }

        public BaseController(IConcertRepository concertRepository, IVenueRepository venueRepository)
            : this()
        {
            // Setup Fields
            _concertRepository = concertRepository;
            _venueRepository = venueRepository;
        }

        #endregion

        #region - Overidden Methods -

        protected override void Initialize(RequestContext requestContext)
        {
            base.Initialize(requestContext);
            ExtractHostingSite();
        }

        #endregion

        #region - Protected Methods -

        protected ConcertListViewModel GetConcerts(int venueId = 0, int cityId = 0)
        {
            var concertList = _concertRepository.GetConcertList(venueId, cityId);
            var venueList = _venueRepository.GetVenues(venueId, cityId);

            return new ConcertListViewModel()
            {
                ConcertList = concertList.ConcertsList.Select(c => new ConcertListViewModel.ConcertViewModel()
                {
                    ConcertId = c.ConcertId,
                    Name = c.ConcertName,
                    Date = c.ConcertDate,
                    Performer = c.PerformerModel.ShortName,
                    Venue = c.VenueModel.VenueName

                }).ToList(),
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
        }

        protected void DisplayMessage(string content)
        {
            if (!string.IsNullOrWhiteSpace(content))
            {
                TempData["msg"] = string.Format("<script>showAlert(\'{0}\', '{1}');</script>", "Confirmation", content);
            }
        }

        #endregion

        #region - Private Methods -

        private void ExtractHostingSite()
        {
            var requestUrl = Request.Url;

            if (requestUrl == null)
            {
                throw new Exception("No request Url to resolve the Host");
            }

            if (!requestUrl.Host.Contains("trafficmanager.net"))
            {
                ViewBag.SiteHostName = requestUrl.Host;
            }
            else
            {
                try
                {
                    var resolvedHostName = Dns.GetHostEntry(requestUrl.Host);

                    if (resolvedHostName.HostName.Contains("waws"))
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
                    throw new Exception(String.Format("Unable to resolve host for {0}", requestUrl.Host));
                }
            }
        }

        #endregion
    }
}