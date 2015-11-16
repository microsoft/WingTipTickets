using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using Tenant.Mvc.Models.CustomersDB;
using Tenant.Mvc.Models.VenuesDB;
using Tenant.Mvc.Repositories;
namespace Tenant.Mvc.Controllers
{
    public class EventsController : Controller
    {

        public VenueMetaDataRepository VenueMetaData { get; private set; }
        public TicketsRepository MainRepository { get; private set; }

        public EventsController()
        {
            VenueMetaData = new VenueMetaDataRepository();
            MainRepository = new TicketsRepository(msg => DisplayMessage(msg));
        }

        private void DisplayMessage(string msg)
        {

        }
        // GET: Events
        public ActionResult Index(string venueName = null)
        {
            Customer customer = Session["SessionUser"] as Customer;
            return View(MainRepository.GenerateMyEvents(customer, venueName));
        }
    }
}