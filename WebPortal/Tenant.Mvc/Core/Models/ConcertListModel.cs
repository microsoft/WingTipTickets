using System.Collections.Generic;
using System.Linq;

namespace Tenant.Mvc.Core.Models
{
    public class ConcertListModel
    {
        #region - Properties -

        public List<ConcertModel> ConcertsList { get; set; }
        public List<VenueModel> VenuesList { get; set; }
        public int SelectedCity { get; set; }
        public int SelectedVenue { get; set; }

        #endregion

        #region - Constructors -

        public ConcertListModel()
        {
            ConcertsList = new List<ConcertModel>();
            VenuesList = new List<VenueModel>();
        }

        #endregion

        #region - Public Methods -

        public static ConcertListModel FromSearchHits(IEnumerable<ConcertSearchHit> hits)
        {
            var city = new CityModel();
            var view = new ConcertListModel()
            {

                ConcertsList = hits.Select(h => new ConcertModel
                {
                    ConcertId = int.Parse(h.ConcertId),
                    ConcertName = h.ConcertName,
                    ConcertDate = h.ConcertDate.LocalDateTime,
                    PerformerModel = new PerformerModel
                    {
                        PerformerId = h.PerformerId, ShortName = h.PerformerName
                    },
                    PerformerId = h.PerformerId,
                    VenueModel = new VenueModel
                    {
                        VenueId = h.VenueId, VenueName = h.VenueName, Description = h.PerformerName, VenueCityModel = new CityModel
                        {
                            CityName = h.VenueCity
                        }
                    },
                    VenueId = h.VenueId
                }).ToList(),
                VenuesList = hits.Select(h => new
                {
                    h.VenueId, h.VenueName, h.VenueCity, h.VenueState
                })
                                 .Distinct()
                                 .Select(v => new VenueModel
                                 {
                                     VenueId = v.VenueId, VenueName = v.VenueName, VenueCityModel = new CityModel
                                     {
                                         CityName = v.VenueCity, StateModel = new StateModel
                                         {
                                             StateName = v.VenueState
                                         }
                                     }
                                 })
                                 .ToList()
            };

            return view;
        }

        #endregion
    }
}