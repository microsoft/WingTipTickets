using System.Web.Mvc;
using Tenant.Mvc.Core.Interfaces.Tenant;

namespace Tenant.Mvc.Controllers
{
    public class VenueController : BaseController
    {
        #region - Controllers -

        public VenueController(IConcertRepository concertRepository, IVenueRepository venueRepository)
            : base(concertRepository, venueRepository)
        {
            // Setup Callbacks
            concertRepository.StatusCallback = DisplayMessage;
            venueRepository.StatusCallback = DisplayMessage;
        }

        #endregion

        #region - Index View -

        public ActionResult Index(int venueId = 0)
        {
            var viewModel = GetConcerts(venueId);

            return View(viewModel);
        }

        #endregion
    }
}