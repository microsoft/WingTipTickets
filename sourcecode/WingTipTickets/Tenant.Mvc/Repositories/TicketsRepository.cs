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
        public readonly ConcertDbContext concertDbContext = new ConcertDbContext();
        public readonly VenuesDbContext venuesDbContext = new VenuesDbContext();
        public readonly ConcertTicketDbContext concertTicketDbContext = new ConcertTicketDbContext();
        public readonly CustomerDbContext customerDbContext = new CustomerDbContext();

        private readonly Action<string> _statusCallback;

        public TicketsRepository(Action<string> statusCallback)
        {
            _statusCallback = statusCallback;
        }

        public EventListView GenerateEventListView(int venueId = 0, int cityId = 0)
        {
            EventListView eventListView = new EventListView { SelectedVenue = venueId, SelectedCity = cityId };
            List<Concert> concertsList = new List<Concert>(concertDbContext.GetConcerts().Where(a => DateTime.Compare(a.ConcertDate, DateTime.Today) >= 0));
            
            //If Concerts have expired, roll dates forward            
            if (concertsList.Count < 2)
                if (!new ResetCode().RefreshConcerts(false))
                    
                    //If connection fails, prompt user on troubleshoot steps
                    UpdateStatus(string.Format("ERROR connecting to {0} database server.  Make sure: 1. The database server name, username and password in the web.config are correct, 2. Auditing is enabled on the Database Server, 3. Firewall rules allow access - including Azure Services, and 4. the Database server name resolves using nslookup.", WingtipTicketApp.Config.PrimaryDatabaseServer));

            foreach (var concert in concertsList)
            {
                if (!eventListView.VenuesList.Any(a => a.VenueId == concert.VenueId))
                    eventListView.VenuesList.Add(venuesDbContext.GetVenueByVenueId(concert.VenueId));
                eventListView.ConcertsList.Add(concert);
                concert.Venue = eventListView.VenuesList.FirstOrDefault(a => a.VenueId == concert.VenueId);
            }

            return eventListView;
        }

        public MyEventsView GenerateMyEvents(Customer customer, string venueName = null)
        {
            MyEventsView myEventsView = new MyEventsView();
            PurchasedTicket tempTicket = null;
            try
            {
                if (customer == null) return myEventsView;
                
                List<ConcertTicket> concertTicketsList = concertTicketDbContext.ReturnPurchasedTicketsByCustomerId(customer.CustomerId);
                List<Venue> venuesList = venuesDbContext.GetVenues();
                List<Concert> concertsList = new List<Concert>(concertDbContext.GetConcerts());
                List<ConcertTicketLevel> ticketLevelsList = concertTicketDbContext.GetTicketLevels();
                
                Concert concert = new Concert();               

                foreach (var ticket in concertTicketsList)
                {                    
                    concert = concertsList.Find(c => c.ConcertId.Equals(ticket.ConcertId));

                    tempTicket = new PurchasedTicket(
                    //should be concert.ConcertName
                    concert.Performer.ShortName,
                    concert.ConcertId,
                    venuesList.Find(v => v.VenueId.Equals(concert.VenueId)).VenueName,
                    1,
                    //should be seat section
                    Convert.ToInt32(ticketLevelsList.Find(l => l.TicketLevelId.Equals(ticket.TicketLevelId)).TicketPrice).ToString(),
                    "N/A",
                    concert.ConcertDate,
                    ticket.ConcertId,
                    concert.VenueId
                    );

                    switch (Convert.ToInt32(tempTicket.SectionName))
                    {
                        case 55: tempTicket.SectionName = "219-221"; break;
                        case 60: tempTicket.SectionName = "218-214"; break;
                        case 65: tempTicket.SectionName = "222-226"; break;
                        case 70: tempTicket.SectionName = "210-213"; break;
                        case 75: tempTicket.SectionName = "201-204"; break;
                        case 80: tempTicket.SectionName = "114-119"; break;
                        case 85: tempTicket.SectionName = "120-126"; break;
                        case 90: tempTicket.SectionName = "104-110"; break;
                        case 95: tempTicket.SectionName = "111-113"; break;
                        case 100: tempTicket.SectionName = "101-103"; break;
                    }

                    if (myEventsView.PurchasedTickets.Exists(x => x.ConcertId == ticket.ConcertId && x.SectionName == tempTicket.SectionName))
                    {
                        int index = myEventsView.PurchasedTickets.FindIndex(x => x.ConcertId == ticket.ConcertId && x.SectionName == tempTicket.SectionName);                        
                            myEventsView.PurchasedTickets[index].TicketQuantity++;
                    }
                    else
                    {
                        myEventsView.PurchasedTickets.Add(tempTicket);
                    }
                    
                // sort all events by date
                if (myEventsView != null && myEventsView.PurchasedTickets != null && myEventsView.PurchasedTickets.Count > 0)
                    myEventsView.PurchasedTickets.Sort((a, b) => a.EventDateTime.CompareTo(b.EventDateTime));
                }
            }
            catch (Exception ex)
            { }
             
            return myEventsView;
        }

        public bool DeleteConcert(String concertId)
        {
            bool concertDeleted = false;
            var concertToDelete = concertDbContext.GetConcertById(Int32.Parse(concertId));
            if (concertToDelete != null)
            {
                // delete ALL tickets for this concert, then delete concert
                concertTicketDbContext.DeleteAllTicketsForConcert(concertToDelete.ConcertId);
                concertDeleted = concertDbContext.DeleteConcert(concertToDelete.ConcertId);
            }
            if (concertDeleted)
            {                
                UpdateStatus(string.Format("Successfully deleted concert id #{0} - '{1}'", concertToDelete.ConcertId, concertToDelete.ConcertName));
            }
            else
                UpdateStatus(string.Format("FAILED to delete concert id #{0} - '{1}'", concertToDelete.ConcertId, concertToDelete.ConcertName));
            return concertDeleted;
        }

        private void UpdateStatus(string message)
        {
            if (_statusCallback != null)
            {
                _statusCallback(message);
            }
        }
        #region Private Functions
        private string constructTicketsDbConnnectString()
        {
            return WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName);
        }
        #endregion
    }
}