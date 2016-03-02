using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using WingTipTickets;

namespace Tenant.Mvc.Models.VenuesDB
{
    public class VenuesDbContext
    {
        #region - Constants -

        private const int ConstAllCitiesId = -1;

        private const String ConstGetAllVenuesQuery =
                                        @"SELECT venue.VenueName as venueName,
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
	                                     FROM [Venues] as venue
	                                       INNER JOIN [dbo].City as city ON (venue.CityId = city.CityId)
	                                       INNER JOIN [dbo].States as states ON (city.StateId = states.StateId)
	                                       INNER JOIN [dbo].Country as country ON (states.CountryId = country.CountryId)";

        private const String ConstGetAllCities = 
                                    @" SELECT city.CityId as cityId,
                                            city.CityName as cityName,
                                            city.Description as cityDescription,
                                            cityState.StateName as stateName,
                                            cityState.StateId as stateId,
                                            cityCountry.CountryName as countryName,
                                            cityCountry.CountryId as countryId
                                       FROM [City]
                                          INNER JOIN [dbo].States AS cityState ON (City.StateId = cityState.StateId)
                                          INNER JOIN [dbo].Country as cityCountry on (cityCountry.CountryId = cityState.CountryId)
                                       ORDER BY City.CityName";
        
        #endregion

        #region - Private Methods -

        private static String ConstructVenuesConnectString()
        {
            return WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName);
        }

        #endregion


        #region - City Methods -

        public List<City> GetCities()
        {
            return GetCitiesInternal();
        }

        public City GetCityByName(String cityName)
        {
            return GetCitiesInternal().FirstOrDefault(c => c.CityName == cityName);
        }

        public City GetCityById(int cityId)
        {
            return GetCitiesInternal().FirstOrDefault(c => c.CityId == cityId);
        }

        public City AddNewCity(String cityName, String cityDescription = "", String cityState = "")
        {
            var allCities = GetCitiesInternal();
            var stateId = allCities.Any() ? allCities[0].State.StateId : 0;
            
            using (var dbConnection = new SqlConnection(ConstructVenuesConnectString()))
            {
                dbConnection.Open();

                using (var cmd = new SqlCommand(String.Format(@"INSERT INTO [City] (CityName, Description, StateId) VALUES ('{0}', '{1}', {2})", cityName, cityDescription, stateId), dbConnection))
                {
                    cmd.ExecuteNonQuery();
                }
            }

            LogAction("Added new city - " + cityName);

            return GetCitiesInternal().FirstOrDefault(c => c.CityName == cityName);
        }

        #endregion

        #region - Venue Methods -

        public List<Venue> GetVenues(int cityId)
        {
            return GetVenuesInternal(cityId);
        }

        public List<Venue> GetVenues()
        {
            return GetVenuesInternal(ConstAllCitiesId);
        }

        public Venue GetVenueByVenueId(int venueId)
        {
            return (GetVenueByVenueIdInternal(venueId));
        }

        public List<SeatSection> GetSeatMapForVenue(int venueId)
        {
            return getSeatMapForVenueInternal(venueId);
        }

        public Venue AddNewVenue(String venueName, int cityId)
        {
            var tempInt = 0; 
            var venueAdded = new Venue(); 
            var tempDs = new DataSet();
            var venueInsert = string.Format(@"INSERT INTO [Venues] (VenueName, Capacity, CityId, Description) VALUES ('{0}', 1000, {1}, '') Select @@Identity", venueName, cityId);

            using (var venueDataAdapter = new SqlDataAdapter(new SqlCommand(venueInsert, new SqlConnection(ConstructVenuesConnectString()))))
            {
                venueDataAdapter.Fill(tempDs);
                
                // Capture integer value of newly added venue
                if (tempDs.Tables.Count > 0 && tempDs.Tables[0].Rows.Count > 0 && tempDs.Tables[0].Rows[0][0] != DBNull.Value)
                {
                    Int32.TryParse(tempDs.Tables[0].Rows[0][0].ToString(), out tempInt);
                }

                // If venue was added, continue, else, return
                if (tempInt > 0)
                {
                    venueAdded.VenueId = tempInt;
                }
                else
                {
                    return venueAdded;
                }
            }

            var seatSectionInsert = string.Format(@"INSERT INTO [SeatSection] (SeatCount, VenueId, Description) VALUES (100, {0}, '') Select @@Identity", venueAdded.VenueId);
            
            // Add SeatSections for this venue
            using (var seatDataAdapter = new SqlDataAdapter(new SqlCommand(seatSectionInsert, new SqlConnection(ConstructVenuesConnectString()))))
            {
                for (var i = 1; i <= 10; i++)
                {
                    seatDataAdapter.Fill(tempDs);
                }
            }

            LogAction("Added new venue - " + venueName);

            return venueAdded;
        }

        #endregion

        #region - Private Methods -

        private List<City> GetCitiesInternal()
        {
            var citiesList = new List<City>();
            
            using (var conn = new SqlConnection(ConstructVenuesConnectString()))
            {
                conn.Open();

                using (var queryCommand = new SqlCommand(ConstGetAllCities, conn))
                {
                    using (var reader = queryCommand.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var cityCountry = new Country
                            {
                                CountryName = reader.GetString(reader.GetOrdinal("countryName")),
                                CountryId = reader.GetInt32(reader.GetOrdinal("countryId"))
                            };

                            var cityState = new State
                            {
                                StateName = reader.GetString(reader.GetOrdinal("stateName")),
                                StateId = reader.GetInt32(reader.GetOrdinal("stateId")),
                                Country = cityCountry
                            };

                            var cityToAdd = new City
                            {
                                CityId = reader.GetInt32(reader.GetOrdinal("cityId")),
                                CityName = reader.GetString(reader.GetOrdinal("cityName")),
                                Description = (reader.IsDBNull(reader.GetOrdinal("cityDescription"))) 
                                    ? "" 
                                    : reader.GetString(reader.GetOrdinal("cityDescription")),
                                State = cityState
                            };

                            citiesList.Add(cityToAdd);
                        }
                    }
                }
            }

            return citiesList;
        }

        private List<Venue> GetVenuesInternal(int cityId)
        {
            var venuesList = new List<Venue>();
            
            using (var conn = new SqlConnection(ConstructVenuesConnectString()))
            {
                conn.Open();

                var queryCommand = cityId == ConstAllCitiesId 
                    ? new SqlCommand(ConstGetAllVenuesQuery, conn) 
                    : new SqlCommand(String.Format("{0} WHERE city.CityId={1} ORDER BY Venue.VenueName", ConstGetAllVenuesQuery, cityId), conn);

                using (var reader = queryCommand.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        venuesList.Add(PopulateSingleVenueFromDbReader(reader));
                    }
                }
            }

            return venuesList;
        }

        private Venue PopulateSingleVenueFromDbReader(SqlDataReader dbReader)
        {
            var venueCountry = new Country
            {
                CountryName = dbReader.GetString(dbReader.GetOrdinal(@"countryName"))
            };

            var venueState = new State
            {
                StateName = dbReader.GetString(dbReader.GetOrdinal(@"stateName")),
                Description = (dbReader.IsDBNull(dbReader.GetOrdinal(@"stateDescription"))) 
                    ? ""
                    : dbReader.GetString(dbReader.GetOrdinal(@"stateDescription")),
                Country = venueCountry
            };

            var venueCity = new City
            {
                CityName = dbReader.GetString(dbReader.GetOrdinal(@"cityName")),
                CityId = dbReader.GetInt32(dbReader.GetOrdinal("cityId")),
                Description = (dbReader.IsDBNull(dbReader.GetOrdinal(@"cityDescription"))) 
                    ? "" 
                    : dbReader.GetString(dbReader.GetOrdinal(@"cityDescription")),
                State = venueState
            };

            var venueToReturn = new Venue
            {
                VenueName = dbReader.GetString(dbReader.GetOrdinal(@"venueName")),
                Capacity = dbReader.GetInt32(dbReader.GetOrdinal(@"venueCapacity")),
                Description = (dbReader.IsDBNull(dbReader.GetOrdinal(@"venueDescription"))) 
                    ? "" 
                    : dbReader.GetString(dbReader.GetOrdinal(@"venueDescription")),
                VenueCity = venueCity,
                VenueId = dbReader.GetInt32(dbReader.GetOrdinal(@"venueId"))
            };

            return venueToReturn;
        }

        private Venue GetVenueByVenueIdInternal(int venueId)
        {
            Venue venueNeeded = null;
            
            using (var conn = new SqlConnection(ConstructVenuesConnectString()))
            {
                conn.Open();

                using (var queryCommand = new SqlCommand(String.Format("{0} WHERE venue.VenueId={1}", ConstGetAllVenuesQuery, venueId), conn))
                {
                    using (var reader = queryCommand.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            venueNeeded = PopulateSingleVenueFromDbReader(reader);
                        }
                    }
                }
            }

            return venueNeeded;
        }

        private List<SeatSection> getSeatMapForVenueInternal(int venueId)
        {
            var seatMapList = new List<SeatSection>();

            using (var conn = new SqlConnection(ConstructVenuesConnectString()))
            {
                var seatMapQuery = String.Format(@"SELECT  seatSection.SeatSectionId as seatSectionId,
                                                   seatSection.Description as seatDescription,
                                                   seatSection.VenueId as venueId,
                                                   seatSection.SeatCount as seatCount
                                                   FROM SeatSection as seatSection
                                                   WHERE seatSection.VenueId={0}", venueId);

                conn.Open();
                using (var cmd = new SqlCommand(seatMapQuery, conn))
                {
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var seatMapToAdd = new SeatSection
                            {
                                SeatSectionId = reader.GetInt32(reader.GetOrdinal(@"seatSectionId")),
                                Description = (reader.IsDBNull(reader.GetOrdinal(@"seatDescription"))) 
                                    ? "" 
                                    : reader.GetString(reader.GetOrdinal(@"seatDescription")),
                                VenueId = reader.GetInt32(reader.GetOrdinal(@"venueId")),
                                SeatCount = reader.GetInt32(reader.GetOrdinal(@"seatCount")),
                                TicketLevelId = 1,
                                TicketPrice = 55
                            };

                            seatMapList.Add(seatMapToAdd);
                        }
                    }
                }
            }

            return seatMapList;
        }

        #endregion

        #region - Logging Methods -

        public static void LogAction(string action)
        {
            using (var sqlConn = new SqlConnection(ConstructVenuesConnectString()))
            {
                sqlConn.Open();

                using (var logCommand = new SqlCommand("Insert into WebSiteActionLog (Action, UpdatedDate) Values ('" + action + "', GETDATE())", sqlConn))
                {
                    logCommand.ExecuteNonQuery();
                }
            }
        }

        #endregion
    }
}