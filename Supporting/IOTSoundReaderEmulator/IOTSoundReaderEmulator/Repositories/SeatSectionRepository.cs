using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using IOTSoundReaderEmulator.Models;

namespace IOTSoundReaderEmulator.Repositories
{
    public class SeatSectionRepository
    {
        #region - Fields -

        private List<SeatSectionModel> _seatSections;

        #endregion

        #region - Constructors -

        public SeatSectionRepository()
        {
            // Initialize and read all data to lessen the amount of calls to the database
            _seatSections = GetSeatSections();
        }

        #endregion

        #region - Private Methods -

        private List<SeatSectionModel> GetSeatSections()
        {
            var seatSections = new List<SeatSectionModel>();

            var sqlScript = "SELECT * FROM [dbo].[SeatSection] ORDER BY SeatSectionID";
            var connectionString = Helpers.Helper.BuildConnectionString(CloudConfiguration.TenantPrimaryDatabaseServer, CloudConfiguration.TenantDatabase1, CloudConfiguration.DatabaseUser, CloudConfiguration.DatabasePassword, CloudConfiguration.RunningInDev);

            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();

                using (var command = new SqlCommand(sqlScript, connection))
                {
                    var reader = command.ExecuteReader();

                    while (reader.Read())
                    {
                        seatSections.Add(new SeatSectionModel
                        {
                            SeatSectionId = !Convert.IsDBNull(reader["SeatSectionId"]) ? Convert.ToInt32(reader["SeatSectionId"]) : default(int),
                            VenueId = !Convert.IsDBNull(reader["VenueId"]) ? Convert.ToInt32(reader["VenueId"]) : default(int),
                            SeatCount = !Convert.IsDBNull(reader["SeatCount"]) ? Convert.ToInt32(reader["SeatCount"]) : default(int),
                            Description = !Convert.IsDBNull(reader["Description"]) ? Convert.ToString(reader["Description"]) : default(string),
                        });
                    }
                }
            }

            return seatSections;
        }

        #endregion

        #region - Public Methods -

        public int GetSeatCount(int seatSectionId)
        {
            return _seatSections.First(s => s.SeatSectionId == seatSectionId).SeatCount;
        }

        public int CalculateSum(int venueId, int seatSectionId)
        {
            return _seatSections.Where(s => s.VenueId == venueId && s.SeatSectionId < seatSectionId).Sum(s => s.SeatCount);
        }

        #endregion
    }
}
