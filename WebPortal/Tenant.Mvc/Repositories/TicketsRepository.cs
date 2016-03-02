using System;
using System.Collections.Generic;
using System.Linq;
using Tenant.Mvc.Models;
using Tenant.Mvc.Models.ConcertsDB;
using Tenant.Mvc.Models.ConcertTicketDB;
using Tenant.Mvc.Models.CustomersDB;
using Tenant.Mvc.Models.VenuesDB;
using WingTipTickets;

namespace Tenant.Mvc.Repositories
{
    public class TicketsRepository
    {
        #region - Fields -

        public readonly ConcertDbContext ConcertDbContext = new ConcertDbContext();
        public readonly VenuesDbContext VenuesDbContext = new VenuesDbContext();
        public readonly ConcertTicketDbContext ConcertTicketDbContext = new ConcertTicketDbContext();
        public readonly CustomerDbContext CustomerDbContext = new CustomerDbContext();

        private readonly Action<string> _statusCallback;

        #endregion

        #region - Constructors -

        public TicketsRepository(Action<string> statusCallback)
        {
            _statusCallback = statusCallback;
        }

        #endregion

        #region - Public Methods -

        public EventListView GenerateEventListView(int venueId = 0, int cityId = 0)
        {
            var eventListView = new EventListView
            {
                SelectedVenue = venueId,
                SelectedCity = cityId
            };

            var concertsList = new List<Concert>(ConcertDbContext.GetConcerts().Where(a => DateTime.Compare(a.ConcertDate, DateTime.Today) >= 0));

            // If Concerts have expired, roll dates forward
            if (concertsList.Count < 2)
            {
                if (!new ResetCode().RefreshConcerts(false))
                {
                    // If connection fails, prompt user on troubleshoot steps
                    UpdateStatus(string.Format("ERROR connecting to {0} database server.  Make sure: 1. The database server name, username and password in the web.config are correct, 2. Auditing is enabled on the Database Server, 3. Firewall rules allow access - including Azure Services, and 4. the Database server name resolves using nslookup.", WingtipTicketApp.Config.PrimaryDatabaseServer));
                }
            }

            foreach (var concert in concertsList)
            {
                if (eventListView.VenuesList.All(a => a.VenueId != concert.VenueId))
                {
                    eventListView.VenuesList.Add(VenuesDbContext.GetVenueByVenueId(concert.VenueId));
                }

                eventListView.ConcertsList.Add(concert);
                concert.Venue = eventListView.VenuesList.FirstOrDefault(a => a.VenueId == concert.VenueId);
            }

            return eventListView;
        }

        public MyEventsView GenerateMyEvents(Customer customer, string venueName = null)
        {
            var myEventsView = new MyEventsView();

            if (customer == null)
            {
                return myEventsView;
            }

            var concertTicketsList = ConcertTicketDbContext.ReturnPurchasedTicketsByCustomerId(customer.CustomerId);
            var venuesList = VenuesDbContext.GetVenues();
            var concertsList = new List<Concert>(ConcertDbContext.GetConcerts());
            var ticketLevelsList = ConcertTicketDbContext.GetTicketLevels();

            foreach (var ticket in concertTicketsList)
            {
                var concert = concertsList.Find(c => c.ConcertId.Equals(ticket.ConcertId));

                var tempTicket = new PurchasedTicket(
                    concert.Performer.ShortName,
                    concert.ConcertId,
                    venuesList.Find(v => v.VenueId.Equals(concert.VenueId)).VenueName,
                    1,
                    Convert.ToInt32(ticketLevelsList.Find(l => l.TicketLevelId.Equals(ticket.TicketLevelId)).TicketPrice).ToString(),
                    "N/A",
                    concert.ConcertDate,
                    ticket.ConcertId,
                    concert.VenueId
                    );

                switch (Convert.ToInt32(tempTicket.SectionName))
                {
                    case 55:
                        tempTicket.SectionName = "219-221";
                        break;
                    case 60:
                        tempTicket.SectionName = "218-214";
                        break;
                    case 65:
                        tempTicket.SectionName = "222-226";
                        break;
                    case 70:
                        tempTicket.SectionName = "210-213";
                        break;
                    case 75:
                        tempTicket.SectionName = "201-204";
                        break;
                    case 80:
                        tempTicket.SectionName = "114-119";
                        break;
                    case 85:
                        tempTicket.SectionName = "120-126";
                        break;
                    case 90:
                        tempTicket.SectionName = "104-110";
                        break;
                    case 95:
                        tempTicket.SectionName = "111-113";
                        break;
                    case 100:
                        tempTicket.SectionName = "101-103";
                        break;
                }

                if (myEventsView.PurchasedTickets.Exists(x => x.ConcertId == ticket.ConcertId && x.SectionName == tempTicket.SectionName))
                {
                    var index = myEventsView.PurchasedTickets.FindIndex(x => x.ConcertId == ticket.ConcertId && x.SectionName == tempTicket.SectionName);
                    myEventsView.PurchasedTickets[index].TicketQuantity++;
                }
                else
                {
                    myEventsView.PurchasedTickets.Add(tempTicket);
                }

                // Sort all events by date
                if (myEventsView.PurchasedTickets != null && myEventsView.PurchasedTickets.Count > 0)
                {
                    myEventsView.PurchasedTickets.Sort((a, b) => a.EventDateTime.CompareTo(b.EventDateTime));
                }
            }

            return myEventsView;
        }

        public bool DeleteConcert(String concertId)
        {
            var concertDeleted = false;
            var concertToDelete = ConcertDbContext.GetConcertById(Int32.Parse(concertId));

            if (concertToDelete != null)
            {
                // Delete ALL tickets for this concert, then delete concert
                ConcertTicketDbContext.DeleteAllTicketsForConcert(concertToDelete.ConcertId);
                concertDeleted = ConcertDbContext.DeleteConcert(concertToDelete.ConcertId);
            }

            UpdateStatus(concertDeleted
                             ? string.Format("Successfully deleted concert id #{0} - '{1}'", concertToDelete.ConcertId, concertToDelete.ConcertName)
                             : string.Format("FAILED to delete concert id #{0} - '{1}'", concertToDelete.ConcertId, concertToDelete.ConcertName));

            return concertDeleted;
        }

        #endregion

        #region - Private Methods -
        
        private void UpdateStatus(string message)
        {
            if (_statusCallback != null)
            {
                _statusCallback(message);
            }
        }

        #endregion
    }
}