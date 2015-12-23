using System.Configuration;
using System.Web.Mvc;

namespace Promotions.Controllers
{
    public class VersionController : Controller
    {
        public ActionResult Index()
        {
            // Setup the ViewBag
            ViewBag.LastCheckInBy = ConfigurationManager.AppSettings["LastCheckInBy"];
            ViewBag.LastCheckInDatetime = ConfigurationManager.AppSettings["LastCheckInDateTime"];

            return View();
        }
    }
}