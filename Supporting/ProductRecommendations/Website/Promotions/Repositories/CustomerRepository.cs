using Microsoft.AspNet.Identity;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Web;

namespace Promotions.Repositories
{
    public class CustomerRepository : ICustomerRepository, IUserStore<Customer>
    {
        Func<SqlConnection> _getConnection;

        public CustomerRepository(Func<SqlConnection> getConnection)
        {
            _getConnection = getConnection;
        }

        public Customer GetCustomerByName(string customer)
        {
            using(var conn = _getConnection())
            {
                conn.Open();
                using(var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT * FROM Customers WHERE Name = @Name";
                    cmd.Parameters.Add(new SqlParameter("Name", System.Data.SqlDbType.NVarChar) { Value = customer });
                    using(var reader = cmd.ExecuteReader())
                    {
                        if(!reader.Read())
                        {
                            return null;
                        }

                        return new Customer
                        {
                            Id = (Int64)reader["Id"],
                            UserName = reader["Name"].ToString(),
                            Region = reader["Region"].ToString()
                        };
                    }
                }
            }
        }

        public Customer GetCustomerById(Int64 id)
        {
            using (var conn = _getConnection())
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT * FROM Customers WHERE Id = @Id";
                    cmd.Parameters.Add(new SqlParameter("Id", System.Data.SqlDbType.BigInt) { Value = id });
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return null;
                        }

                        return new Customer
                        {
                            Id = (Int64)reader["Id"],
                            UserName = reader["Name"].ToString(),
                            Region = reader["Region"].ToString()
                        };
                    }
                }
            }
        }


        public System.Threading.Tasks.Task CreateAsync(Customer user)
        {
            throw new NotImplementedException();
        }

        public System.Threading.Tasks.Task DeleteAsync(Customer user)
        {
            throw new NotImplementedException();
        }

        public System.Threading.Tasks.Task<Customer> FindByIdAsync(string userId)
        {
            return Task.Factory.StartNew(() => GetCustomerById(Int64.Parse(userId)));
        }

        public System.Threading.Tasks.Task<Customer> FindByNameAsync(string userName)
        {
            return Task.Factory.StartNew(() => GetCustomerByName(userName));
        }

        public System.Threading.Tasks.Task UpdateAsync(Customer user)
        {
            throw new NotImplementedException();
        }

        public void Dispose()
        {
        }
    }

    public class Customer : IUser
    {
        public Int64 Id;

        public string UserName;

        string IUser.Id { get { return this.Id.ToString(); } }

        string IUser.UserName { get { return this.UserName; } set { this.UserName = value; } }

        public string Region { get; set; }
    }
}