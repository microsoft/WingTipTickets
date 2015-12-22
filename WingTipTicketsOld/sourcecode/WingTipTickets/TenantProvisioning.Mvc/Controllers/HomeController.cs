using System.Web.Mvc;

namespace TenantProvisioning.Mvc.Controllers
{
    public class HomeController : Controller
    {
        #region - Index View -

        [HttpGet]
        public ActionResult Index()
        {
            var cookies = Request.Cookies;

            return View();
        }

        #endregion
    }
}
