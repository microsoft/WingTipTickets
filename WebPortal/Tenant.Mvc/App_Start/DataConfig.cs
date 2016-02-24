using Microsoft.Azure.Search;
using WingTipTickets;

namespace Tenant.Mvc
{
    public class DataConfig
    {
        #region - Public Methods -

        public static void Configure()
        {
            var searchServiceClient = new SearchServiceClient(WingtipTicketApp.Config.SearchServiceName, new SearchCredentials(WingtipTicketApp.Config.SearchServiceKey));

            WingtipTicketApp.SearchIndexClient = searchServiceClient.Indexes.GetClient("concerts");
        }

        #endregion
    }
}
