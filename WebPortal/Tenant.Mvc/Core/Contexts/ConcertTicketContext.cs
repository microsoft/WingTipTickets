using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using Tenant.Mvc.Core.Models;
using WingTipTickets;

namespace Tenant.Mvc.Core.Contexts
{
    public partial class DatabaseContext
    {
        public class ConcertTicketContext
        {
            #region - Get Methods -

            public List<ConcertTicket> ReturnPurchasedTicketsByConcertId(int customerId, long concertId = 0)
            {
                var ticketList = new List<ConcertTicket>();
                var ticketsPurchasedByConcertIdQuery = String.Format(@"SELECT TicketId, CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate, SeatNumber FROM Tickets WHERE (ConcertId=" + concertId + " AND CustomerId=" + customerId + ")", concertId);

                using (var cmd = new SqlCommand(ticketsPurchasedByConcertIdQuery, WingtipTicketApp.CreateTenantConnectionDatabase1()))
                {
                    using (var sdAdapter = new SqlDataAdapter(cmd))
                    {
                        using (var dsTickets = new DataSet())
                        {
                            sdAdapter.Fill(dsTickets);

                            ticketList.AddRange(
                                from DataRow drTicket in dsTickets.Tables[0].Rows
                                select new ConcertTicket(Convert.ToInt32(drTicket[0].ToString()), Convert.ToInt32(drTicket[1].ToString()), drTicket[2].ToString(), Convert.ToInt32(drTicket[4].ToString()), Convert.ToInt32(drTicket[3].ToString()), 0, Convert.ToDateTime(drTicket[5].ToString()), drTicket[6].ToString()));
                        }
                    }
                }

                return ticketList;
            }

            public List<ConcertTicket> ReturnPurchasedTicketsByCustomerId(int customerId)
            {
                var ticketList = new List<ConcertTicket>();
                var ticketsPurchasedByCustomerIdQuery = String.Format(@"SELECT TicketId, CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate, SeatNumber FROM Tickets WHERE (CustomerId=" + customerId + ")");

                using (var cmd = new SqlCommand(ticketsPurchasedByCustomerIdQuery, WingtipTicketApp.CreateTenantConnectionDatabase1()))
                {
                    using (var sdAdapter = new SqlDataAdapter(cmd))
                    {
                        using (var dsTickets = new DataSet())
                        {
                            sdAdapter.Fill(dsTickets);

                            ticketList.AddRange(from DataRow drTicket in dsTickets.Tables[0].Rows 
                                                select new ConcertTicket(
                                                    Convert.ToInt32(drTicket[0].ToString()), 
                                                    Convert.ToInt32(drTicket[1].ToString()), 
                                                    drTicket[2].ToString(), 
                                                    Convert.ToInt32(drTicket[4].ToString()), 
                                                    Convert.ToInt32(drTicket[3].ToString()), 
                                                    0, 
                                                    Convert.ToDateTime(drTicket[5].ToString()), 
                                                    drTicket[6].ToString()));
                        }
                    }
                }

                return ticketList;
            }

            public List<ConcertTicketLevel> GetTicketLevelById(int concertId)
            {
                var ticketLevelsForConcert = new List<ConcertTicketLevel>();
                var ticketLevelQuery = "SELECT TicketLevelId, Description, SeatSectionId, TicketPrice FROM TicketLevels WHERE ConcertId=" + concertId;

                using (var cmd = new SqlCommand(ticketLevelQuery, WingtipTicketApp.CreateTenantConnectionDatabase1()))
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

                using (var cmd = new SqlCommand(ticketLevelQuery, WingtipTicketApp.CreateTenantConnectionDatabase1()))
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

            public List<ConcertTicket> WriteNewTicketToDb(List<PurchaseTicketsModel> model)
            {
                List<ConcertTicket> purchasedTickets = new List<ConcertTicket>();

                using (var insertConnection = WingtipTicketApp.CreateTenantConnectionDatabase1())
                {
                    insertConnection.Open();

                    for (var i = 0; i < model.Count; i++)
                    {
                        var ticketName = String.Format("Ticket ({0} of {1}) for user {2} to concert-{3}", (i + 1), model.Count, model[i].CustomerName, model[i].ConcertId);
                        var insertQuery = String.Format(@"INSERT INTO Tickets (CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate, SeatNumber) VALUES ('{0}', '{1}', '{2}', '{3}', '{4}', '{5}')", model[i].CustomerId, ticketName, model[i].SeatSectionId, model[i].ConcertId, DateTime.Now, model[i].Seat);

                        using (var insertCommand = new SqlCommand(insertQuery, insertConnection))
                        {
                            insertCommand.ExecuteNonQuery();
                        }

                        var tickets = ReturnPurchasedTicketsByConcertId(model[i].CustomerId, model[i].ConcertId);
                        purchasedTickets.AddRange(tickets);
                    }


                    insertConnection.Close();
                    insertConnection.Dispose();

                }

                return purchasedTickets;
            }

            #endregion

            #region - Delete Methods -

            public void DeleteAllTicketsForConcert(int concertId)
            {
                // Delete all tickets and ticket levels for this concert
                using (var dbConnection = WingtipTicketApp.CreateTenantConnectionDatabase1())
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
        }
    }
}
 