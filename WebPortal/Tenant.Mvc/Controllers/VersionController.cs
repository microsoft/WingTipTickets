using System.Configuration;
using System.Web.Mvc;

namespace Tenant.Mvc.Controllers
{
    public class VersionController : BaseController
    {
        #region - Index View -

        public ActionResult Index()
        {
            // Setup the ViewBag
            ViewBag.LastCheckInBy = ConfigurationManager.AppSettings["LastCheckInBy"];
            ViewBag.LastCheckInDatetime = ConfigurationManager.AppSettings["LastCheckInDateTime"];

            return View();
        }

        #endregion
    }
}