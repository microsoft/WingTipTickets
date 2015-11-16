using Newtonsoft.Json;
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
    public class VenueAdministrationController : Controller
    {


        public VenueMetaDataRepository VenueMetaData { get; private set; }
        public TicketsRepository MainRepository { get; private set; }

        public VenueAdministrationController()
        {
            VenueMetaData = new VenueMetaDataRepository();
            MainRepository = new TicketsRepository(msg => DisplayMessage(msg));
        }

        private void DisplayMessage(string msg)
        {

        }
        // GET: Venue
        public ActionResult Index()
        {
            return View(MainRepository.venuesDbContext.GetVenues());
        }

        [HttpGet]
        public async Task<ActionResult> Edit(int id)
        {
            ViewBag.VenueId = id;

            VenueMetaData metaData = await VenueMetaData.GetVenueMetaData(id);
            if (metaData == null)
            {
                metaData = new Models.VenuesDB.VenueMetaData();
                Venue venue = MainRepository.venuesDbContext.GetVenues().FirstOrDefault(v => v.VenueId == id);
                metaData.VenueId = id;
                metaData.Data = new
                {
                };
            }
            return View(metaData);
        }

        [HttpPost]
        public async Task<ActionResult> Edit(int id, string data)
        {
            var _data = JsonConvert.DeserializeObject<dynamic>(data);            

            if (ModelState.IsValid)
            {
                await VenueMetaData.SetVenueMetaData(id, _data);
            }
            return RedirectToAction("Index");
        }
    }
}