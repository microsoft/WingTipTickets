using System.Web;
using System.Web.Mvc;
using Microsoft.Owin.Security;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.OpenIdConnect;
using TenantProvisioning.Core.Helpers;
using TenantProvisioning.Core.Services;

namespace TenantProvisioning.Mvc.Controllers
{
    public class AccountController : Controller
    {
        public void SignIn(string directoryName = "common", bool isMsa = false, bool redirectToSignUp = false)
        {
            // Clear the Session object to eliminate the redirect loop 
            Session.RemoveAll();

            if (!Request.IsAuthenticated)
            {
                // Note configuration (keys, etc…) will not necessarily understand this authority.
                HttpContext.GetOwinContext().Environment.Add("Authority", string.Format(Settings.LoginUri + "OAuth2/Authorize", directoryName));

                if (isMsa)
                {
                    HttpContext.GetOwinContext().Environment.Add("DomainHint", "live.com");
                }

                var uri = Url.Action("Authenticated", "Account", new { redirectToSignUp = redirectToSignUp });
                HttpContext.GetOwinContext().Authentication.Challenge(new AuthenticationProperties { RedirectUri = uri }, OpenIdConnectAuthenticationDefaults.AuthenticationType);
            }
        }

        [HttpGet]
        public ActionResult SignOut()
        {
            HttpContext.GetOwinContext().Authentication.SignOut(OpenIdConnectAuthenticationDefaults.AuthenticationType, CookieAuthenticationDefaults.AuthenticationType);

            return RedirectToAction("Index", "Home");
        }

        [HttpGet]
        public ActionResult Authenticated(bool redirectToSignUp = false)
        {
            return RedirectToAction("Index", redirectToSignUp ? "SignUp" : "Home");
        }

        [HttpGet]
        public void DeleteAccount(string username)
        {
            var tenantService = new TenantService();
            tenantService.DeleteTenant(username);
        }
    }
}