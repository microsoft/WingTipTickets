using System.Web.Mvc;
using Tenant.Mvc.Core.Models;
using Tenant.Mvc.Models.DomainModels;

namespace Tenant.Mvc.Models.ViewModels
{
    public class FindSeatsViewModel
    {
        public ConcertViewModel Concert { get; set; }
        public PurchaseViewModel Purchase { get; set; }

        public VenueMetaData VenueMetaData { get; set; }

        public SelectList SeatSections { get; set; }
        public SelectList TicketQuantities { get; set; }
        public SelectList ExpirationMonths { get; set; }
        public SelectList ExpirationYears { get; set; }
    }
}