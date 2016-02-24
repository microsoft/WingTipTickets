using System.Web.Mvc;
using Tenant.Mvc.Core.Interfaces.Tenant;

namespace Tenant.Mvc.Controllers
{
    public class CityController : BaseController
    {
        #region - Fields -

        private readonly IConcertRepository _concertRepository;

        #endregion

        #region - Controllers -

        public CityController(IConcertRepository concertRepository)
        {
            // Setup Fields
            _concertRepository = concertRepository;

            // Setup Callbacks
            _concertRepository.StatusCallback = DisplayMessage;
        }

        #endregion

        #region - Index View -

        public ActionResult Index(int cityId = 0)
        {
            return View(_concertRepository.GetConcertList(0, cityId));
        }

        #endregion
    }
}