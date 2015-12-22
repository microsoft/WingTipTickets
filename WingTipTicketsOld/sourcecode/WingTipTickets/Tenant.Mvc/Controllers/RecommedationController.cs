using System;
using System.Web;
using System.Web.Mvc;
using Tenant.Mvc.Models.CustomersDB;
using Tenant.Mvc.Models.View;
using WingTipTickets;

namespace Tenant.Mvc.Controllers
{
    public class RecommendationController : BaseController
    {
        #region - Index View -

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

                uriBuilder.Query = queryStringBuilder.ToString();
                uri = uriBuilder.ToString();
            }

            var model = new RecommendationModel(uri);

            return View(model);
        }

        #endregion
    }
}