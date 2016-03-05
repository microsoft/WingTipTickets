using System.Linq;
using System.Web.Mvc;
using System.Web.Security;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Controllers
{
    public class AccountController : BaseController
    {
        #region - Fields -

        private readonly ICustomerRepository _customerRepository;

        #endregion

        #region - Constructors -

        public AccountController(ICustomerRepository customerRepository)
        {
            // Setup Fields
            _customerRepository = customerRepository;

            // Setup Callbacks
            _customerRepository.StatusCallback = DisplayMessage;
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

            if (_customerRepository.Login(loginUsername, loginPassword))
            {
                var customer = (CustomerModel)Session["SessionUser"];

                FormsAuthentication.RedirectFromLoginPage(string.Format("{0} {1}", customer.FirstName, customer.LastName), false);
            }
            else
            {
                DisplayMessage("The username and password supplied is not correct.");
            }

            return RedirectToAction("Index", "Home");
        }

        public ActionResult Logout()
        {
            if (User.Identity.IsAuthenticated)
            {
                if (Startup.SessionUsers.Contains(Session["SessionUser"] as CustomerModel))
                {
                    Startup.SessionUsers.Remove(Session["SessionUser"] as CustomerModel);
                    Session["SessionUser"] = null;
                }

                FormsAuthentication.SignOut();
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

            if (_customerRepository.CreateUser(firstName, lastName, email, phonenumber, password))
            {
                FormsAuthentication.RedirectFromLoginPage(email, true);
            }

            return RedirectToAction("Index", "Home");
        }

        #endregion
    }
}