using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using IOTSoundReaderEmulator.Models;

namespace IOTSoundReaderEmulator.Repositories
{
    public class VenueRepository
    {
        #region - Fields -

        private List<VenueModel> _venues;

        #endregion

        #region - Constructors -

        public VenueRepository()
        {
            // Initialize and read all data to lessen the amount of calls to the database
            _venues = GetVenues();
        }

        #endregion

        #region - Private Methods -

        private List<VenueModel> GetVenues()
        {
            var venues = new List<VenueModel>();

            var sqlScript = "SELECT * FROM [dbo].[Venues] ORDER BY VenueId";
            var connectionString = Helpers.Helper.BuildConnectionString(CloudConfiguration.TenantPrimaryDatabaseServer, CloudConfiguration.TenantDatabase1, CloudConfiguration.DatabaseUser, CloudConfiguration.DatabasePassword, CloudConfiguration.RunningInDev);

            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();

                using (var command = new SqlCommand(sqlScript, connection))
                {
                    var reader = command.ExecuteReader();

                    while (reader.Read())
                    {
                        venues.Add(new VenueModel
                        {
                            VenueId = !Convert.IsDBNull(reader["VenueId"]) ? Convert.ToInt32(reader["VenueId"]) : default(int),
                            Latitude = !Convert.IsDBNull(reader["Latitude"]) ? Convert.ToDecimal(reader["Latitude"]) : default(decimal),
                            Longitude = !Convert.IsDBNull(reader["Longitude"]) ? Convert.ToDecimal(reader["Longitude"]) : default(decimal),
                        });
                    }
                }
            }

            return venues;
        }

        #endregion

        #region - Public Methods -

        public VenueModel GetVenueInformation(int venueId)
        {
            return _venues.First(v => v.VenueId == venueId);
        }

        #endregion
    }
}
