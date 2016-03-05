using System.Web.Mvc;
using Tenant.Mvc.Core.Interfaces.Tenant;

namespace Tenant.Mvc.Controllers
{
    public class CityController : BaseController
    {
        #region - Controllers -

        public CityController(IConcertRepository concertRepository, IVenueRepository venueRepository)
            : base(concertRepository, venueRepository)
        {
            // Setup Callbacks
            concertRepository.StatusCallback = DisplayMessage;
        }

        #endregion

        #region - Index View -

        public ActionResult Index(int cityId = 0)
        {
            var viewModel = GetConcerts(0, cityId);

            return View(viewModel);
        }

        #endregion
    }
}