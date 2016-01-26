-- ================================================================
-- Dropping Dim Stage Table
-- ================================================================

IF OBJECT_ID('stage.DimCurrency') IS NOT NULL
	DROP TABLE stage.DimCurrency;
GO

-- ================================================================
-- Dropping Dim Stage Table
-- ================================================================

IF OBJECT_ID('stage.DimCustomer') IS NOT NULL
	DROP TABLE stage.DimCustomer;
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