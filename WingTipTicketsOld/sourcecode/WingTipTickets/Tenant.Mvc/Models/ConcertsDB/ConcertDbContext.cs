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
        #region - Constants -

        private const int ConstConcertduration = 3;

        private const String ConstGetAllConcertsQuery = @"SELECT concerts.ConcertId as concertId,
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
                                                        FROM     [Concerts] as concerts
                                                        JOIN     [dbo].Performers as performers ON concerts.PerformerId = performers.PerformerId";

        private const String ConstInsertNewConcert = @"INSERT INTO [Concerts] (ConcertName, Description, ConcertDate, Duration, VenueId, PerformerId, SaveToDbServerType)
                                                       VALUES ('{0}', '{1}', '{2}', {3}, {4}, {5}, {6})";

        private const String ConstOrderByConcertDate = @" ORDER BY concerts.ConcertDate";

        private const String ConstOrderByConcertName = @" ORDER BY concerts.ConcertName";

        #endregion

        #region - Get Methods -

        public List<Concert> GetConcerts(int venueId = 0, bool orderByName = false)
        {
            var concertsList = new List<Concert>();
            var dbConnectionString = ConstructConcertsConnnectString();

            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();
                    SqlCommand queryCommand;

                    if (venueId == 0)
                    {
                        queryCommand = new SqlCommand(String.Format("{0}", ConstGetAllConcertsQuery), dbConnection);
                    }
                    else
                    {
                        var query = String.Format("{0} WHERE concerts.VenueId={1} {2}", ConstGetAllConcertsQuery, venueId, orderByName ? ConstOrderByConcertName : ConstOrderByConcertDate);
                        queryCommand = new SqlCommand(query, dbConnection);
                    }

                    using (var reader = queryCommand.ExecuteReader())
                    {
                        try
                        {
                            while (reader.Read())
                            {
                                var tempConcert = PopulateSingleConcertFromDbReader(reader);

                                if (tempConcert != null)
                                {
                                    concertsList.Add(tempConcert);
                                }
                            }
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

            return concertsList;
        }

        public Concert GetConcertById(int concertId)  
        {
            Concert concertToReturn = null;
            var dbConnectionString = ConstructConcertsConnnectString();

            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();

                    var getSingleConcertQuery = String.Format("{0} WHERE concerts.ConcertId={1} {2}", ConstGetAllConcertsQuery, concertId, ConstOrderByConcertDate);
                    var queryCommand = new SqlCommand(getSingleConcertQuery, dbConnection);

                    using (var reader = queryCommand.ExecuteReader())
                    {
                        try
                        {
                            if (reader.Read())
                            {
                                concertToReturn = PopulateSingleConcertFromDbReader(reader);
                            }
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
            var dbConnectionString = ConstructConcertsConnnectString();

            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();

                    var getSingleConcertQuery = String.Format("{0} WHERE concerts.ConcertName={1}", ConstGetAllConcertsQuery, concertName);
                    var queryCommand = new SqlCommand(getSingleConcertQuery, dbConnection);

                    using (var reader = queryCommand.ExecuteReader())
                    {
                        try
                        {
                            if (reader.Read())
                            {
                                concertToReturn = PopulateSingleConcertFromDbReader(reader);
                            }
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
            var saveToDbMap = new List<Tuple<int, int>>();
            const string queryCommandString = @"Select ConcertId as concertId, SaveToDbServerType as saveToDatabase From [Concerts] Order By concertId";

            using (var sqlConnection = new SqlConnection(ConstructConcertsConnnectString()))
            {
                sqlConnection.Open();

                using (var sqlCommand = new SqlCommand(queryCommandString, sqlConnection))
                {
                    using (var reader = sqlCommand.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            saveToDbMap.Add(new Tuple<int, int>(reader.GetInt32(0), reader.GetInt32(1)));
                        }
                    }
                }
            }

            return saveToDbMap;
        }

        public List<Performer> GetArtists()
        {
            var artistList = new List<Performer>();
            var dbConnectionString = ConstructConcertsConnnectString();

            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();
                    var queryCommand = new SqlCommand("Select PerformerId, FirstName, LastName, ShortName From Performers", dbConnection);

                    using (var reader = queryCommand.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var tempArtist = PopulateSingleArtistFromDbReader(reader);

                            if (tempArtist != null)
                            {
                                artistList.Add(tempArtist);
                            }
                        }
                    }
                }
                finally
                {
                    dbConnection.Close();
                }
            }

            return artistList;
        }

        public Performer GetArtistById(int artistId)
        {
            Performer artistToReturn = null;
            var dbConnectionString = ConstructConcertsConnnectString();

            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();
                    var queryCommand = new SqlCommand(String.Format("Select Top(1) * From Performers where PerformerId='{0}'", artistId), dbConnection);

                    using (var reader = queryCommand.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            artistToReturn = PopulateSingleArtistFromDbReader(reader);
                        }
                    }
                }
                finally
                {
                    dbConnection.Close();
                }
            }

            return artistToReturn;
        }

        public Performer GetArtistByName(String artistName)
        {
            Performer artistToReturn = null;
            var dbConnectionString = ConstructConcertsConnnectString();

            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();
                    var queryCommand = new SqlCommand(String.Format("Select Top(1) * From Performers Where ShortName='{0}'", artistName), dbConnection);

                    using (var reader = queryCommand.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            artistToReturn = PopulateSingleArtistFromDbReader(reader);
                        }
                    }
                }
                finally
                {
                    dbConnection.Close();
                }
            }

            return artistToReturn;
        }

        #endregion

        #region - Save Methods -

        public Concert SaveNewConcert(String concertName, String concertDescription, DateTime concertDateTime, ShardDbServerTargetEnum saveToDatabase,  int concertVenueId, int performerId) 
        {
            Concert concertToReturn = null; 
            var tempDs = new DataSet();

            #region Insert

            var insertQuery = String.Format(ConstInsertNewConcert, concertName, concertDescription, concertDateTime, ConstConcertduration, concertVenueId, performerId, (int)saveToDatabase);

            using (var insertConnection = new SqlConnection(ConstructConcertsConnnectString()))
            {
                insertConnection.Open();
                
                using (var insertCommand = new SqlCommand(insertQuery, insertConnection))
                {
                    insertCommand.ExecuteNonQuery(); 
                }

                insertConnection.Close();
                insertConnection.Dispose();
            }

            #endregion

            #region Get Information

            var getCommandQuery = string.Format("{0} WHERE (concerts.ConcertName='{1}' AND concerts.VenueId={2} AND concerts.PerformerId={3}) {4}", ConstGetAllConcertsQuery, concertName, concertVenueId, performerId, ConstOrderByConcertDate);

            using (var getConnection = new SqlConnection(ConstructConcertsConnnectString()))
            {
                getConnection.Open();

                using (var reader = new SqlCommand(getCommandQuery, getConnection).ExecuteReader())
                {
                    if (reader.Read())
                    {
                        concertToReturn = PopulateSingleConcertFromDbReader(reader);
                    }
                }

                getConnection.Close();
                getConnection.Dispose();
            }

            #endregion

            #region Populate Ticket Levels

            var i = 1;
            var seatSectionQuery = string.Format(@"SELECT * FROM [SeatSection] Where VenueId={0}", concertVenueId);

            using (var seatCommand = new SqlCommand(seatSectionQuery, new SqlConnection(ConstructVenuesConnectString())))
            {
                using (var seatDataAdapter = new SqlDataAdapter(seatCommand))
                {
                    seatDataAdapter.Fill(tempDs);

                    if (tempDs.Tables.Count > 0 && tempDs.Tables[0].Rows.Count > 0)
                    {
                        foreach (DataRow drSeat in tempDs.Tables[0].Rows)
                        {
                            var ticketLevelInsert = string.Format(@"INSERT INTO [TicketLevels] (Description, SeatSectionId, ConcertId, TicketPrice) Values('Level-{0}', {0}, {1}, '{2}')", drSeat["SeatSectionId"].ToString(), concertToReturn.ConcertId, (50 + (5 * i++)).ToString() + ".00");

                            using (var ticketConnection = new SqlConnection(ConstructTicketConnectString()))
                            {
                                ticketConnection.Open();

                                using (var ticketCommand = new SqlCommand(ticketLevelInsert, ticketConnection))
                                {
                                    ticketCommand.ExecuteNonQuery();
                                }

                                ticketConnection.Close();
                                ticketConnection.Dispose();
                            }
                        }
                    }
                }
            }

            #endregion

            VenuesDbContext.LogAction("Added new concert " + concertName + " for venueId " + concertVenueId);

            return concertToReturn;
        }

        public Performer AddNewArtist(String artistName)
        {
            var dsInsert = new DataSet();
            var insertQuery = String.Format("Insert Into Performers (FirstName, LastName, ShortName) Values ('{0}', '{1}', '{0} {1}') Select @@Identity", artistName.Split(' ')[0], artistName.Split(' ')[1]);

            using (var insertCommand = new SqlCommand(insertQuery, new SqlConnection(ConstructConcertsConnnectString())))
            {
                using (var insertData = new SqlDataAdapter(insertCommand))
                {
                    insertData.Fill(dsInsert);

                    if (dsInsert.Tables.Count > 0 && dsInsert.Tables[0].Rows.Count > 0 && dsInsert.Tables[0].Rows[0][0] != DBNull.Value)
                    {
                        return new Performer
                        {
                            PerformerId = Int32.Parse(dsInsert.Tables[0].Rows[0][0].ToString()), 
                            ShortName = artistName, 
                            FirstName = artistName.Split(' ')[0], 
                            LastName = artistName.Split(' ')[1]
                        };
                    }
                }
            }

            return null;
        }

        #endregion

        #region - Delete Methods -

        public Boolean DeleteConcert(int concertId) 
        {
            var dbConnectionString = ConstructConcertsConnnectString();

            using (var dbConnection = new SqlConnection(dbConnectionString))
            {
                try
                {
                    dbConnection.Open();

                    var getSingleConcertQuery = String.Format("DELETE FROM Concerts WHERE concerts.ConcertId={0}", concertId);
                    var queryCommand = new SqlCommand(getSingleConcertQuery, dbConnection);

                    queryCommand.ExecuteNonQuery();
                }
                finally
                {
                    dbConnection.Close();
                }
            }

            VenuesDbContext.LogAction("Deleted concert " + concertId);

            return true;
        }

        #endregion

        #region - Private Methods -

        private Concert PopulateSingleConcertFromDbReader(SqlDataReader dbReader) 
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
                SaveToDbServer = (dbReader.IsDBNull(dbReader.GetOrdinal(@"saveToDatabase"))) 
                    ? ((int)ShardDbServerTargetEnum.Primary) 
                    : ((ShardDbServerTargetEnum)dbReader.GetInt32(dbReader.GetOrdinal(@"saveToDatabase")))
            };

            return concertToReturn;
        }

        private Performer PopulateSingleArtistFromDbReader(SqlDataReader dbReader)
        {
            return new Performer
            {
                PerformerId = dbReader.GetInt32(dbReader.GetOrdinal(@"PerformerId")),
                FirstName = dbReader.GetString(dbReader.GetOrdinal(@"FirstName")),
                LastName = dbReader.GetString(dbReader.GetOrdinal(@"LastName")),
                ShortName = dbReader.GetString(dbReader.GetOrdinal(@"ShortName"))
            };
        }

        private String ConstructConcertsConnnectString()
        {
            return WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName);
        }

        private String ConstructTicketConnectString()
        {
            return WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName);
        }

        private String ConstructVenuesConnectString()
        {
            return WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName);
        }

        #endregion
    }
}