using Newtonsoft.Json;
using System.Threading.Tasks;
using System.Web.Mvc;
using Tenant.Mvc.Models.VenuesDB;
using Tenant.Mvc.Repositories;

namespace Tenant.Mvc.Controllers
{
    public class VenueAdministrationController : BaseController
    {
        #region - Fields -

        private readonly VenueMetaDataRepository _venueMetaData;
        private readonly TicketsRepository _mainRepository;

        #endregion

        #region - Constructors -

        public VenueAdministrationController()
        {
            _venueMetaData = new VenueMetaDataRepository();
            _mainRepository = new TicketsRepository(DisplayMessage);
        }

        #endregion

        #region - Index View -

        public ActionResult Index()
        {
            return View(_mainRepository.VenuesDbContext.GetVenues());
        }

        #endregion

        #region - Edit View -

        [HttpGet]
        public async Task<ActionResult> Edit(int id)
        {
            ViewBag.VenueId = id;
            var metaData = await _venueMetaData.GetVenueMetaData(id) ?? new VenueMetaData
            {
                VenueId = id, Data = new
                {
                }
            };

            return View(metaData);
        }

        [HttpPost]
        public async Task<ActionResult> Edit(int id, string data)
        {
            var deserializedData = JsonConvert.DeserializeObject<dynamic>(data);

            if (ModelState.IsValid)
            {
                await _venueMetaData.SetVenueMetaData(id, deserializedData);
            }

            return RedirectToAction("Index");
        }

        #endregion
    }
}