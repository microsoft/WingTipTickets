using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;
using Tenant.Mvc.Models.CustomersDB;
using Tenant.Mvc.Models.VenuesDB;
using Tenant.Mvc.Repositories;

namespace Tenant.Mvc.Controllers
{
    public class AccountAdministrationController : Controller
    {
        public TicketsRepository MainRepository { get; private set; }

        public AccountAdministrationController()
        {
            MainRepository = new TicketsRepository(DisplayMessage);
        }

        private void DisplayMessage(string msg)
        {

        }

        public ActionResult Index()
        {
            return View(MainRepository.customerDbContext.GetUsers());
        }
    }
}