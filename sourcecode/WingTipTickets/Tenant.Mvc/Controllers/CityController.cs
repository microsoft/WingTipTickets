using System.Web.Mvc;
using Tenant.Mvc.Repositories;

namespace Tenant.Mvc.Controllers
{
    public class CityController : BaseController
    {
        #region - Fields -

        private readonly TicketsRepository _mainRepository;

        #endregion

        #region - Controllers -

        public CityController()
        {
            _mainRepository = new TicketsRepository(DisplayMessage);
        }

        #endregion

        #region - Index View -

        public ActionResult Index(int cityId = 0)
        {
            return View(_mainRepository.GenerateEventListView(0, cityId));
        }

        #endregion
    }
}