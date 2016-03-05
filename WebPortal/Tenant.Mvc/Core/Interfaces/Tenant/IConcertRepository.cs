using System;
using System.Collections.Generic;
using Tenant.Mvc.Core.Enums;
using Tenant.Mvc.Core.Models;

namespace Tenant.Mvc.Core.Interfaces.Tenant
{
    public interface IConcertRepository : IBaseRepository
    {
        ConcertModel GetConcertById(int concertId);
        ConcertListModel GetConcertList(int venueId = 0, int cityId = 0);
        List<ConcertModel> GetConcerts(int venueId = 0, bool orderByName = false);
        ConcertModel SaveNewConcert(string concertName, string concertDescription, DateTime concertDateTime, ServerTargetEnum saveToDatabase, int concertVenueId, int performerId);
        bool DeleteConcert(int concertId);
    }
}