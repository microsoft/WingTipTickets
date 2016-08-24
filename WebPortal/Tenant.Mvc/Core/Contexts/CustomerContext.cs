using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using Microsoft.Rest.TransientFaultHandling;
using Tenant.Mvc.Core.Models;
using WingTipTickets;

namespace Tenant.Mvc.Core.Contexts
{
    public partial class DatabaseContext
    {
        public class CustomerContext
        {
            #region - Get Methods -

            public List<CustomerModel> GetUsers()
            {
                var customers = new List<CustomerModel>();
                var query = String.Format(@"Select CustomerId, FirstName, LastName, Email, ContactNbr from Customers Where Email <> 'admin@admin.com'");

                using (var cmd = new SqlCommand(query, WingtipTicketApp.CreateTenantConnectionDatabase1()))
                {
                    using (var sdAdapter = new SqlDataAdapter(cmd))
                    {
                        var dsUser = new DataSet();
                        sdAdapter.Fill(dsUser);

                        if (dsUser.Tables.Count > 0)
                        {
                            foreach (DataRow row in dsUser.Tables[0].Rows)
                            {
                                customers.Add(new CustomerModel()
                                {
                                    CustomerId = Convert.ToInt32(row["CustomerId"]),
                                    FirstName = row["FirstName"].ToString(),
                                    LastName = row["LastName"].ToString(),
                                    Email = row["Email"].ToString(),
                                    PhoneNumber = row["ContactNbr"].ToString()
                                });
                            }
                        }
                    }
                }

                return customers;
            }

            #endregion

            #region - Save Methods -

            public bool CreateUser(string firstName, string lastName, string email, string phonenumber, string password)
            {
                var database1Result = CreateUserOnDatabase(firstName, lastName, email, phonenumber, password, true, WingtipTicketApp.CreateTenantConnectionDatabase1());
                var database2Result = CreateUserOnDatabase(firstName, lastName, email, phonenumber, password, false, WingtipTicketApp.CreateTenantConnectionDatabase2());

                return database1Result;
            }

            private bool CreateUserOnDatabase(string firstName, string lastName, string email, string phonenumber, string password, bool setSession, SqlConnection connection)
            {
                var query = String.Format(@"Insert into Customers (FirstName, LastName, Email, ContactNbr, Password)
                                        Values ('{0}', '{1}', '{2}', '{3}', '{4}');
                                        Select @@Identity as 'Identity'", firstName, lastName, email, phonenumber, password);

                using (var cmd = new SqlCommand(query, connection))
                {
                    using (var sdAdapter = new SqlDataAdapter(cmd))
                    {
                        var dsUser = new DataSet();
                        sdAdapter.Fill(dsUser);

                        if (dsUser.Tables.Count > 0 && dsUser.Tables[0].Rows.Count > 0)
                        {
                            var newUser = new CustomerModel
                            {
                                FirstName = firstName,
                                LastName = lastName,
                                Email = email,
                                PhoneNumber = phonenumber,
                                CustomerId = Convert.ToInt32(dsUser.Tables[0].Rows[0]["Identity"])
                            };

                            if (setSession)
                            {
                                Startup.SessionUsers.Add(newUser);
                                HttpContext.Current.Session["SessionUser"] = newUser;
                                LogAction("Added new user - " + firstName + " " + lastName);
                            }

                            return true;
                        }
                    }
                }

                return false;
            }

            #endregion

            #region - Helper Methods -

            public bool UserExists(string email)
            {
                using (var conn = WingtipTicketApp.CreateTenantConnectionDatabase1())
                {
                    using (var dbReader = new SqlCommand(String.Format(@"Select CustomerId From Customers Where Email={0}", email), conn).ExecuteReader())
                    {
                        return dbReader.HasRows;
                    }
                }
            }

            public bool Login(string email, string password)
            {
                var query = String.Format(@"Select FirstName, LastName, CustomerId from Customers Where Email='{0}' and Password='{1}'", email, password);

                using (var cmd = new SqlCommand(query, WingtipTicketApp.CreateTenantConnectionDatabase1()))
                {
                    using (var sdAdapter = new SqlDataAdapter(cmd))
                    {
                        var dsUser = new DataSet();
                        sdAdapter.Fill(dsUser);

                        if (dsUser.Tables.Count > 0 && dsUser.Tables[0].Rows.Count > 0)
                        {
                            var newUser = new CustomerModel
                            {
                                FirstName = dsUser.Tables[0].Rows[0]["FirstName"].ToString(),
                                LastName = dsUser.Tables[0].Rows[0]["LastName"].ToString(),
                                Email = email,
                                CustomerId = Convert.ToInt32(dsUser.Tables[0].Rows[0]["CustomerId"])
                            };

                            HttpContext.Current.Session["SessionUser"] = newUser;

                            if (Startup.SessionUsers.Any(a => a.Email != null && a.Email.ToUpper() == email.ToUpper()))
                            {
                                Startup.SessionUsers.Remove(Startup.SessionUsers.First(a => a.Email.ToUpper() == email.ToUpper()));
                            }

                            Startup.SessionUsers.Add(newUser);

                            return true;
                        }
                    }
                }

                return false;
            }

            #endregion
        }
    }
}
 