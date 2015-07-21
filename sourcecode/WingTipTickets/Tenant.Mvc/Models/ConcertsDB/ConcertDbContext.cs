using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Tenant.Mvc.Models.VenuesDB;
using WingTipTickets;

namespace Tenant.Mvc.Models.ConcertsDB
{
    public class ConcertDbContext
    {
        #region Private Variables
        private const int CONST_CONCERTDURATION = 3; //Default duration of concert in hours
        private const String CONST_GetAllConcertsQuery = @"SELECT concerts.ConcertId as concertId,
                                                    concerts.VenueId as venueId,
                                                    concerts.PerformerId as concertPerformerId,
		                                            concerts.ConcertDate as concertDate,
		                                            concerts.ConcertName as concertName,
		                                            concerts.Description as concertDescription,
		                                            concerts.Duration as concertDuration,
                                                    concerts.SaveToDbServerType as saveToDatabase,
		                                            performers.PerformerId as performerId,
                                                    performers.FirstName as performerFirstName,
		                                            performers.LastName as performerLastName,
		                                            performers.ShortName as performerShortName
                                              FROM [Concerts] as concerts
                                               INNER JOIN [dbo].Performers as performers ON concerts.PerformerId = performers.PerformerId";

        private const String CONST_InsertNewConcert = @"INSERT INTO [Concerts] (ConcertName, Description, ConcertDate, Duration, VenueId, PerformerId, SaveToDbServerType)
                                                    VALUES ('{0}', '{1}', '{2}', {3}, {4}, {5}, {6})";

        private const String CONST_OrderByConcertDate = @" ORDER BY concerts.ConcertDate";
        private const String CONST_OrderByConcertName = @" ORDER BY concerts.ConcertName";
        #endregion Private Variables

        #region Get
        public List<Concert> GetConcerts(int venueId = 0, bool orderByName = false)
        {
            List<Concert> concertsList = new List<Concert>();
            var dbConnectionString = constructConcertsConnnectString();
            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();
                    SqlCommand queryCommand = null;
                    if (venueId == 0)
                        //queryCommand = new SqlCommand(String.Format("{0} WHERE concerts.ConcertDate > GETDATE() {1}", CONST_GetAllConcertsQuery, CONST_OrderByConcertDate), dbConnection);
                        queryCommand = new SqlCommand(String.Format("{0}", CONST_GetAllConcertsQuery), dbConnection);
                    else
                    {
                        string query = String.Format("{0} WHERE concerts.VenueId={1} {2}", CONST_GetAllConcertsQuery, venueId, orderByName ? CONST_OrderByConcertName : CONST_OrderByConcertDate);
                        queryCommand = new SqlCommand(query, dbConnection);
                    }
                    using (SqlDataReader reader = queryCommand.ExecuteReader())
                    {
                        try
                        {
                            Concert tempConcert = null;
                            while (reader.Read())
                            {
                                tempConcert = populateSingleConcertFromDbReader(reader);
                                if (tempConcert != null)
                                    concertsList.Add(tempConcert);
                            }
                        }
                        finally
                        {
                            reader.Close();
                        }
                    }
                }
                catch { }
                finally
                {
                    dbConnection.Close();
                }
            }

            return concertsList;
        }
        public Concert GetConcertById(int concertId)  {
            Concert concertToReturn = null;
            var dbConnectionString = constructConcertsConnnectString();
            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();
                    String getSingleConcertQuery = String.Format("{0} WHERE concerts.ConcertId={1} {2}",
                                    CONST_GetAllConcertsQuery, concertId, CONST_OrderByConcertDate);
                    var queryCommand = new SqlCommand(getSingleConcertQuery, dbConnection);
                    using (SqlDataReader reader = queryCommand.ExecuteReader())
                    {
                        try
                        {
                            if (reader.Read())
                                concertToReturn = populateSingleConcertFromDbReader(reader);
                        }
                        finally
                        {
                            reader.Close();
                        }
                    }
                }
                finally
                {
                    dbConnection.Close();
                }
            }
            return concertToReturn;
        }
        public Concert GetConcertByName(String concertName)
        {
            Concert concertToReturn = null;
            var dbConnectionString = constructConcertsConnnectString();
            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();
                    String getSingleConcertQuery = String.Format("{0} WHERE concerts.ConcertName={1}",
                                    CONST_GetAllConcertsQuery, concertName);
                    var queryCommand = new SqlCommand(getSingleConcertQuery, dbConnection);
                    using (SqlDataReader reader = queryCommand.ExecuteReader())
                    {
                        try
                        {
                            if (reader.Read())
                                concertToReturn = populateSingleConcertFromDbReader(reader);
                        }
                        finally
                        {
                            reader.Close();
                        }
                    }
                }
                finally
                {
                    dbConnection.Close();
                }
            }
            return concertToReturn;
        }
        public List<Tuple<int, int>> GetConcertIdToDbSaveMap()
        {
            List<Tuple<int, int>> saveToDbMap = new List<Tuple<int, int>>();
            try
            {
                String queryCommandString = @"Select ConcertId as concertId, SaveToDbServerType as saveToDatabase From [Concerts] Order By concertId";
                using (var sqlConnection = new SqlConnection(constructConcertsConnnectString()))
                {
                    sqlConnection.Open();
                    using (var sqlCommand = new SqlCommand(queryCommandString, sqlConnection))
                    using (SqlDataReader reader = sqlCommand.ExecuteReader())
                        while (reader.Read())
                            saveToDbMap.Add(new Tuple<int, int>(reader.GetInt32(0), reader.GetInt32(1)));
                }
            }
            catch { }
            return saveToDbMap;
        }

        public List<Performer> GetArtists()
        {
            List<Performer> artistList = new List<Performer>();
            var dbConnectionString = constructConcertsConnnectString();
            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();
                    SqlCommand queryCommand = new SqlCommand("Select PerformerId, FirstName, LastName, ShortName From Performers", dbConnection);
                    using (SqlDataReader reader = queryCommand.ExecuteReader())
                    {
                        try
                        {
                            Performer tempArtist = null;
                            while (reader.Read())
                            {
                                tempArtist = populateSingleArtistFromDbReader(reader);
                                if (tempArtist != null)
                                    artistList.Add(tempArtist);
                            }
                        }
                        catch { }
                    }
                }
                finally { dbConnection.Close(); }
            }

            return artistList;
        }
        public Performer GetArtistById(int artistId)
        {
            Performer artistToReturn = null;
            var dbConnectionString = constructConcertsConnnectString();
            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();
                    var queryCommand = new SqlCommand(String.Format("Select Top(1) * From Performers where PerformerId='{0}'", artistId), dbConnection);
                    using (SqlDataReader reader = queryCommand.ExecuteReader())
                    {
                        try
                        {
                            if (reader.Read())
                                artistToReturn = populateSingleArtistFromDbReader(reader);
                        }
                        catch { }
                    }
                }
                finally { dbConnection.Close(); }
            }
            return artistToReturn;
        }
        public Performer GetArtistByName(String artistName)
        {
            Performer artistToReturn = null;
            var dbConnectionString = constructConcertsConnnectString();
            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();
                    var queryCommand = new SqlCommand(String.Format("Select Top(1) * From Performers Where ShortName='{0}'", artistName), dbConnection);
                    using (SqlDataReader reader = queryCommand.ExecuteReader())
                    {
                        try
                        {
                            if (reader.Read())
                                artistToReturn = populateSingleArtistFromDbReader(reader);
                        }
                        catch { }
                    }
                }
                finally { dbConnection.Close(); }
            }
            return artistToReturn;
        }

        #endregion Get

        #region Save
        public Concert SaveNewConcert(String concertName, String concertDescription, DateTime concertDateTime, ShardDbServerTargetEnum saveToDatabase,  int concertVenueId, int performerId) {
            Concert concertToReturn = null; DataSet tempDS = new DataSet();

            #region Insert
            string insertQuery = String.Format(CONST_InsertNewConcert, concertName, concertDescription, concertDateTime, CONST_CONCERTDURATION, concertVenueId, performerId, (int)saveToDatabase);
            using (var insertConnection = new SqlConnection(constructConcertsConnnectString()))
            {
                insertConnection.Open();
                using (var insertCommand = new SqlCommand(insertQuery, insertConnection))
                { insertCommand.ExecuteNonQuery(); }
                insertConnection.Close();
                insertConnection.Dispose();
            }
            #endregion Insert

            #region Get Information
            string getCommandQuery = string.Format("{0} WHERE (concerts.ConcertName='{1}' AND concerts.VenueId={2} AND concerts.PerformerId={3}) {4}",
                CONST_GetAllConcertsQuery, concertName, concertVenueId, performerId, CONST_OrderByConcertDate);
            using (var getConnection = new SqlConnection(constructConcertsConnnectString()))
            {
                getConnection.Open();
                using (var reader = new SqlCommand(getCommandQuery, getConnection).ExecuteReader())
                { if (reader.Read()) concertToReturn = populateSingleConcertFromDbReader(reader); }
                getConnection.Close();
                getConnection.Dispose();
            }
            #endregion Get Information

            #region Populate Ticket Levels
            int i = 1;
            string seatSectionQuery = string.Format(@"SELECT * FROM [SeatSection] Where VenueId={0}", concertVenueId);
            using (var seatCommand = new SqlCommand(seatSectionQuery, new SqlConnection(constructVenuesConnectString())))
            using (var seatDataAdapter = new SqlDataAdapter(seatCommand))
            {
                seatDataAdapter.Fill(tempDS);
                if (tempDS.Tables.Count > 0 && tempDS.Tables[0].Rows.Count > 0)
                    foreach (DataRow drSeat in tempDS.Tables[0].Rows)
                    {
                        string ticketLevelInsert = string.Format(@"INSERT INTO [TicketLevels] (Description, SeatSectionId, ConcertId, TicketPrice) Values('Level-{0}', {0}, {1}, '{2}')", drSeat["SeatSectionId"].ToString(), concertToReturn.ConcertId, (50 + (5 * i++)).ToString() + ".00");
                        using (var ticketConnection = new SqlConnection(constructTicketConnectString()))
                        {
                            ticketConnection.Open();
                            using (var ticketCommand = new SqlCommand(ticketLevelInsert, ticketConnection))
                            { ticketCommand.ExecuteNonQuery(); }
                            ticketConnection.Close();
                            ticketConnection.Dispose();
                        }
                    }
            }
            #endregion Populate Ticket Levels

            VenuesDbContext.LogAction("Added new concert " + concertName + " for venueId " + concertVenueId);
            return concertToReturn;

        }
        public Performer AddNewArtist(String ArtistName)
        {
            DataSet dsInsert = new DataSet();
            try
            {
                string insertQuery = String.Format("Insert Into Performers (FirstName, LastName, ShortName) Values ('{0}', '{1}', '{0} {1}') Select @@Identity", ArtistName.Split(' ')[0], ArtistName.Split(' ')[1]);
                using (var insertCommand = new SqlCommand(insertQuery, new SqlConnection(constructConcertsConnnectString())))
                using (var insertData = new SqlDataAdapter(insertCommand))
                {
                    insertData.Fill(dsInsert);
                    if (dsInsert.Tables.Count > 0 && dsInsert.Tables[0].Rows.Count > 0 && dsInsert.Tables[0].Rows[0][0] != DBNull.Value)
                        return new Performer { PerformerId = Int32.Parse(dsInsert.Tables[0].Rows[0][0].ToString()), ShortName = ArtistName, FirstName = ArtistName.Split(' ')[0], LastName = ArtistName.Split(' ')[1] };
                }
            }
            catch { }
            return null;
        }
        #endregion Save

        #region Delete
        public Boolean DeleteConcert(int concertId) {
            Boolean operationResult = true;
            var dbConnectionString = constructConcertsConnnectString();
            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();
                    String getSingleConcertQuery = String.Format("DELETE FROM Concerts WHERE concerts.ConcertId={0}", concertId);
                    var queryCommand = new SqlCommand(getSingleConcertQuery, dbConnection);
                    queryCommand.ExecuteNonQuery();
                } catch(Exception) {
                    operationResult = false;
                }
                finally
                {
                    dbConnection.Close();
                }
            }
            VenuesDbContext.LogAction("Deleted concert " + concertId);
            return operationResult;
        }
        #endregion Delete

        #region Private Functions
        private Concert populateSingleConcertFromDbReader(SqlDataReader dbReader) {
            try
            {
                var concertPerformer = new Performer
                {
                    PerformerId = dbReader.GetInt32(dbReader.GetOrdinal(@"performerId")),
                    FirstName = dbReader.GetString(dbReader.GetOrdinal(@"performerFirstName")),
                    LastName = dbReader.GetString(dbReader.GetOrdinal(@"performerLastName")),
                    ShortName = dbReader.GetString(dbReader.GetOrdinal(@"performerShortName"))
                };
                var concertToReturn = new Concert
                {
                    ConcertId = dbReader.GetInt32(dbReader.GetOrdinal(@"concertId")),
                    ConcertDate = dbReader.GetDateTime(dbReader.GetOrdinal(@"concertDate")),
                    ConcertName = dbReader.GetString(dbReader.GetOrdinal(@"concertName")),
                    VenueId = dbReader.GetInt32(dbReader.GetOrdinal(@"venueId")),
                    Description = dbReader.GetString(dbReader.GetOrdinal(@"concertDescription")),
                    PerformerId = dbReader.GetInt32(dbReader.GetOrdinal(@"concertPerformerId")),
                    Performer = concertPerformer,
                    SaveToDbServer = (dbReader.IsDBNull(dbReader.GetOrdinal(@"saveToDatabase"))) ?
                                        ((int)ShardDbServerTargetEnum.Primary) :
                                        ((ShardDbServerTargetEnum)dbReader.GetInt32(dbReader.GetOrdinal(@"saveToDatabase")))
                };
                return concertToReturn;
            }
            catch { }
            return null;
        }
        private Performer populateSingleArtistFromDbReader(SqlDataReader dbReader)
        {
            try
            {
                return new Performer
                {
                    PerformerId = dbReader.GetInt32(dbReader.GetOrdinal(@"PerformerId")),
                    FirstName = dbReader.GetString(dbReader.GetOrdinal(@"FirstName")),
                    LastName = dbReader.GetString(dbReader.GetOrdinal(@"LastName")),
                    ShortName = dbReader.GetString(dbReader.GetOrdinal(@"ShortName"))
                };
            }
            catch { }
            return null;
        }

        private String constructConcertsConnnectString()
            { return WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName); }
        private String constructTicketConnectString()
            { return WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName); }
        private String constructVenuesConnectString()
            { return WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName); }
        #endregion Private Functions
    }
}