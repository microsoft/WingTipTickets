using System;
using System.Data.SqlClient;

namespace IOTSoundReaderEmulator.Repositories
{
    public class SeatSectionRepository
    {
        #region Public methods

        public int GetSeatCount(int seatSectionId)
        {
            int seatCount = 0;
            string sqlScript = "SELECT SeatCount FROM [dbo].[SeatSection] WHERE [SeatSectionId] = " + seatSectionId;

            var connectionString = Helpers.Helper.BuildConnectionString(CloudConfiguration.TenantPrimaryDatabaseServer, CloudConfiguration.TenantDatabase1, CloudConfiguration.DatabaseUser, CloudConfiguration.DatabasePassword, CloudConfiguration.RunningInDev);

            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();

                using (var command = new SqlCommand(sqlScript, connection))
                {
                    var reader = command.ExecuteReader();

                    if (reader.Read())
                    {
                        seatCount = !Convert.IsDBNull(reader["SeatCount"])
                            ? Convert.ToInt32(reader["SeatCount"])
                            : default(int);
                    }
                }
            }

            return seatCount;
        }

        public int CalculateSum(int venueId, int seatSectionId)
        {
            int sum = 0;

            string sqlScript =
                $"SELECT Sum(SeatCount) FROM [dbo].[SeatSection] WHERE [VenueId] = {venueId} AND [SeatSectionId] < {seatSectionId}";

            var connectionString = Helpers.Helper.BuildConnectionString(CloudConfiguration.TenantPrimaryDatabaseServer, CloudConfiguration.TenantDatabase1, CloudConfiguration.DatabaseUser, CloudConfiguration.DatabasePassword, CloudConfiguration.RunningInDev);

            using (var connection = new SqlConnection(connectionString))
            {
                connection.Open();

                using (var command = new SqlCommand(sqlScript, connection))
                {
                    sum = (int)command.ExecuteScalar();
                }
            }
            
            return sum;
        }

        #endregion
    }
}
