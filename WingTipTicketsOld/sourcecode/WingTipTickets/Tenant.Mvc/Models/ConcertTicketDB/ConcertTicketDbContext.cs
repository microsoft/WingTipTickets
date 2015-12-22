using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Tenant.Mvc.Models.CustomersDB;
using WingTipTickets;

namespace Tenant.Mvc.Models.ConcertTicketDB
{
    public class ConcertTicketDbContext
    {
        #region - Get Methods -

        public List<ConcertTicket> ReturnPurchasedTicketsByConcertId(int customerId, long concertId = 0)
        {
            var ticketList = new List<ConcertTicket>();
            var ticketsPurchasedByConcertIdQuery = String.Format(@"SELECT TicketId, CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate FROM Tickets WHERE (ConcertId=" + concertId + " AND CustomerId=" + customerId +")" , concertId);

            using (var cmd = new SqlCommand(ticketsPurchasedByConcertIdQuery, new SqlConnection(ConstructTicketsDbConnnectString())))
            {
                using (var sdAdapter = new SqlDataAdapter(cmd))
                {
                    using (var dsTickets = new DataSet())
                    {
                        sdAdapter.Fill(dsTickets);

                        foreach (DataRow drTicket in dsTickets.Tables[0].Rows)
                        {
                            ticketList.Add(new ConcertTicket(Convert.ToInt32(drTicket[0].ToString()), Convert.ToInt32(drTicket[1].ToString()), drTicket[2].ToString(), Convert.ToInt32(drTicket[4].ToString()), Convert.ToInt32(drTicket[3].ToString()), 0, Convert.ToDateTime(drTicket[5].ToString())));
                        }
                    }
                }
            }

            return ticketList;
        }

        public List<ConcertTicket> ReturnPurchasedTicketsByCustomerId(int customerId)
        {
            var ticketList = new List<ConcertTicket>();
            var ticketsPurchasedByCustomerIdQuery = String.Format(@"SELECT TicketId, CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate FROM Tickets WHERE (CustomerId=" + customerId + ")");

            using (var cmd = new SqlCommand(ticketsPurchasedByCustomerIdQuery, new SqlConnection(ConstructTicketsDbConnnectString())))
            {
                using (var sdAdapter = new SqlDataAdapter(cmd))
                {
                    using (var dsTickets = new DataSet())
                    {
                        sdAdapter.Fill(dsTickets);

                        foreach (DataRow drTicket in dsTickets.Tables[0].Rows)
                        {
                            ticketList.Add(new ConcertTicket(Convert.ToInt32(drTicket[0].ToString()), Convert.ToInt32(drTicket[1].ToString()), drTicket[2].ToString(), Convert.ToInt32(drTicket[4].ToString()), Convert.ToInt32(drTicket[3].ToString()), 0, Convert.ToDateTime(drTicket[5].ToString())));
                        }
                    }
                }
            }

            return ticketList;
        }

        public List<ConcertTicketLevel> GetTicketLevelById(int concertId)
        {
            var ticketLevelsForConcert = new List<ConcertTicketLevel>();
            var ticketLevelQuery = "SELECT TicketLevelId, Description, SeatSectionId, TicketPrice FROM TicketLevels WHERE ConcertId=" + concertId;

            using (var cmd = new SqlCommand(ticketLevelQuery, new SqlConnection(ConstructTicketsDbConnnectString())))
            {
                using (var sdAdapter = new SqlDataAdapter(cmd))
                {
                    using (var dsTickets = new DataSet())
                    {
                        sdAdapter.Fill(dsTickets);

                        if (dsTickets.Tables.Count > 0 && dsTickets.Tables[0].Rows.Count > 0)
                        {
                            foreach (DataRow drTicket in dsTickets.Tables[0].Rows)
                            {
                                ticketLevelsForConcert.Add(new ConcertTicketLevel(Convert.ToInt32(drTicket["TicketLevelId"]), drTicket["Description"].ToString(), concertId, Convert.ToInt32(drTicket["SeatSectionId"]), Convert.ToDecimal(drTicket["TicketPrice"])));
                            }
                        }
                    }
                }
            }

            return ticketLevelsForConcert;
        }

        public List<ConcertTicketLevel> GetTicketLevels()
        {
            var ticketLevels = new List<ConcertTicketLevel>();
            const string ticketLevelQuery = "SELECT TicketLevelId, Description, SeatSectionId, ConcertId, TicketPrice FROM TicketLevels";

            using (var cmd = new SqlCommand(ticketLevelQuery, new SqlConnection(ConstructTicketsDbConnnectString())))
            {
                using (var sdAdapter = new SqlDataAdapter(cmd))
                {
                    using (var dsTickets = new DataSet())
                    {
                        sdAdapter.Fill(dsTickets);

                        if (dsTickets.Tables.Count > 0 && dsTickets.Tables[0].Rows.Count > 0)
                        {
                            foreach (DataRow drTicket in dsTickets.Tables[0].Rows)
                            {
                                ticketLevels.Add(new ConcertTicketLevel(Convert.ToInt32(drTicket["TicketLevelId"]), drTicket["Description"].ToString(), Convert.ToInt32(drTicket["ConcertId"]), Convert.ToInt32(drTicket["SeatSectionId"]), Convert.ToDecimal(drTicket["TicketPrice"])));
                            }
                        }
                    }
                }
            }

            return ticketLevels;
        }    

        #endregion

        #region - Save Methods -

        public List<ConcertTicket> WriteNewTicketToDb(Customer customer, int concertId, int seatMapId, int ticketPrice, int ticketCount)
        {
            using (var insertConnection = new SqlConnection(ConstructTicketsDbConnnectString()))
            {
                insertConnection.Open();

                for (var i = 0; i < ticketCount; i++)
                {
                    var ticketName = String.Format("Ticket ({0} of {1}) for user {2} to concert-{3}", (i + 1), ticketCount, customer.FirstName, concertId);
                    var insertQuery = String.Format(@"INSERT INTO Tickets (CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate) VALUES ('{0}', '{1}', '{2}', '{3}', '{4}')", customer.CustomerId, ticketName, seatMapId, concertId, DateTime.Now);

                    using (var insertCommand = new SqlCommand(insertQuery, insertConnection))
                    {
                        insertCommand.ExecuteNonQuery();
                    }
                }

                insertConnection.Close();
                insertConnection.Dispose();
            }

            return ReturnPurchasedTicketsByConcertId(customer.CustomerId, concertId);
        }

        #endregion

        #region - Delete Methods -

        public void DeleteAllTicketsForConcert(int concertId)
        {
            // Delete all tickets and ticket levels for this concert
            using (var dbConnection = new SqlConnection(ConstructTicketsDbConnnectString()))
            {
                dbConnection.Open();

                using (var cmd = new SqlCommand(String.Format(@"DELETE FROM [TicketLevels] WHERE ConcertId = {0}", concertId), dbConnection))
                {
                    cmd.ExecuteNonQuery();
                }

                using (var cmd = new SqlCommand(String.Format(@"DELETE FROM [Tickets] WHERE ConcertId = {0}", concertId), dbConnection))
                {
                    cmd.ExecuteNonQuery();
                }
            }
        }

        #endregion

        #region - Private Methods -

        private string ConstructTicketsDbConnnectString()
        {
            return WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName);
        }

        #endregion
    }
}
 