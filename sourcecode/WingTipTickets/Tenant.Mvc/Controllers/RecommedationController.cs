using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Tenant.Mvc.Models;
using Tenant.Mvc.Models.CustomersDB;
using Tenant.Mvc.Models.View;
using Tenant.Mvc.Repositories;
using WingTipTickets;

namespace Tenant.Mvc.Controllers
{
    public class RecommendationController : Controller
    {
        public RecommendationController()
        {
            // nothing to see here: The recommendations site is hosted externally
        }

        public ActionResult Index()
        {
            var config = WingtipTicketApp.Config.RecommendationSiteUrl;
            var uri = String.Empty;

            if (!String.IsNullOrEmpty(config))
            {
                var uriBuilder = new UriBuilder(config);

                var user = Session["SessionUser"] as Customer;
                var queryStringBuilder = HttpUtility.ParseQueryString(uriBuilder.Query);
                if (user != null)
                {
                    queryStringBuilder["UserName"] = String.Format("{0} {1}", user.FirstName, user.LastName);
                }
                else
                {
                    switch (WingtipTicketApp.Config.TenantEventTypeGenre)
                    {
                        case "Pop":
                            queryStringBuilder["BandId"] = "407";
                            break;
                        case "Rock":
                            queryStringBuilder["BandId"] = "40";
                            break;
                        case "Classical":
                            queryStringBuilder["BandId"] = "1681";
                            break;
                    }
                }
                uriBuilder.Query = queryStringBuilder.ToString();

                uri = uriBuilder.ToString();
            }

            var model = new RecommendationModel(uri);
            return View(model);
        }
    }
}