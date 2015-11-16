using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using Tenant.Mvc.Models.VenuesDB;
using Tenant.Mvc.Repositories;

namespace Tenant.Mvc.Controllers
{
    public class VenueController : Controller
    {
        
        public TicketsRepository MainRepository { get; private set; }

        public VenueController()
        {
            MainRepository = new TicketsRepository(msg => DisplayMessage(msg));
        }

        private void DisplayMessage(string msg)
        {

        }

        // GET: Venue
        public ActionResult Index(int venueId = 0)
        {
            return View(MainRepository.GenerateEventListView(venueId));
        }

       

    }
}