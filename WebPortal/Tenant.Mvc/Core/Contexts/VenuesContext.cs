using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using Tenant.Mvc.Core.Helpers;
using Tenant.Mvc.Core.Models;
using WingTipTickets;

namespace Tenant.Mvc.Core.Contexts
{
    public partial class DatabaseContext
    {
        public class VenueContext
        {
            #region - Constants -

            private const string GetAllVenuesQuery =
                @"SELECT    venue.VenueName as venueName,
                        venue.Description as venueDescription,
                        venue.Capacity as venueCapacity,
                        venue.VenueId as venueId,
                        city.CityName as cityName,
                        city.CityID as cityId,
                        city.Description as cityDescription,
                        states.StateName as stateName,
                        states.StateId as stateId,
                        states.Description as stateDescription,
                        country.CountryName as countryName,
                        country.CountryId as countryId
            FROM        Venues as venue
            JOIN        City as city ON (venue.CityId = city.CityId)
            JOIN        States as states ON (city.StateId = states.StateId)
            JOIN        Country as country ON (states.CountryId = country.CountryId)
            JOIN        Concerts as concert ON (concert.VenueId = venue.VenueId)";

            private const string GetAllCities =
                @" SELECT   city.CityId as cityId,
                        city.CityName as cityName,
                        city.Description as cityDescription,
                        state.StateName as stateName,
                        state.StateId as stateId,
                        country.CountryName as countryName,
                        country.CountryId as countryId
            FROM        City as city
            JOIN        States AS state ON (city.StateId = state.StateId)
            JOIN        Country as country on (country.CountryId = state.CountryId)
            ORDER BY    city.CityName";

            #endregion

            #region - City Methods -

            public List<CityModel> GetCities()
            {
                return GetCitiesInternal();
            }

            public CityModel GetCityByName(string cityName)
            {
                return GetCitiesInternal().FirstOrDefault(c => c.CityName == cityName);
            }

            public CityModel GetCityById(int cityId)
            {
                return GetCitiesInternal().FirstOrDefault(c => c.CityId == cityId);
            }

            public CityModel AddNewCity(string cityName, string cityDescription = "", string cityState = "")
            {
                var allCities = GetCitiesInternal();
                var stateId = allCities.Any() ? allCities[0].StateModel.StateId : 0;

                var sqlScript = string.Format(@"INSERT INTO [City] (CityName, Description, StateId) VALUES ('{0}', '{1}', {2})", cityName, cityDescription, stateId);
                DataHelper.ExecuteNonQuery(sqlScript);

                LogAction("Added New City - " + cityName);

                return GetCitiesInternal().FirstOrDefault(c => c.CityName == cityName);
            }

            public int GetVenueIdByVenueName(string venueName)
            {
                var sqlScript = $"SELECT VenueId FROM Venues WHERE VenueName = '{venueName}'";
                var venueIds = new List<int>();
                using (var cmd = new SqlCommand(sqlScript, WingtipTicketApp.CreateTenantConnectionDatabase1()))
                {
                    using (var sdAdapter = new SqlDataAdapter(cmd))
                    {
                        var dsUser = new DataSet();
                        sdAdapter.Fill(dsUser);

                        if (dsUser.Tables.Count > 0)
                        {
                            foreach (DataRow row in dsUser.Tables[0].Rows)
                            {
                                venueIds.Add(Convert.ToInt32(row["VenueId"]));
                            }
                        }
                    }
                }

                return venueIds.First();
            }

            #endregion

            #region - Venue Methods -

            public List<VenueModel> GetVenues(int venueId = 0, int cityId = 0)
            {
                // Build the Script
                const string sqlScript = GetAllVenuesQuery + " ORDER BY Venue.VenueName";

                // Get the Venues
                var venuesList = DataHelper.ExecuteReader(sqlScript, MapRowToVenue);

                // Apply Filters
                if (venueId != 0)
                {
                    venuesList = venuesList.Where(v => v.VenueId == venueId).ToList();
                }

                if (cityId != 0)
                {
                    venuesList = venuesList.Where(v => v.VenueCityModel.CityId == cityId).ToList();
                }

                return venuesList.Distinct().ToList();
            }

            public VenueModel GetVenueByVenueId(int venueId)
            {
                return (GetVenueByVenueIdInternal(venueId));
            }

            //public List<SeatSection> GetSeatMapForVenue(int venueId)
            //{
            //    return GetSeatMapForVenueInternal(venueId);
            //}

            public VenueModel AddNewVenue(string venueName, int cityId)
            {
                // Add Venue, continue if added
                var venue = new VenueModel();
                var venueScript = string.Format(@"INSERT INTO [Venues] (VenueName, Capacity, CityId, Description) VALUES ('{0}', 1000, {1}, '') Select @@Identity", venueName, cityId);
                var venueId = DataHelper.ExecuteInsert(venueScript);

                if (venueId > 0)
                {
                    venue.VenueId = venueId;
                }
                else
                {
                    return venue;
                }

                // Add Seat Section
                var seatSectionScript = string.Format(@"INSERT INTO [SeatSection] (SeatCount, VenueId, Description) VALUES (100, {0}, '') Select @@Identity", venue.VenueId);
                var seatSectionId = DataHelper.ExecuteInsert(seatSectionScript);

                LogAction("Added new venue - " + venueName);

                return venue;
            }

            #endregion

            #region - Private Methods -

            private List<CityModel> GetCitiesInternal()
            {
                var cities = DataHelper.ExecuteReader(GetAllCities, MapRowToCity);

                return cities;
            }

            private VenueModel GetVenueByVenueIdInternal(int venueId)
            {
                var venue = DataHelper.ExecuteReader(String.Format("{0} WHERE venue.VenueId = {1}", GetAllVenuesQuery, venueId), MapRowToVenue).First();

                return venue;
            }

//            private List<SeatSection> GetSeatMapForVenueInternal(int venueId)
//            {
//                // Build script
//                var seatMapQuery = String.Format(
//                                                 @"SELECT    section.SeatSectionId as seatSectionId,
//                            section.Description as seatDescription,
//                            section.VenueId as venueId,
//                            section.SeatCount as seatCount
//                  FROM      SeatSection as section
//                  WHERE     section.VenueId={0}", venueId);

//                // Get the Seat Maps for Venue
//                var seatMapList = DataHelper.ExecuteReader(seatMapQuery, MapRowToSeatSection);

//                return seatMapList;
//            }

            #endregion

            #region - Mapping Methods -

            private static VenueModel MapRowToVenue(SqlDataReader reader)
            {
                // Map data row into the venue
                var venue = new VenueModel
                {
                    VenueName = reader.GetString("venueName"),
                    Capacity = reader.GetInt32(reader.GetOrdinal("venueCapacity")),
                    Description = reader.GetString("venueDescription"),
                    VenueId = reader.GetInt32(reader.GetOrdinal("venueId")),

                    VenueCityModel = new CityModel
                    {
                        CityName = reader.GetString("cityName"),
                        CityId = reader.GetInt32(reader.GetOrdinal("cityId")),
                        Description = reader.GetString("cityDescription"),

                        StateModel = new StateModel
                        {
                            StateName = reader.GetString("stateName"),
                            Description = reader.GetString("stateDescription"),

                            Country = new Country
                            {
                                CountryName = reader.GetString("countryName")
                            }
                        }
                    },
                };

                return venue;
            }

            private static CityModel MapRowToCity(SqlDataReader reader)
            {
                return new CityModel
                {
                    CityId = reader.GetInt32(reader.GetOrdinal("cityId")),
                    CityName = reader.GetString("cityName"),
                    Description = reader.GetString("cityDescription"),

                    StateModel = new StateModel
                    {
                        StateName = reader.GetString("stateName"),
                        StateId = reader.GetInt32(reader.GetOrdinal("stateId")),

                        Country = new Country
                        {
                            CountryName = reader.GetString("countryName"),
                            CountryId = reader.GetInt32(reader.GetOrdinal("countryId"))
                        }
                    }
                };
            }

            //private static SeatSection MapRowToSeatSection(SqlDataReader reader)
            //{
            //    return new SeatSection
            //    {
            //        SeatSectionId = reader.GetInt32(reader.GetOrdinal(@"seatSectionId")),
            //        Description = reader.GetString(@"seatDescription"),
            //        VenueId = reader.GetInt32(reader.GetOrdinal(@"venueId")),
            //        SeatCount = reader.GetInt32(reader.GetOrdinal(@"seatCount")),
            //        TicketLevelId = 1,
            //        TicketPrice = 55
            //    };
            //}

            #endregion
        }
    }
}