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
    public class CityController : Controller
    {
        public VenueMetaDataRepository VenueMetaData { get; private set; }
        public TicketsRepository MainRepository { get; private set; }

        public CityController()
        {
            VenueMetaData = new VenueMetaDataRepository();
            MainRepository = new TicketsRepository(msg => DisplayMessage(msg));
        }

        private void DisplayMessage(string msg)
        {

        }
        // GET: City
        public ActionResult Index(int cityId = 0)
        {
            return View(MainRepository.GenerateEventListView(0, cityId));
        }
    }
}