using System.Collections.Generic;
using System.Linq;
using Tenant.Mvc.Models.ConcertsDB;
using Tenant.Mvc.Models.ConcertTicketDB;
using Tenant.Mvc.Models.VenuesDB;

namespace Tenant.Mvc.Models
{
    public class EventListView
    {
        public List<Concert> ConcertsList { get; set; }
        public List<Venue> VenuesList { get; set; }
        public int SelectedCity { get; set; }
        public int SelectedVenue { get; set; }

        public EventListView()  {
            ConcertsList = new List<Concert>();
            VenuesList = new List<Venue>();
        }

        public static EventListView FromSearchHits(IEnumerable<ConcertSearchHit> hits)
        {
            City city = new City();
            EventListView view = new EventListView()
            {

                ConcertsList = hits.Select(h => new Concert
                {
                    ConcertId = int.Parse(h.ConcertId),
                    ConcertName = h.ConcertName,
                    ConcertDate = h.ConcertDate.LocalDateTime,
                    Performer = new Performer { PerformerId = h.PerformerId, ShortName = h.PerformerName },
                    PerformerId = h.PerformerId,
                    Venue = new Venue { VenueId = h.VenueId, VenueName = h.VenueName, Description = h.PerformerName, VenueCity = new City { CityName = h.VenueCity} },
                    VenueId = h.VenueId
                }).ToList(),
                VenuesList = hits.Select(h => new { h.VenueId, h.VenueName, h.VenueCity, h.VenueState })
                                 .Distinct()
                                 .Select(v => new Venue { VenueId = v.VenueId, VenueName = v.VenueName, VenueCity = new City { CityName = v.VenueCity, State = new State { StateName = v.VenueState } } })
                                 .ToList()
            };

            return view;
        }
    }
    public class MyEventsView
    {
        public List<PurchasedTicket> PurchasedTickets { get; set; }
        public List<Venue> MyVenues { get; set; }
        public MyEventsView()
        {
            PurchasedTickets = new List<PurchasedTicket>();
            MyVenues = new List<Venue>();
        }
    }

    public class MyEventRating
    {
        public PurchasedTicket PurchasedTicket { get; set; }
        public string Comments { get; set; }
        public int Score { get; set; }
    }
}