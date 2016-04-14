using System;
using System.Collections.Generic;
using System.Linq;
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

        public CustomerEventsModel GetCustomerEvents(CustomerModel customerModel, int? venueId = null)
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
                    ticketLevel.Description.Split('-').First().Trim(),
                    ticket.SeatNumber,
                    concert.ConcertDate,
                    ticket.ConcertId,
                    concert.VenueId
                    );

                if (myEventsView.PurchasedTickets.Exists(x => x.ConcertId == ticket.ConcertId && x.SectionName == tempTicket.SectionName))
                {
                    var index = myEventsView.PurchasedTickets.FindIndex(x => x.ConcertId == ticket.ConcertId && x.SectionName == tempTicket.SectionName);
                    myEventsView.PurchasedTickets[index].TicketQuantity++;
                    myEventsView.PurchasedTickets[index].SeatName += ", " + tempTicket.SeatName;
                }
                else if (venueId == null || tempTicket.VenueId == venueId)
                {
                    myEventsView.PurchasedTickets.Add(tempTicket);

                    if (!myEventsView.MyVenues.Exists(v => v.VenueId == tempTicket.VenueId))
                    {
                        var venue = venuesList.Find(v => v.VenueId.Equals(concert.VenueId));
                        myEventsView.MyVenues.Add(new VenueModel()
                        {
                            VenueId = venue.VenueId,
                            VenueName = venue.VenueName,
                            Capacity = venue.Capacity
                        });
                    }
                }
            }

            // Sort all events by date
            if (myEventsView.PurchasedTickets != null && myEventsView.PurchasedTickets.Count > 0)
            {
                myEventsView.PurchasedTickets.Sort((a, b) => a.EventDateTime.CompareTo(b.EventDateTime));
            }

            return myEventsView;
        }

        #endregion
    }
}