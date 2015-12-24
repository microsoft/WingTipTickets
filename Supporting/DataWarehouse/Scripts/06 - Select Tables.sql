-- ================================================================
-- Select from External Tables
-- ================================================================

SELECT * FROM asb.DimConcert
SELECT * FROM asb.DimCurrency
SELECT * FROM asb.DimCustomer
SELECT * FROM asb.DimDate
SELECT * FROM asb.DimGeography
SELECT * FROM asb.DimPerformer
SELECT * FROM asb.DimPromotion
SELECT * FROM asb.DimSalesTerritory
SELECT * FROM asb.DimVenue
SELECT * FROM asb.FactSales

-- ================================================================
-- Select from Staging Tables
-- ================================================================

SELECT * FROM stage.DimConcert
SELECT * FROM stage.DimCurrency
SELECT * FROM stage.DimCustomer
SELECT * FROM stage.DimDate
SELECT * FROM stage.DimGeography
SELECT * FROM stage.DimPerformer
SELECT * FROM stage.DimPromotion
SELECT * FROM stage.DimSalesTerritory
SELECT * FROM stage.DimVenue
SELECT * FROM stage.FactSales

-- ================================================================
-- Select from Query Tables
-- ================================================================

SELECT * FROM dbo.DimConcert
SELECT * FROM dbo.DimCurrency
SELECT * FROM dbo.DimCustomer
SELECT * FROM dbo.DimDate
SELECT * FROM dbo.DimGeography
SELECT * FROM dbo.DimPerformer
SELECT * FROM dbo.DimPromotion
SELECT * FROM dbo.DimSalesTerritory
SELECT * FROM dbo.DimVenue
SELECT * FROM dbo.FactSales