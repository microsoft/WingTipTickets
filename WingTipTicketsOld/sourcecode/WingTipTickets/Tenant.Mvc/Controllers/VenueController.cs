using System.Web.Mvc;
using Tenant.Mvc.Repositories;

namespace Tenant.Mvc.Controllers
{
    public class VenueController : BaseController
    {
        #region - Fields -

        private readonly TicketsRepository _mainRepository;

        #endregion

        #region - Controllers -

        public VenueController()
        {
            _mainRepository = new TicketsRepository(DisplayMessage);
        }

        #endregion

        #region - Index View -

        public ActionResult Index(int venueId = 0)
        {
            return View(_mainRepository.GenerateEventListView(venueId));
        }

        #endregion
    }
}