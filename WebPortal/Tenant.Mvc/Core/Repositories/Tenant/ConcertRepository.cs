using System;
using System.Collections.Generic;
using System.Linq;
using Tenant.Mvc.Core.Enums;
using Tenant.Mvc.Core.Helpers;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Core.Models;
using WingTipTickets;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class ConcertRepository : BaseRepository, IConcertRepository
    {
        #region - Implementation -

        public ConcertModel GetConcertById(int concertId)
        {
            return Context.Concerts.GetConcertById(concertId);
        }

        public ConcertListModel GetConcertList(int venueId = 0, int cityId = 0)
        {
            // Fetch Concerts
            var concertsList = Context.Concerts.GetConcerts().Where(a => DateTime.Compare(a.ConcertDate, DateTime.Today) >= 0).ToList();

            // Roll forward expired concerts
            if (concertsList.Count < 2 && !DataHelper.RefreshConcerts(false))
            {
                UpdateStatus(string.Format("ERROR connecting to {0} database server.  Make sure: 1. The database server name, username and password in the web.config are correct, 2. Auditing is enabled on the Database Server, 3. Firewall rules allow access - including Azure Services, and 4. the Database server name resolves using nslookup.", WingtipTicketApp.Config.TenantDatabaseServer));
            }

            // Create ViewModel
            var eventListView = new ConcertListModel
            {
                SelectedVenue = venueId,
                SelectedCity = cityId,
                ConcertsList = concertsList,
                VenuesList = Context.Venues.GetVenues(cityId)
            };

            // Update Venues
            eventListView.ConcertsList.ForEach(c => c.VenueModel = eventListView.VenuesList.FirstOrDefault(a => a.VenueId == c.VenueId));
            eventListView.VenuesList.ForEach(v => v.ConcertQty = eventListView.ConcertsList.Count(a => a.VenueId == v.VenueId));

            // Filter by Venue
            if (venueId > 0)
            {
                eventListView.ConcertsList = concertsList.Where(c => c.VenueId == venueId).ToList();
                eventListView.VenuesList = eventListView.VenuesList.Where(v => v.VenueId == venueId).ToList();
            }

            // Filter by City
            if (cityId > 0)
            {
                eventListView.ConcertsList = concertsList.Where(c => c.VenueModel != null && c.VenueModel.VenueCityModel.CityId == cityId).ToList();
            }

            return eventListView;
        }

        public List<ConcertModel> GetConcerts(int venueId = 0, bool orderByName = false)
        {
            return Context.Concerts.GetConcerts(venueId, orderByName);
        }

        public ConcertModel SaveNewConcert(string concertName, string concertDescription, DateTime concertDateTime, ServerTargetEnum saveToDatabase, int concertVenueId, int performerId)
        {
            return Context.Concerts.SaveNewConcert(concertName, concertDescription, concertDateTime, saveToDatabase, concertVenueId, performerId);
        }

        public bool DeleteConcert(int concertId)
        {
            var concertDeleted = false;
            var concertToDelete = Context.Concerts.GetConcertById(concertId);

            if (concertToDelete != null)
            {
                // Delete ALL tickets for this concert, then delete concert
                Context.Tickets.DeleteAllTicketsForConcert(concertToDelete.ConcertId);
                concertDeleted = Context.Concerts.DeleteConcert(concertToDelete.ConcertId);

                UpdateStatus(concertDeleted
                            ? string.Format("Successfully deleted concert id #{0} - {1}", concertToDelete.ConcertId, concertToDelete.ConcertName)
                            : string.Format("FAILED to delete concert id #{0} - {1}", concertToDelete.ConcertId, concertToDelete.ConcertName));
            }
            else
            {
                UpdateStatus(string.Format("FAILED to delete concert id #{0}", concertId));
            }
           

            return concertDeleted;
        }

        #endregion
    }
}