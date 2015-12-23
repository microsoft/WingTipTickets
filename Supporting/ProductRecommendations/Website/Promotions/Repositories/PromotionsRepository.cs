using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Promotions.Repositories
{
    public class PromotionsRepository : Promotions.Repositories.IPromotionsRepository
    {
        Func<SqlConnection> _getConnection;

        public PromotionsRepository(Func<SqlConnection> getConnection)
        {
            _getConnection = getConnection;
        }

        public Promotion GetPromotion(Int64 customerId, Int64 productId)
        {
            using (var conn = _getConnection())
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT DISTINCT CustomerId, ProductId, NewPrice, Promotion FROM Promotions WHERE CustomerId = @CustomerId AND ProductId = @ProductId";
                    cmd.Parameters.Add(new SqlParameter("CustomerId", System.Data.SqlDbType.BigInt) { Value = customerId });
                    cmd.Parameters.Add(new SqlParameter("ProductId", System.Data.SqlDbType.BigInt) { Value = productId });
                    using (var reader = cmd.ExecuteReader())
                    {
                        if(!reader.Read())
                        {
                            return null;
                        }

                        return new Promotion
                        {
                            CustomerId = (Int64)reader["CustomerId"],
                            ProductId = (Int64)reader["ProductId"],
                            PromotionDiscount = reader["Promotion"].ToString(),
                            NewPrice = (int)reader["NewPrice"]
                        };
                    }
                }
            }
        }

        public IEnumerable<Promotion> GetPromotions(Int64 customerId)
        {
            var promotions = new List<Promotion>();
            using (var conn = _getConnection())
            {
                conn.Open();
                using (var cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT DISTINCT CustomerId, ProductId, NewPrice, Promotion FROM Promotions WHERE CustomerId = @CustomerId";
                    cmd.Parameters.Add(new SqlParameter("CustomerId", System.Data.SqlDbType.BigInt) { Value = customerId });
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            promotions.Add(
                                new Promotion
                                {
                                    CustomerId = (Int64)reader["CustomerId"],
                                    ProductId = (Int64)reader["ProductId"],
                                    PromotionDiscount = reader["Promotion"].ToString(),
                                    NewPrice = (int)reader["NewPrice"]
                                });
                        }
                    }
                }
            }

            return promotions;
        }

    }
}