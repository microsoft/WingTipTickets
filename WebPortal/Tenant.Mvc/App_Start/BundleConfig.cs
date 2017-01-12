using System.Web.Optimization;

namespace Tenant.Mvc
{
    public class BundleConfig
    {
        #region - Public Methods -

        public static void RegisterBundles(BundleCollection bundles)
        {
            RegisterScripts(bundles);
            RegisterStyles(bundles);
        }

        #endregion

        #region - Private Methods -

        private static void RegisterScripts(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                "~/Content/Scripts/jquery-{version}.js",
                "~/Content/Scripts/jquery.ui.widget.js",
                "~/Content/Scripts/jquery.ui-1.11.4.js",
                "~/Content/Scripts/jquery.fileupload.js",
                "~/Content/Scripts/jquery.fileupload-ui.js"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                "~/Content/Scripts/bootstrap.js",
                "~/Content/Scripts/bootstrap-select.js",
                "~/Content/Scripts/respond.js"));

            bundles.Add(new ScriptBundle("~/bundles/powerbi").Include(
                "~/Content/Scripts/powerbi.js"));
        }

        private static void RegisterStyles(BundleCollection bundles)
        {
            bundles.Add(new StyleBundle("~/styles/bootstrap").Include(
                "~/Content/Stylesheets/bootstrap-theme.css",
                "~/Content/Stylesheets/bootstrap.css"));

            bundles.Add(new StyleBundle("~/styles/jquery").Include(
                "~/Content/Stylesheets/jquery.fileupload.css"));

            bundles.Add(new StyleBundle("~/styles/powerbi").Include(
                "~/Content/Stylesheets/powerbi.css"));

            bundles.Add(new StyleBundle("~/styles/site").Include(
                "~/Content/Stylesheets/site.css"));
        }

        #endregion
    }
}
