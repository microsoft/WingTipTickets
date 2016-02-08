-- ================================================================
-- Dropping Dim Stage Table
-- ================================================================

IF OBJECT_ID('stage.DimCurrency') IS NOT NULL
	DROP TABLE stage.DimCurrency;
GO

-- ================================================================
-- Dropping Dim Stage Table
-- ================================================================

IF OBJECT_ID('stage.DimDate') IS NOT NULL
	DROP TABLE stage.DimDate;
GO

-- ================================================================
-- Dropping Dim Stage Table
-- ================================================================

IF OBJECT_ID('stage.DimGeography') IS NOT NULL
	DROP TABLE stage.DimGeography;
GO

-- ================================================================
-- Dropping Dim Stage Table
-- ================================================================

IF OBJECT_ID('stage.DimPerformer') IS NOT NULL
	DROP TABLE stage.DimPerformer;
GO

-- ================================================================
-- Dropping Dim Stage Table
-- ================================================================

IF OBJECT_ID('stage.DimConcert') IS NOT NULL
	DROP TABLE stage.DimConcert;
GO

-- ================================================================
-- Dropping Dim Stage Table
-- ================================================================

IF OBJECT_ID('stage.DimPromotion') IS NOT NULL
	DROP TABLE stage.DimPromotion;
GO

-- ================================================================
-- Dropping Dim Stage Table
-- ================================================================

IF OBJECT_ID('stage.DimSalesTerritory') IS NOT NULL
	DROP TABLE stage.DimSalesTerritory;
GO

-- ================================================================
-- Dropping Dim Stage Table
-- ================================================================

IF OBJECT_ID('stage.DimVenue') IS NOT NULL
	DROP TABLE stage.DimVenue;
GO

-- ================================================================
-- Dropping Dim Stage Table
-- ================================================================

IF OBJECT_ID('stage.FactSales') IS NOT NULL
	DROP TABLE stage.FactSales;
GO
-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimCurrency') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimCurrency;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimDate') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimDate;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimGeography') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimGeography;
GO


-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimPerformer') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimPerformer;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimConcert') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimConcert;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimPromotion') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimPromotion;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimSalesTerritory') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimSalesTerritory;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimVenue') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimVenue;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.FactSales') IS NOT NULL
    DROP EXTERNAL TABLE asb.FactSales;
GO