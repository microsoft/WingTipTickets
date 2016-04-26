using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using Tenant.Mvc.Core.Interfaces.Recommendations;
using Tenant.Mvc.Core.Models;
using WingTipTickets;

namespace Tenant.Mvc.Core.Repositories.Recommendations
{
    public class ProductsRepository : IProductsRepository
    {
        #region - Public Methods -

        public IEnumerable<Product> GetProducts()
        {
            var products = new List<Product>();
            using (var conn = WingtipTicketApp.CreateRecommendationSqlConnection())
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT top 20 * FROM Products";
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            products.Add(
                                         new Product
                                         {
                                             Id = (Int64)reader["Id"],
                                             Name = reader["Name"].ToString(),
                                             Description = reader["Description"].ToString(),
                                             Title1 = reader["Title1"].ToString(),
                                             Title2 = reader["Title2"].ToString(),
                                             TitlesCount = (int)reader["TitlesCount"],
                                             Price = (int)reader["Price"]
                                         });
                        }
                    }
                }
            }

            return products;
        }

        public int GetSongPlayCount(Int64 productId, Int64 customerId)
        {
            var playCount = 0;
            using (var conn = WingtipTicketApp.CreateRecommendationSqlConnection())
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT Sum(CU.IsPlayed) as PlayCount FROM CustomerUsage CU WHERE Cu.CustomerId = @CustomerId AND Cu.ProductId = @ProductId";
                    cmd.Parameters.Add(new SqlParameter("CustomerId", SqlDbType.BigInt) { Value = customerId });
                    cmd.Parameters.Add(new SqlParameter("ProductId", SqlDbType.BigInt) { Value = productId });
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            if (!DBNull.Value.Equals(reader["PlayCount"]))
                            {
                                playCount = (int) (reader["PlayCount"]);
                            }
                            else
                            {
                                playCount = 0;
                            }
                        }
                    }
                }
            }

            return playCount;
        }

        public Product GetProduct(Int64 id)
        {
            using (var conn = WingtipTicketApp.CreateRecommendationSqlConnection())
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT * FROM Products WHERE Id = @Id";
                    cmd.Parameters.Add(new SqlParameter("Id", SqlDbType.BigInt) { Value = id });
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return null;
                        }

                        return new Product
                        {
                            Id = (Int64)reader["Id"],
                            Name = reader["Name"].ToString(),
                            Description = reader["Description"].ToString(),
                            Title1 = reader["Title1"].ToString(),
                            Title2 = reader["Title2"].ToString(),
                            TitlesCount = (int)(reader["TitlesCount"] ?? 0),
                            Price = (int)reader["Price"]
                        };
                    }
                }
            }
        }

        public IEnumerable<Product> GetRelatedProducts(Int64 productId)
        {
            var products = new List<Product>();
            using (var conn = WingtipTicketApp.CreateRecommendationSqlConnection())
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT DISTINCT Top 10 Related.ProductId, Products.Name, Products.Price, Products.TitlesCount FROM SimilarProducts AS Related INNER JOIN Products ON Related.SimilarProductId = Products.Id WHERE Related.ProductId = @ProductId";
                    cmd.Parameters.Add(new SqlParameter("ProductId", SqlDbType.BigInt) { Value = productId });
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            products.Add(
                                         new Product
                                         {
                                             Id = (Int64)reader["ProductId"],
                                             Name = reader["Name"].ToString(),
                                             Price = (int)reader["Price"],
                                             TitlesCount = (int)reader["TitlesCount"]
                                         });
                        }
                    }
                }
            }

            return products;
        }

        public IEnumerable<Product> GetRecommendedProducts(Int64 customerId)
        {
            var products = new List<Product>();
            using (var conn = WingtipTicketApp.CreateRecommendationSqlConnection())
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT DISTINCT Top 10 Related.RecommendedProductId, Products.Name, Products.Price, Products.TitlesCount FROM PersonalizedRecommendations AS Related INNER JOIN Products ON Related.RecommendedProductId = Products.Id WHERE Related.CustomerId = @CustomerId";
                    cmd.Parameters.Add(new SqlParameter("CustomerId", SqlDbType.BigInt) { Value = customerId });
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            products.Add(
                                         new Product
                                         {
                                             Id = (Int64)reader["RecommendedProductId"],
                                             Name = reader["Name"].ToString(),
                                             Price = (int)reader["Price"],
                                             TitlesCount = (int)reader["TitlesCount"]
                                         });
                        }
                    }
                }
            }

            return products;
        }

        #endregion
    }
}