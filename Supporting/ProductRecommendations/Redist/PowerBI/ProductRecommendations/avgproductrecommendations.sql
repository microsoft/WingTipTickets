Select Avg(Count) from (
select count(UserName) as Count, UserName from (
Select UserId, UserName, ProductId, ProductName, RecommendedProduct, RankSel from (
select U.UserId as UserId, U.Name as UserName, PC.ProductId as ProductId, PC.Name as ProductName, R.Product2 as RecommendedProduct, RANK() OVER (PARTITION BY U.Name, PC.Name ORDER BY U.Name, PC.Name, R.Product2 DESC) AS RankSel
From ProductsCatalog PC, ProductsUsage PU, Users U, Recommendations R
Where PC.productid = PU.productid
AND PU.UserId = U.UserID
AND PC.Name = R.Product1) A ) B
Group by UserName
) C
