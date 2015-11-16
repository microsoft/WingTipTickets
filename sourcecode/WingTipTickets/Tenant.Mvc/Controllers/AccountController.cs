using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Tenant.Mvc.Models.CustomersDB;
using Tenant.Mvc.Repositories;

namespace Tenant.Mvc.Controllers
{
    public class AccountController : Controller
    {
        private readonly TicketsRepository ticketsRepository;
        private readonly VenueMetaDataRepository venueMetaDataRepository;

        public AccountController()
        {
            venueMetaDataRepository = new VenueMetaDataRepository();
            ticketsRepository = new TicketsRepository(msg => DisplayMessage(msg));
            ViewBag.PrimaryDbServerName = ConfigurationManager.AppSettings["PrimaryDatabaseServer"];
        }

        private void DisplayMessage(string content)
        {
            //if (!string.IsNullOrWhiteSpace(content))
            //    TempData["msg"] = string.Format("<script>alert(\"{0}\");</script>", content);
        }

        [HttpPost]
        public ActionResult CurrentCustomerLogin(string loginUsername, string loginPassword)
        {
            if (string.IsNullOrWhiteSpace(loginUsername) || string.IsNullOrWhiteSpace(loginPassword))
                DisplayMessage("Please type your email and password.");
            else
                ticketsRepository.customerDbContext.Login(loginUsername, loginPassword);

            return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
        }

        [HttpPost]
        public ActionResult NewCustomerRegistration(string firstName, string lastName, string email, string phonenumber, string confirmEmail, string password, string confirmPassword)
        {
            if (string.IsNullOrWhiteSpace(email) || string.IsNullOrWhiteSpace(password))
                DisplayMessage("Please type your email and password.");
            else if (email != confirmEmail || password != confirmPassword)
                DisplayMessage("Confirmation fields need to match for email and password.");
            else
            {
                if (Startup.SessionUsers.Any(a => a.Email == email))
                    DisplayMessage("User already exists in session.");
                else
                    ticketsRepository.customerDbContext.CreateUser(firstName, lastName, email, phonenumber, password);
            }

            return new RedirectResult(ControllerContext.HttpContext.Request.UrlReferrer.AbsoluteUri);
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
    }
}