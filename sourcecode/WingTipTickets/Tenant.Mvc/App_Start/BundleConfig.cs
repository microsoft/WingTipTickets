using System.Web.Optimization;
using WingTipTickets;

namespace Tenant.Mvc
{
    public class BundleConfig
    {
        public static void RegisterBundles(BundleCollection bundles)
        {
            RegisterScripts(bundles);
            RegisterStyles(bundles);
        }

        private static void RegisterScripts(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                "~/Content/Scripts/jquery-{version}.js"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                "~/Content/Scripts/bootstrap.js"));}

        private static void RegisterStyles(BundleCollection bundles)
        {
            bundles.Add(new StyleBundle("~/styles/site").Include(
                "~/Content/Stylesheets/site.css"));

            bundles.Add(new StyleBundle("~/styles/bootstrap").Include(
                "~/Content/Stylesheets/bootstrap-theme.css",
                "~/Content/Stylesheets/bootstrap.css"));
        }
    }
}
