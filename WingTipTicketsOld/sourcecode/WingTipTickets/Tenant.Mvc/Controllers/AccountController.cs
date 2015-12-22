using System.Linq;
using System.Web.Mvc;
using Tenant.Mvc.Models.CustomersDB;
using Tenant.Mvc.Repositories;

namespace Tenant.Mvc.Controllers
{
    public class AccountController : BaseController
    {
        #region - Fields -

        private readonly TicketsRepository _ticketsRepository;

        #endregion

        #region - Constructors -

        public AccountController()
        {
            _ticketsRepository = new TicketsRepository(DisplayMessage);
        }

        #endregion

        #region  - Page Helpers -

        [HttpPost]
        public ActionResult Login(string loginUsername, string loginPassword)
        {
            if (string.IsNullOrWhiteSpace(loginUsername) || string.IsNullOrWhiteSpace(loginPassword))
            {
                DisplayMessage("Please type your email and password.");
            }
            else
            {
                _ticketsRepository.CustomerDbContext.Login(loginUsername, loginPassword);
            }

            if (ControllerContext.HttpContext.Request.UrlReferrer != null)
            {
            return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
        }

            return RedirectToAction("Index", "Home");
        }

        public ActionResult Logout()
        {
            if (Session["SessionUser"] != null)
            {
                if (Startup.SessionUsers.Contains(Session["SessionUser"] as Customer))
                {
                    Startup.SessionUsers.Remove(Session["SessionUser"] as Customer);
                    Session["SessionUser"] = null;
                }
            }

            return RedirectToAction("Index", "Home");
        }

        [HttpPost]
        public ActionResult Register(string firstName, string lastName, string email, string phonenumber, string confirmEmail, string password, string confirmPassword)
        {
            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
            {
                DisplayMessage("Please type your email and password.");
            }
            else if (email != confirmEmail || password != confirmPassword)
            {
                DisplayMessage("Confirmation fields need to match for email and password.");
            }
            else if (Startup.SessionUsers.Any(a => a.Email == email))
            {
                    DisplayMessage("User already exists in session.");
            }
                else
            {
                _ticketsRepository.CustomerDbContext.CreateUser(firstName, lastName, email, phonenumber, password);
        }

            if (ControllerContext.HttpContext.Request.UrlReferrer != null)
                {
                return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
            }

            return RedirectToAction("Index", "Home");
        }

        #endregion
    }
}