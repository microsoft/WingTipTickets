using System.Web.Mvc;
using Tenant.Mvc.Core.Interfaces.Tenant;

namespace Tenant.Mvc.Controllers
{
    public class VenueController : BaseController
    {
        #region - Fields -

        private readonly IConcertRepository _concertRepository;

        #endregion

        #region - Controllers -

        public VenueController(IConcertRepository concertRepository)
        {
            // Setup Fields
            _concertRepository = concertRepository;

            // Setup Callbacks
            _concertRepository.StatusCallback = DisplayMessage;
        }

        #endregion

        #region - Index View -

        public ActionResult Index(int venueId = 0)
        {
            return View(_concertRepository.GetConcerts(venueId));
        }

        #endregion
    }
}