-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('dbo.DimCurrency') IS NOT NULL
    DROP TABLE dbo.DimCurrency;
GO

CREATE TABLE dbo.DimCurrency
WITH (DISTRIBUTION = HASH(CurrencyKey), CLUSTERED COLUMNSTORE INDEX)
AS
SELECT
    CurrencyKey
  , CurrencyLabel
  , CurrencyName
  , CurrencyDescription
  , ETLLoadID
  , LoadDate
  , UpdateDate
FROM stage.DimCurrency;
GO

ALTER TABLE dbo.DimCurrency REBUILD;
GO

UPDATE STATISTICS dbo.DimCurrency WITH FULLSCAN;
GO

CREATE STATISTICS S_CurrencyKey ON dbo.DimCurrency (CurrencyKey) WITH FULLSCAN;
GO
-- ================================================================
-- Creating Dim External Table
-- ================================================================
IF OBJECT_ID('dbo.DimDate') IS NOT NULL
    DROP TABLE dbo.DimDate;
GO

CREATE TABLE dbo.DimDate
WITH (DISTRIBUTION = HASH(DateKey), CLUSTERED COLUMNSTORE INDEX)
AS
SELECT
    DateKey
  , FullDateLabel
  , DateDescription
  , CalendarYear
  , CalendarYearLabel
  , CalendarHalfYear
  , CalendarHalfYearLabel
  , CalendarQuarter
  , CalendarQuarterLabel
  , CalendarMonth
  , CalendarMonthLabel
  , CalendarWeek
  , CalendarWeekLabel
  , CalendarDayOfWeek
  , CalendarDayOfWeekLabel
  , FiscalYear
  , FiscalYearLabel
  , FiscalHalfYear
  , FiscalHalfYearLabel
  , FiscalQuarter
  , FiscalQuarterLabel
  , FiscalMonth
  , FiscalMonthLabel
  , IsWorkDay
  , IsHoliday
  , HolidayName
  , EuropeSeason
  , NorthAmericaSeason
  , AsiaSeason
FROM stage.DimDate;
GO

ALTER TABLE dbo.DimDate REBUILD;
GO

UPDATE STATISTICS dbo.DimDate WITH FULLSCAN;
GO

CREATE STATISTICS S_DateKey ON dbo.DimDate (DateKey) WITH FULLSCAN;
CREATE STATISTICS S_CalendarYear ON dbo.DimDate (CalendarYear) WITH FULLSCAN;
CREATE STATISTICS S_CalendarMonth ON dbo.DimDate (CalendarMonth) WITH FULLSCAN;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('dbo.DimGeography') IS NOT NULL
    DROP TABLE dbo.DimGeography;
GO

CREATE TABLE dbo.DimGeography
WITH (DISTRIBUTION = HASH(GeographyKey), CLUSTERED COLUMNSTORE INDEX)
AS
SELECT
    GeographyKey
  , GeographyType
  , ContinentName
  , CityName
  , StateProvinceName
  , RegionCountryName
  , ETLLoadID
  , LoadDate
  , UpdateDate
FROM stage.DimGeography;
GO

ALTER TABLE dbo.DimGeography REBUILD;
GO

UPDATE STATISTICS dbo.DimGeography WITH FULLSCAN;
GO

CREATE STATISTICS S_GeographyKey ON dbo.DimGeography (GeographyKey) WITH FULLSCAN;
CREATE STATISTICS S_StateProvinceName ON dbo.DimGeography (StateProvinceName) WITH FULLSCAN;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('dbo.DimPerformer') IS NOT NULL
    DROP TABLE dbo.DimPerformer;
GO

CREATE TABLE dbo.DimPerformer
WITH (DISTRIBUTION = HASH(PerformerKey), CLUSTERED COLUMNSTORE INDEX)
AS
SELECT
    PerformerKey
  , PerformerName
  , PerformerSkill
FROM stage.DimPerformer;
GO

ALTER TABLE dbo.DimPerformer REBUILD;
GO

UPDATE STATISTICS dbo.DimPerformer WITH FULLSCAN;
GO

CREATE STATISTICS S_PerformerKey ON dbo.DimPerformer (PerformerKey) WITH FULLSCAN;
CREATE STATISTICS S_PerformerName ON dbo.DimPerformer (PerformerName) WITH FULLSCAN;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('dbo.DimConcert') IS NOT NULL
    DROP TABLE dbo.DimConcert;
GO

CREATE TABLE dbo.DimConcert
WITH (DISTRIBUTION = HASH(ConcertKey), CLUSTERED COLUMNSTORE INDEX)
AS
SELECT
    ConcertKey
  , ConcertName
  , ConcertDescription
  , ConcertDate
  , Duration
  , VenueKey
  , PerformerKey
FROM stage.DimConcert;
GO

ALTER TABLE dbo.DimConcert REBUILD;
GO

UPDATE STATISTICS dbo.DimConcert WITH FULLSCAN;
GO

CREATE STATISTICS S_ConcertKey ON dbo.DimConcert (ConcertKey) WITH FULLSCAN;
CREATE STATISTICS S_ConcertName ON dbo.DimConcert (ConcertName) WITH FULLSCAN;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('dbo.DimPromotion') IS NOT NULL
    DROP TABLE dbo.DimPromotion;
GO

CREATE TABLE dbo.DimPromotion
WITH (DISTRIBUTION = HASH(PromotionKey), CLUSTERED COLUMNSTORE INDEX)
AS
SELECT
    PromotionKey
  , PromotionLabel
  , PromotionName
  , PromotionDescription
  , DiscountPercent
  , PromotionType
  , PromotionCategory
  , StartDate
  , EndDate
  , MinQuantity
  , MaxQuantity
  , ETLLoadID
  , LoadDate
  , UpdateDate
FROM stage.DimPromotion;
GO

ALTER TABLE dbo.DimPromotion REBUILD;
GO

UPDATE STATISTICS dbo.DimPromotion WITH FULLSCAN;
GO

CREATE STATISTICS S_PromotionKey ON dbo.DimPromotion (PromotionKey) WITH FULLSCAN;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('dbo.DimSalesTerritory') IS NOT NULL
    DROP TABLE dbo.DimSalesTerritory;
GO

CREATE TABLE dbo.DimSalesTerritory
WITH (DISTRIBUTION = HASH(SalesTerritoryKey), CLUSTERED COLUMNSTORE INDEX)
AS
SELECT
    SalesTerritoryKey
  , GeographyKey
  , SalesTerritoryLabel
  , SalesTerritoryName
  , SalesTerritoryRegion
  , SalesTerritoryCountry
  , SalesTerritoryGroup
  , SalesTerritoryLevel
  , SalesTerritoryManager
  , StartDate
  , EndDate
  , Status
  , ETLLoadID
  , LoadDate
  , UpdateDate
FROM stage.DimSalesTerritory;
GO

ALTER TABLE dbo.DimSalesTerritory REBUILD;
GO

UPDATE STATISTICS dbo.DimSalesTerritory WITH FULLSCAN;
GO

CREATE STATISTICS S_SalesTerritoryKey ON dbo.DimSalesTerritory (SalesTerritoryKey) WITH FULLSCAN;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('dbo.DimVenue') IS NOT NULL
    DROP TABLE dbo.DimVenue;
GO

CREATE TABLE dbo.DimVenue
WITH (DISTRIBUTION = HASH(VenueKey), CLUSTERED COLUMNSTORE INDEX)
AS
SELECT
    VenueKey
  , GeographyKey
  , VenueManager
  , VenueType
  , VenueName
  , VenueDescription
  , Status
  , OpenDate
  , CloseDate
  , EntityKey
  , ZipCode
  , ZipCodeExtension
  , VenuePhone
  , VenueFax
  , CloseReason
  , EmployeeCount
  , SellingAreaSize
  , LastRemodelDate
  , ETLLoadID
  , LoadDate
  , UpdateDate
FROM stage.DimVenue;
GO

ALTER TABLE dbo.DimVenue REBUILD;
GO

UPDATE STATISTICS dbo.DimVenue WITH FULLSCAN;
GO

CREATE STATISTICS S_VenueKey ON dbo.DimVenue (VenueKey) WITH FULLSCAN;
CREATE STATISTICS S_SVenueName ON dbo.DimVenue (VenueName) WITH FULLSCAN;
GO

-- ================================================================
-- Creating Dim External Table
-- ================================================================


IF OBJECT_ID('dbo.FactSales') IS NOT NULL
    DROP TABLE dbo.FactSales;
GO

CREATE TABLE dbo.FactSales
WITH (DISTRIBUTION = HASH(OnlineSalesKey), CLUSTERED COLUMNSTORE INDEX)
AS
SELECT
    OnlineSalesKey
  , DateKey
  , VenueKey
  , ConcertKey
  , PromotionKey
  , CurrencyKey
  , CustomerKey
  , SalesOrderNumber
  , SalesOrderLineNumber
  , SalesQuantity
  , SalesAmount
  , ReturnQuantity
  , ReturnAmount
  , DiscountQuantity
  , DiscountAmount
  , TotalCost
  , UnitCost
  , UnitPrice
  , ETLLoadID
  , LoadDate
  , UpdateDate
FROM stage.FactSales;
GO

ALTER TABLE dbo.FactSales REBUILD;
GO

UPDATE STATISTICS dbo.FactSales WITH FULLSCAN;
GO

CREATE STATISTICS S_OnlineSalesKey ON dbo.FactSales (OnlineSalesKey) WITH FULLSCAN;
CREATE STATISTICS S_DateKey ON dbo.FactSales (DateKey) WITH FULLSCAN;
CREATE STATISTICS S_CustomerKey ON dbo.FactSales (CustomerKey) WITH FULLSCAN;
CREATE STATISTICS S_ConcertKey ON dbo.FactSales (ConcertKey) WITH FULLSCAN;
CREATE STATISTICS S_VenueKey ON dbo.FactSales (VenueKey) WITH FULLSCAN;
GO