using Tenant.Mvc.Core.Helpers;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Contexts
{
    public partial class DatabaseContext
    {
        #region - Properties -

        public ConcertContext Concerts { get; set; }
        public ConcertTicketContext Tickets { get; set; }
        public CustomerContext Customers { get; set; }
        public PurchaseTicketsModel Purchase { get; set; }
        public VenueContext Venues { get; set; }
        public DiscountContext Discount { get; set; }
        public SeatSectionContext SeatSection { get; set; }
        public AllSeatsContext AllSeats { get; set; }


        #endregion

        #region - Constructors -

        public DatabaseContext()
        {
            Concerts = new ConcertContext();
            Tickets = new ConcertTicketContext();
            Customers = new CustomerContext();
            Purchase = new PurchaseTicketsModel();
            Venues = new VenueContext();
            Discount = new DiscountContext();
            SeatSection = new SeatSectionContext();
            AllSeats = new AllSeatsContext();
        }

        #endregion

        #region - Logging Methods -

        protected static void LogAction(string action)
        {
            var sqlScript = string.Format("INSERT INTO WebSiteActionLog (Action, UpdatedDate) VALUES ('{0}', GETDATE())", action);

            DataHelper.ExecuteNonQuery(sqlScript);
        }

        #endregion
    }
}