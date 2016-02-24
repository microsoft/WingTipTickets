using System.Web.Mvc;
using TenantProvisioning.Mvc.Models;

namespace TenantProvisioning.Mvc.Controllers
{
    public class LoginController : Controller
    {
        #region - Index View -

        [HttpGet]
        public ActionResult Index(bool redirectToSignUp = false)
        {
            // Setup the Initial Model
            var viewModel = new LoginViewModel()
            {
                RedirectToSignUp = redirectToSignUp
            };

            return View(viewModel);
        }

        #endregion
    }
}
