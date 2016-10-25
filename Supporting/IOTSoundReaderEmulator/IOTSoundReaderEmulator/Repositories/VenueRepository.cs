using System;
using System.Data.SqlClient;
using IOTSoundReaderEmulator.Models;

namespace IOTSoundReaderEmulator.Repositories
{
    public class VenueRepository
    {
        #region Public methods

        public VenueModel GetVenueInformation(int venueId)
        {
            VenueModel venueModel = null;
            string sqlScript = "SELECT * FROM [dbo].[Venues] WHERE [VenueId] = " + venueId;

            var connectionString = Helpers.Helper.BuildConnectionString(CloudConfiguration.TenantPrimaryDatabaseServer, CloudConfiguration.TenantDatabase1, CloudConfiguration.DatabaseUser, CloudConfiguration.DatabasePassword, CloudConfiguration.RunningInDev);

            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();

                using (var command = new SqlCommand(sqlScript, connection))
                {
                    var reader = command.ExecuteReader();

                    if (reader.Read())
                    {
                        venueModel = new VenueModel
                        {
                            VenueId = !Convert.IsDBNull(reader["VenueId"]) ? Convert.ToInt32(reader["VenueId"]) : default(int),
                            Latitude = !Convert.IsDBNull(reader["Latitude"]) ? Convert.ToDecimal(reader["Latitude"]) : default(decimal),
                            Longitude = !Convert.IsDBNull(reader["Longitude"]) ? Convert.ToDecimal(reader["Longitude"]) : default(decimal),
                        };
                    }
                }
            }
            
            return venueModel;
        }

        #endregion
    }
}
