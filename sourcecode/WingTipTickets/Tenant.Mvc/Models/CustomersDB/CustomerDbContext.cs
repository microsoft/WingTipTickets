using System;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using Tenant.Mvc.Models.VenuesDB;
using WingTipTickets;

namespace Tenant.Mvc.Models.CustomersDB
{
    public class CustomerDbContext
    {
        public bool UserExists(string email)
        {
            try
            {
                using (var conn = new SqlConnection(WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName)))
                using (SqlDataReader dbReader = new SqlCommand(String.Format(@"Select CustomerId From Customers Where Email={0}", email), conn).ExecuteReader())
                    { return dbReader.HasRows; }
            }
            catch { }
            return false;
        }
        public bool CreateUser(string firstName, string lastName, string email, string password)
        {
            string query = String.Format(@"Insert into Customers (FirstName, LastName, Email, Password)
                                            Values ('{0}', '{1}', '{2}', '{3}');
                                            Select @@Identity as 'Identity'", firstName, lastName, email, password);
            try
            {
                using (var cmd = new SqlCommand(query,  new SqlConnection(WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName))))
                using (var sdAdapter = new SqlDataAdapter(cmd))
                {
                    DataSet dsUser = new DataSet();
                    sdAdapter.Fill(dsUser);
                    if (dsUser.Tables.Count > 0 && dsUser.Tables[0].Rows.Count > 0)
                    {
                        Customer newUser = new Customer { FirstName = firstName, LastName = lastName, Email = email, CustomerId = Convert.ToInt32(dsUser.Tables[0].Rows[0]["Identity"])};
                        HttpContext.Current.Session["SessionUser"] = newUser;
                        Startup.SessionUsers.Add(newUser);
                    }
                }
                VenuesDbContext.LogAction("Added new user - " + firstName + " " + lastName);
                return true;
            }
            catch { return false; }
        }
        public bool Login(string email, string password)
        {
            string query = String.Format(@"Select FirstName, LastName, CustomerId from Customers Where Email='{0}' and Password='{1}'", email, password);
            try
            {
                using (var cmd = new SqlCommand(query, new SqlConnection(WingtipTicketApp.ConstructConnection(WingtipTicketApp.Config.PrimaryDatabaseServer, WingtipTicketApp.Config.TenantDbName))))
                using (var sdAdapter = new SqlDataAdapter(cmd))
                {
                    DataSet dsUser = new DataSet();
                    sdAdapter.Fill(dsUser);
                    if (dsUser.Tables.Count > 0 && dsUser.Tables[0].Rows.Count > 0)
                    {
                        Customer newUser = new Customer { FirstName = dsUser.Tables[0].Rows[0]["FirstName"].ToString(), LastName = dsUser.Tables[0].Rows[0]["LastName"].ToString(), Email = email, CustomerId = Convert.ToInt32(dsUser.Tables[0].Rows[0]["CustomerId"]) };
                        HttpContext.Current.Session["SessionUser"] = newUser;
                        if (Startup.SessionUsers.Any(a => a.Email != null && a.Email.ToUpper() == email.ToUpper()))
                            Startup.SessionUsers.Remove(Startup.SessionUsers.First(a => a.Email.ToUpper() == email.ToUpper()));
                        Startup.SessionUsers.Add(newUser);
                    }
                }
                return true;
            }
            catch { return false; }
        }
    }
}
 