SELECT
SalesOrderNumber as SalesOrderNumber,
CustomerKey as CustomerKey,
COUNT(OnlineSalesKey) as OnlineSalesKey,
AVG(SalesQuantity) as SalesQuantity,
AVG(SalesAmount) as SalesAmount,
AVG(DiscountAmount) As DiscountAmount,
AVG(DiscountQuantity) As DiscountQuantity,
AVG(UnitCost) as UnitCost,
AVG(UnitPrice) as UnitPrice,
AVG((SalesAmount-DiscountAmount)) As SalesAmountDifference,
AVG((SalesQuantity - DiscountQuantity)) as SalesQuantityDifference
FROM
FactSales
GROUP BY
SalesOrderNumber,
CustomerKey
HAVING
AVG(SalesQuantity) > 2