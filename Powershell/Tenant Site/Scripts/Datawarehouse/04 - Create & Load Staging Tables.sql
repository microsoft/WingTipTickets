-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('stage.DimCurrency') IS NOT NULL
    DROP TABLE stage.DimCurrency;
GO

CREATE TABLE stage.DimCurrency
WITH (DISTRIBUTION = HASH(CurrencyKey))
AS
SELECT
    CurrencyKey
  , CurrencyLabel
  , CurrencyName
  , CurrencyDescription
  , ETLLoadID
  , LoadDate
  , UpdateDate
FROM asb.DimCurrency;

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('stage.DimDate') IS NOT NULL
    DROP TABLE stage.DimDate;
GO

CREATE TABLE stage.DimDate
WITH (DISTRIBUTION = HASH(DateKey))
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
FROM asb.DimDate;

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('stage.DimGeography') IS NOT NULL
    DROP TABLE stage.DimGeography;
GO

CREATE TABLE stage.DimGeography
WITH (DISTRIBUTION = HASH(GeographyKey))
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
FROM asb.DimGeography;

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('stage.DimPerformer') IS NOT NULL
    DROP TABLE stage.DimPerformer;
GO

CREATE TABLE stage.DimPerformer
WITH (DISTRIBUTION = HASH(PerformerKey))
AS
SELECT
    PerformerKey
  , PerformerName
  , PerformerSkill
FROM asb.DimPerformer;

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('stage.DimConcert') IS NOT NULL
    DROP TABLE stage.DimConcert;
GO

CREATE TABLE stage.DimConcert
WITH (DISTRIBUTION = HASH(ConcertKey))
AS
SELECT
    ConcertKey
  , ConcertName
  , ConcertDescription
  , ConcertDate
  , Duration
  , VenueKey
  , PerformerKey
FROM asb.DimConcert;

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('stage.DimPromotion') IS NOT NULL
    DROP TABLE stage.DimPromotion;
GO

CREATE TABLE stage.DimPromotion
WITH (DISTRIBUTION = HASH(PromotionKey))
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
FROM asb.DimPromotion;

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('stage.DimSalesTerritory') IS NOT NULL
    DROP TABLE stage.DimSalesTerritory;
GO

CREATE TABLE stage.DimSalesTerritory
WITH (DISTRIBUTION = HASH(SalesTerritoryKey))
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
FROM asb.DimSalesTerritory;

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('stage.DimVenue') IS NOT NULL
    DROP TABLE stage.DimVenue;
GO

CREATE TABLE stage.DimVenue
WITH (DISTRIBUTION = HASH(VenueKey))
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
FROM asb.DimVenue;

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('stage.FactSales') IS NOT NULL
    DROP TABLE stage.FactSales;
GO

CREATE TABLE stage.FactSales
WITH (DISTRIBUTION = HASH(OnlineSalesKey))
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
FROM asb.FactSales;