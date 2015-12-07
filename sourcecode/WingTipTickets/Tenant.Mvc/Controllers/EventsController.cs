using System.Web.Mvc;
using Tenant.Mvc.Models.CustomersDB;
using Tenant.Mvc.Repositories;

namespace Tenant.Mvc.Controllers
{
    public class EventsController : BaseController
    {
        #region - Fields -

        private readonly TicketsRepository _mainRepository;

        #endregion

        #region - Controllers -

        public EventsController()
        {
            _mainRepository = new TicketsRepository(DisplayMessage);
        }

        #endregion

        #region - Index Views -

        public ActionResult Index(string venueName = null)
        {
            var customer = Session["SessionUser"] as Customer;

            return View(_mainRepository.GenerateMyEvents(customer, venueName));
        }

        #endregion
    }
}