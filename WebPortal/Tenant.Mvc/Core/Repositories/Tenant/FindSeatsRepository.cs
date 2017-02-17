using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Mvc;
using Tenant.Mvc.Core.Contexts;
using Tenant.Mvc.Core.Interfaces.Tenant;
using Tenant.Mvc.Models;
using WingTipTickets;

namespace Tenant.Mvc.Core.Repositories.Tenant
{
    public class FindSeatsRepository : IFindSeatsRepository
    {
        #region - Fields -

        public Action<string> StatusCallback { get; set; }

        #endregion

        #region - Implementation -

        public FindSeatsViewModel GetFindSeatsData(int concertId)
        {
            using (var context = new WingTipTicketsEntities(WingtipTicketApp.GetTenantConnectionString(WingtipTicketApp.Config.TenantDatabase1)))
            {
                var concert = context.Concerts.First(c => c.ConcertId == concertId);
                var venue = context.Venues.First(v => v.VenueId == concert.VenueId);
                var performer = context.Performers.First(p => p.PerformerId == concert.PerformerId);

                var seatSections = context.TicketLevels.Where(t => t.ConcertId == concertId).ToList();

                // Map to ViewModel
                var viewModel = new FindSeatsViewModel()
                {
                    // Main Models
                    Concert = new FindSeatsViewModel.ConcertViewModel()
                    {
                        ConcertId = concert.ConcertId,
                        ConcertName = concert.ConcertName,
                        ConcertDate = (DateTime)concert.ConcertDate,

                        VenueId = venue.VenueId,
                        VenueName = venue.VenueName,

                        PerformerName = performer.ShortName
                    },

                    // Collections
                    SeatSections = new SelectList(seatSections, "SeatSectionId", "Description", null),
                };

                return viewModel;
            }
        }

        public List<SeatSectionLayoutViewModel> GetSeatSectionLayout(int concertId, int ticketLevelId)
        {
            using (var context = new WingTipTicketsEntities(WingtipTicketApp.GetTenantConnectionString(WingtipTicketApp.Config.TenantDatabase1)))
            {
                var ticketLevel = context.TicketLevels.First(t => t.TicketLevelId == ticketLevelId);

                var result = context.SeatSectionLayouts.Where(l => l.SeatSectionId == ticketLevel.SeatSectionId).Select(l => new SeatSectionLayoutViewModel()
                {
                    RowNumber = (int)l.RowNumber,
                    SkipCount = (int)l.SkipCount,
                    StartNumber = (int)l.StartNumber,
                    EndNumber = (int)l.EndNumber,
                    SelectedSeats = context.Tickets
                        .Where(t => t.TicketLevelId == ticketLevelId && 
                                    t.ConcertId == concertId && 
                                    t.SeatNumber >= (int)l.StartNumber && 
                                    t.SeatNumber <= (int)l.EndNumber)
                        .Select(t => (int)t.SeatNumber)
                        .Distinct()
                        .ToList()
                }).ToList();

                return result;
            }
        }

        #endregion

        #region - Protected Methods -

        protected void UpdateStatus(string message)
        {
            if (StatusCallback != null)
            {
                StatusCallback(message);
            }
        }

        #endregion
    }
}