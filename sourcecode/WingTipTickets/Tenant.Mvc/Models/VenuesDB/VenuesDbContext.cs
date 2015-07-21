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
        #region Private Variables / Functions
        private const int CONST_ALL_CITIES_ID = -1;
        private const String CONST_GetAllVenuesQuery =
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
        private const String CONST_GetAllCities = 
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
        private static String constructVenuesConnectString()
        {
            return WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName);
        }
        #endregion Private Variables / Functions

        #region Public City methods
        public List<City> GetCities()
            { return getCitiesInternal(); }

        public City GetCityByName(String cityName)
            { return getCitiesInternal().FirstOrDefault(c => c.CityName == cityName); }

        public City GetCityById(int cityId)
            { return getCitiesInternal().FirstOrDefault(c => c.CityId == cityId); }

        public City AddNewCity(String cityName, String cityDescription = "", String cityState = "")
        {
            var allCities = getCitiesInternal();
            int stateId = allCities.Any() ? allCities[0].State.StateId : 0;
            try
            {
                using (var dbConnection = new SqlConnection(constructVenuesConnectString()))
                {
                    dbConnection.Open();
                    using (var cmd = new SqlCommand(String.Format(@"INSERT INTO [City] (CityName, Description, StateId) VALUES ('{0}', '{1}', {2})",
                                            cityName, cityDescription, stateId), dbConnection))
                        cmd.ExecuteNonQuery();
                }
            }
            catch { }

            LogAction("Added new city - " + cityName);
            return getCitiesInternal().FirstOrDefault(c => c.CityName == cityName);
        }
        #endregion

        #region Public Venue Methods
        public List<Venue> GetVenues(int cityId)
            { return getVenuesInternal(cityId); }
        public List<Venue> GetVenues()
            { return getVenuesInternal(CONST_ALL_CITIES_ID); }
        public Venue GetVenueByVenueId(int venueId)
            { return (getVenueByVenueIdInternal(venueId)); }
        public List<SeatSection> GetSeatMapForVenue(int venueId)
            { return getSeatMapForVenueInternal(venueId); }

        public Venue AddNewVenue(String venueName, int cityId)
        {
            int tempInt = 0; Venue venueAdded = new Venue(); DataSet tempDS = new DataSet();

            try
            {
                string venueInsert = string.Format(@"INSERT INTO [Venues] (VenueName, Capacity, CityId, Description) VALUES ('{0}', 1000, {1}, '') Select @@Identity", venueName, cityId);
                using (var venueDataAdapter = new SqlDataAdapter(new SqlCommand(venueInsert, new SqlConnection(constructVenuesConnectString()))))
                {
                    venueDataAdapter.Fill(tempDS);
                    // capture integer value of newly added venue
                    if (tempDS.Tables.Count > 0 && tempDS.Tables[0].Rows.Count > 0 && tempDS.Tables[0].Rows[0][0] != DBNull.Value)
                        Int32.TryParse(tempDS.Tables[0].Rows[0][0].ToString(), out tempInt);
                    
                    // if venue was added, continue, else, return
                    if (tempInt > 0) venueAdded.VenueId = tempInt;
                    else return venueAdded;
                }

                string seatSectionInsert = string.Format(@"INSERT INTO [SeatSection] (SeatCount, VenueId, Description) VALUES (100, {0}, '') Select @@Identity", venueAdded.VenueId);
                //Add SeatSections for this venue
                using (var seatDataAdapter = new SqlDataAdapter(new SqlCommand(seatSectionInsert, new SqlConnection(constructVenuesConnectString()))))
                    for (int i = 1; i <= 10; i++)
                        seatDataAdapter.Fill(tempDS);
            }
            catch { venueAdded = null; }

            LogAction("Added new venue - " + venueName);
            return venueAdded;
        }
        #endregion

        #region Private Functions
        private List<City> getCitiesInternal()
        {
            List<City> citiesList = new List<City>();
            try
            {
                using (var conn = new SqlConnection(constructVenuesConnectString()))
                {
                    conn.Open();
                    using (var queryCommand = new SqlCommand(CONST_GetAllCities, conn))
                    using (SqlDataReader reader = queryCommand.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Country cityCountry = new Country
                            {
                                CountryName = reader.GetString(reader.GetOrdinal("countryName")),
                                CountryId = reader.GetInt32(reader.GetOrdinal("countryId"))
                            };
                            State cityState = new State
                            {
                                StateName = reader.GetString(reader.GetOrdinal("stateName")),
                                StateId = reader.GetInt32(reader.GetOrdinal("stateId")),
                                Country = cityCountry
                            };
                            City cityToAdd = new City
                            {
                                CityId = reader.GetInt32(reader.GetOrdinal("cityId")),
                                CityName = reader.GetString(reader.GetOrdinal("cityName")),
                                Description = (reader.IsDBNull(reader.GetOrdinal("cityDescription"))) ? "" :
                                                reader.GetString(reader.GetOrdinal("cityDescription")),
                                State = cityState
                            };
                            citiesList.Add(cityToAdd);
                        }
                    }
                }
            }
            catch { }
            return citiesList;
        }

        private List<Venue> getVenuesInternal(int cityId)
        {
            List<Venue> venuesList = new List<Venue>();
            try
            {
                using (var conn = new SqlConnection(constructVenuesConnectString()))
                {
                    conn.Open();
                    SqlCommand queryCommand = null;
                    if (cityId == CONST_ALL_CITIES_ID)
                        queryCommand = new SqlCommand(CONST_GetAllVenuesQuery, conn);
                    else
                        queryCommand = new SqlCommand(String.Format("{0} WHERE city.CityId={1} ORDER BY Venue.VenueName", CONST_GetAllVenuesQuery, cityId), conn);

                    using (SqlDataReader reader = queryCommand.ExecuteReader())
                        while (reader.Read())
                            venuesList.Add(populateSingleVenueFromDbReader(reader));
                }
            }
            catch { }

            return venuesList;
        }

        private Venue populateSingleVenueFromDbReader(SqlDataReader dbReader)
        {
            var venueCountry = new Country
            {
                CountryName = dbReader.GetString(dbReader.GetOrdinal(@"countryName"))
            };
            var venueState = new State
            {
                StateName = dbReader.GetString(dbReader.GetOrdinal(@"stateName")),
                Description = (dbReader.IsDBNull(dbReader.GetOrdinal(@"stateDescription"))) ? "": 
                                    dbReader.GetString(dbReader.GetOrdinal(@"stateDescription")),
                Country = venueCountry
            };
            var venueCity = new City
            {
                CityName = dbReader.GetString(dbReader.GetOrdinal(@"cityName")),
                CityId = dbReader.GetInt32(dbReader.GetOrdinal("cityId")),
                Description = (dbReader.IsDBNull(dbReader.GetOrdinal(@"cityDescription"))) ? "" :
                                    dbReader.GetString(dbReader.GetOrdinal(@"cityDescription")),
                State = venueState
            };
            var venueToReturn = new Venue
            {
                VenueName = dbReader.GetString(dbReader.GetOrdinal(@"venueName")),
                Capacity = dbReader.GetInt32(dbReader.GetOrdinal(@"venueCapacity")),
                Description = (dbReader.IsDBNull(dbReader.GetOrdinal(@"venueDescription"))) ? "" :
                                    dbReader.GetString(dbReader.GetOrdinal(@"venueDescription")),
                VenueCity = venueCity,
                VenueId = dbReader.GetInt32(dbReader.GetOrdinal(@"venueId"))
            };

            return venueToReturn;
        }

        private Venue getVenueByVenueIdInternal(int venueId)
        {
            Venue venueNeeded = null;
            try
            {
                using (var conn = new SqlConnection(constructVenuesConnectString()))
                {
                    conn.Open();
                    using (var queryCommand = new SqlCommand(String.Format("{0} WHERE venue.VenueId={1}", CONST_GetAllVenuesQuery, venueId), conn))
                    using (SqlDataReader reader = queryCommand.ExecuteReader())
                        if (reader.Read())
                            venueNeeded = populateSingleVenueFromDbReader(reader);
                }
            }
            catch { }

            return venueNeeded;
        }

        private List<SeatSection> getSeatMapForVenueInternal(int VenueId)
        {
            List<SeatSection> seatMapList = new List<SeatSection>();

            try
            {
                using (var conn = new SqlConnection(constructVenuesConnectString()))
                {
                    String seatMapQuery = String.Format(@"SELECT  seatSection.SeatSectionId as seatSectionId,
                                                        seatSection.Description as seatDescription,
                                                        seatSection.VenueId as venueId,
                                                        seatSection.SeatCount as seatCount
                                                      FROM SeatSection as seatSection
                                                      WHERE seatSection.VenueId={0}", VenueId);

                    conn.Open();
                    using (var cmd = new SqlCommand(seatMapQuery, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            SeatSection seatMapToAdd = new SeatSection
                            {
                                SeatSectionId = reader.GetInt32(reader.GetOrdinal(@"seatSectionId")),
                                Description = (reader.IsDBNull(reader.GetOrdinal(@"seatDescription"))) ?
                                                    "" : reader.GetString(reader.GetOrdinal(@"seatDescription")),
                                VenueId = reader.GetInt32(reader.GetOrdinal(@"venueId")),
                                SeatCount = reader.GetInt32(reader.GetOrdinal(@"seatCount")),
                                //TODO: Remove the hardcoded ticketlevel and tickePrice
                                TicketLevelId = 1,
                                TicketPrice = 55
                            };
                            seatMapList.Add(seatMapToAdd);
                        }
                    }
                }
            }
            catch { }

            return seatMapList;
        }
        #endregion

        #region Logging
        public static void LogAction(string action)
        {
            try
            {
                using (var sqlConn = new SqlConnection(constructVenuesConnectString()))
                {
                    sqlConn.Open();
                    using (var logCommand = new SqlCommand("Insert into WebSiteActionLog (Action, UpdatedDate) Values ('" + action + "', GETDATE())", sqlConn))
                        logCommand.ExecuteNonQuery();
                }
            }
            catch { }
        }
        #endregion Logging
    }
}