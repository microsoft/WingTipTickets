using System.Linq;
using System.Web.Mvc;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models;

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

        public ActionResult Index(int? venueId = null)
        {
            var customer = Session["SessionUser"] as CustomerModel;
            var domainModel = _customerRepository.GetCustomerEvents(customer, venueId);

            var viewModel = new CustomerEventsViewModel()
            {
                TicketList = domainModel.PurchasedTickets.Select(t => new CustomerEventsViewModel.PurchasedTicketViewModel()
                {
                    ConcertId = t.ConcertId,
                    ConcertDate = t.EventDateTime,
                    PerformerId = t.PerformerId,
                    PerformerName = t.PerformerName,
                    VenueId = t.VenueId,
                    VenueName = t.VenueName,
                    SeatName = t.SeatName,
                    SectionName = t.SectionName,
                    TicketQuantity = t.TicketQuantity,
                }).ToList(),
                VenuesList = domainModel.MyVenues.Select(v => new CustomerEventsViewModel.VenueViewModel()
                {
                    VenueId = v.VenueId,
                    VenueName = v.VenueName,
                    Capacity = v.Capacity
                }).ToList()
            };

            return View(viewModel);
        }

        #endregion
    }
}