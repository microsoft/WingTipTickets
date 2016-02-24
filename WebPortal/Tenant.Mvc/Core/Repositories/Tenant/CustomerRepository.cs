using System.Collections.Generic;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class CustomerRepository : BaseRepository, ICustomerRepository
    {
        #region - Implementation -

        public bool Login(string email, string password)
        {
            return Context.Customers.Login(email, password);
        }

        public bool CreateUser(string firstName, string lastName, string email, string phonenumber, string password)
        {
            return Context.Customers.CreateUser(firstName, lastName, email, phonenumber, password);
        }

        public CustomerEventsModel GetCustomerEvents(CustomerModel customerModel, string venueName = null)
        {
            var myEventsView = new CustomerEventsModel();

            if (customerModel == null)
            {
                return myEventsView;
            }

            var concertTicketsList = Context.Tickets.ReturnPurchasedTicketsByCustomerId(customerModel.CustomerId);
            var venuesList = Context.Venues.GetVenues();
            var concertsList = new List<ConcertModel>(Context.Concerts.GetConcerts());
            var ticketLevelsList = Context.Tickets.GetTicketLevels();

            foreach (var ticket in concertTicketsList)
            {
                var concert = concertsList.Find(c => c.ConcertId == ticket.ConcertId);
                var ticketLevel = ticketLevelsList.Find(l => l.TicketLevelId == ticket.TicketLevelId);

                var tempTicket = new PurchasedTicketModel(
                    concert.PerformerModel.ShortName,
                    concert.ConcertId,
                    venuesList.Find(v => v.VenueId.Equals(concert.VenueId)).VenueName,
                    1,
                    ticketLevel.Description,
                    "N/A",
                    concert.ConcertDate,
                    ticket.ConcertId,
                    concert.VenueId
                    );

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

        #endregion
    }
}