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
        #region Insert
        public List<ConcertTicket> WriteNewTicketToDb(Customer customer, int ConcertId, int SeatMapId, int ticketPrice, int ticketCount)
        {            
            using (var insertConnection = new SqlConnection(constructTicketsDbConnnectString()))
            {
                insertConnection.Open();
                for (int i = 0; i < ticketCount; i++)
                {
                    String ticketName = String.Format("Ticket ({0} of {1}) for user {2} to concert-{3}", (i + 1), ticketCount, customer.FirstName, ConcertId);
                    string insertQuery = String.Format(@"INSERT INTO Tickets (CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate) 
                    VALUES ('{0}', '{1}', '{2}', '{3}', '{4}')", customer.CustomerId, ticketName, SeatMapId, ConcertId, DateTime.Now);

                    using (var insertCommand = new SqlCommand(insertQuery, insertConnection))
                    { insertCommand.ExecuteNonQuery(); }
                }
                
                insertConnection.Close();
                insertConnection.Dispose();
            }

            return ReturnPurchasedTicketsByConcertId(customer.CustomerId, ConcertId);            
        }
        #endregion Insert
        
        #region Get
        public List<ConcertTicket> ReturnPurchasedTicketsByConcertId(int CustomerId, long ConcertId = 0)
        {
            List<ConcertTicket> TicketList = new List<ConcertTicket>();
            string ticketsPurchasedByConcertIdQuery = String.Format(@"SELECT TicketId, CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate 
                                    FROM Tickets WHERE (ConcertId=" + ConcertId.ToString() + " AND CustomerId="+CustomerId.ToString() +")" , ConcertId);                       
                       
            try
            {   
                using (SqlCommand cmd = new SqlCommand(ticketsPurchasedByConcertIdQuery, new SqlConnection(constructTicketsDbConnnectString())))
                using (SqlDataAdapter sdAdapter = new SqlDataAdapter(cmd))
                using (DataSet dsTickets = new DataSet())
                {
                    sdAdapter.Fill(dsTickets);
                    foreach (DataRow drTicket in dsTickets.Tables[0].Rows)
                        TicketList.Add(new ConcertTicket(Convert.ToInt32(drTicket[0].ToString()), Convert.ToInt32(drTicket[1].ToString()),
                            drTicket[2].ToString(), Convert.ToInt32(drTicket[4].ToString()), Convert.ToInt32(drTicket[3].ToString()), 0, Convert.ToDateTime(drTicket[5].ToString())));
                }
            }
            catch { }

            return TicketList;
        }
        public List<ConcertTicket> ReturnPurchasedTicketsByCustomerId(int CustomerId)
        {
            List<ConcertTicket> TicketList = new List<ConcertTicket>();
            
            string ticketsPurchasedByCustomerIdQuery = String.Format(@"SELECT TicketId, CustomerId, Name, TicketLevelId, ConcertId, PurchaseDate FROM Tickets WHERE (CustomerId=" + CustomerId.ToString() + ")");

            try
            {
                using (SqlCommand cmd = new SqlCommand(ticketsPurchasedByCustomerIdQuery, new SqlConnection(constructTicketsDbConnnectString())))
                using (SqlDataAdapter sdAdapter = new SqlDataAdapter(cmd))
                using (DataSet dsTickets = new DataSet())
                {
                    sdAdapter.Fill(dsTickets);
                    foreach (DataRow drTicket in dsTickets.Tables[0].Rows)
                        TicketList.Add(new ConcertTicket(Convert.ToInt32(drTicket[0].ToString()), Convert.ToInt32(drTicket[1].ToString()),
                            drTicket[2].ToString(), Convert.ToInt32(drTicket[4].ToString()), Convert.ToInt32(drTicket[3].ToString()), 0, Convert.ToDateTime(drTicket[5].ToString())));
                }
            }
            catch { }
                        
            return TicketList;
        }
        #endregion Get

        public List<ConcertTicketLevel> GetTicketLevelById(int concertId)
        {
            List<ConcertTicketLevel> ticketLevelsForConcert = new List<ConcertTicketLevel>();
            string ticketLevelQuery = "SELECT TicketLevelId, Description, SeatSectionId, TicketPrice FROM TicketLevels WHERE ConcertId=" + concertId.ToString();
            try
            {
                using (SqlCommand cmd = new SqlCommand(ticketLevelQuery, new SqlConnection(constructTicketsDbConnnectString())))
                using (SqlDataAdapter sdAdapter = new SqlDataAdapter(cmd))
                using (DataSet dsTickets = new DataSet())
                {
                    sdAdapter.Fill(dsTickets);
                    if (dsTickets.Tables.Count > 0 && dsTickets.Tables[0].Rows.Count > 0)
                        foreach (DataRow drTicket in dsTickets.Tables[0].Rows)
                            ticketLevelsForConcert.Add(new ConcertTicketLevel(Convert.ToInt32(drTicket["TicketLevelId"]), drTicket["Description"].ToString(), concertId, Convert.ToInt32(drTicket["SeatSectionId"]), Convert.ToDecimal(drTicket["TicketPrice"])));
                }
            }
            catch { }

            return ticketLevelsForConcert;
        }

        public List<ConcertTicketLevel> GetTicketLevels()
        {
            List<ConcertTicketLevel> ticketLevels = new List<ConcertTicketLevel>();
            string ticketLevelQuery = "SELECT TicketLevelId, Description, SeatSectionId, ConcertId, TicketPrice FROM TicketLevels";
            try
            {
                using (SqlCommand cmd = new SqlCommand(ticketLevelQuery, new SqlConnection(constructTicketsDbConnnectString())))
                using (SqlDataAdapter sdAdapter = new SqlDataAdapter(cmd))
                using (DataSet dsTickets = new DataSet())
                {
                    sdAdapter.Fill(dsTickets);
                    if (dsTickets.Tables.Count > 0 && dsTickets.Tables[0].Rows.Count > 0)
                        foreach (DataRow drTicket in dsTickets.Tables[0].Rows)
                            ticketLevels.Add(new ConcertTicketLevel(Convert.ToInt32(drTicket["TicketLevelId"]), drTicket["Description"].ToString(), Convert.ToInt32(drTicket["ConcertId"]), Convert.ToInt32(drTicket["SeatSectionId"]), Convert.ToDecimal(drTicket["TicketPrice"])));
                }
            }
            catch { }

            return ticketLevels;
        }        
        public void DeleteAllTicketsForConcert(int concertId)
        {
            //Delete all tickets and ticket levels for this concert
            try
            {
                using (var dbConnection = new SqlConnection(constructTicketsDbConnnectString()))
                {
                    dbConnection.Open();
                    using (SqlCommand cmd = new SqlCommand(String.Format(@"DELETE FROM [TicketLevels] WHERE ConcertId = {0}", concertId), dbConnection))
                        { cmd.ExecuteNonQuery(); }
                    using (SqlCommand cmd = new SqlCommand(String.Format(@"DELETE FROM [Tickets] WHERE ConcertId = {0}", concertId), dbConnection))
                    { cmd.ExecuteNonQuery(); }
                }
            }
            catch { }                        
        }

        #region Private Functions
        private string constructTicketsDbConnnectString()
        {
            return WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName);
        }
        #endregion
    }
}
 