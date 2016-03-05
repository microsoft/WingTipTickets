using System;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using Microsoft.AspNet.Identity;
using Tenant.Mvc.Core.Interfaces.Recommendations;
using Tenant.Mvc.Core.Models;
using WingTipTickets;

namespace Tenant.Mvc.Core.Repositories.Recommendations
{
    public class CustomerRepository : ICustomerRepository, IUserStore<CustomerRec>
    {
        #region - Public Methods -

        public CustomerRec GetCustomerByName(string customer)
        {
            using(var conn = WingtipTicketApp.CreateRecommendationSqlConnection())
            {
                conn.Open();
                using(var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT * FROM Customers WHERE Name = @Name";
                    cmd.Parameters.Add(new SqlParameter("Name", SqlDbType.NVarChar) { Value = customer });
                    using(var reader = cmd.ExecuteReader())
                    {
                        if(!reader.Read())
                        {
                            return null;
                        }

                        return new CustomerRec
                        {
                            CustomerId = (Int64)reader["Id"],
                            UserName = reader["Name"].ToString(),
                            Region = reader["Region"].ToString()
                        };
                    }
                }
            }
        }

        public CustomerRec GetCustomerById(Int64 id)
        {
            using (var conn = WingtipTicketApp.CreateRecommendationSqlConnection())
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT * FROM Customers WHERE Id = @Id";
                    cmd.Parameters.Add(new SqlParameter("Id", SqlDbType.BigInt) { Value = id });
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return null;
                        }

                        return new CustomerRec
                        {
                            CustomerId = (Int64)reader["Id"],
                            UserName = reader["Name"].ToString(),
                            Region = reader["Region"].ToString()
                        };
                    }
                }
            }
        }

        public Task<CustomerRec> FindByIdAsync(string userId)
        {
            return Task.Factory.StartNew(() => GetCustomerById(Int64.Parse(userId)));
        }

        public Task<CustomerRec> FindByNameAsync(string userName)
        {
            return Task.Factory.StartNew(() => GetCustomerByName(userName));
        }

        #endregion

        #region - Not Implemented -

        public void Dispose()
        {

        }

        public Task CreateAsync(CustomerRec user)
        {
            throw new NotImplementedException();
        }

        public Task DeleteAsync(CustomerRec user)
        {
            throw new NotImplementedException();
        }

        public Task UpdateAsync(CustomerRec user)
        {
            throw new NotImplementedException();
        }

        #endregion
    }
}