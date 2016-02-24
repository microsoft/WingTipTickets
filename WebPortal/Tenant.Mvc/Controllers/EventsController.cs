using System.Web.Mvc;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models.DomainModels;

namespace Tenant.Mvc.Controllers
{
    public class EventsController : BaseController
    {
        #region - Fields -

        private readonly ICustomerRepository _customerRepository;

        #endregion

        #region - Controllers -

        public EventsController(ICustomerRepository customerRepository)
        {
            // Setup Fields
            _customerRepository = customerRepository;

            // Setup Callbacks
            _customerRepository.StatusCallback = DisplayMessage;
        }

        #endregion

        #region - Index Views -

        public ActionResult Index(string venueName = null)
        {
            var customer = Session["SessionUser"] as CustomerModel;

            return View(_customerRepository.GetCustomerEvents(customer, venueName));
        }

        #endregion
    }
}