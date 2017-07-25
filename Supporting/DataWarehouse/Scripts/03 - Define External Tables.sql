-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimCurrency') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimCurrency;
GO

CREATE EXTERNAL TABLE asb.DimCurrency
(
    CurrencyKey int NULL
  , CurrencyLabel varchar(3) NULL
  , CurrencyName varchar(3) NULL
  , CurrencyDescription varchar(18) NULL
  , ETLLoadID int NULL
  , LoadDate datetime NULL
  , UpdateDate datetime NULL
)
WITH (
    LOCATION='DimCurrency.txt.gz'
  , DATA_SOURCE = wttdatacampdwwestus
  , FILE_FORMAT = gzip_tab_delimited_text_file
);

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimDate') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimDate;
GO

CREATE EXTERNAL TABLE asb.DimDate
(
    DateKey datetime NULL
  , FullDateLabel varchar(10) NULL
  , DateDescription varchar(10) NULL
  , CalendarYear int NULL
  , CalendarYearLabel varchar(9) NULL
  , CalendarHalfYear int NULL
  , CalendarHalfYearLabel varchar(2) NULL
  , CalendarQuarter int NULL
  , CalendarQuarterLabel varchar(2) NULL
  , CalendarMonth int NULL
  , CalendarMonthLabel varchar(9) NULL
  , CalendarWeek int NULL
  , CalendarWeekLabel varchar(7) NULL
  , CalendarDayOfWeek int NULL
  , CalendarDayOfWeekLabel varchar(9) NULL
  , FiscalYear int NULL
  , FiscalYearLabel varchar(15) NULL
  , FiscalHalfYear int NULL
  , FiscalHalfYearLabel varchar(2) NULL
  , FiscalQuarter int NULL
  , FiscalQuarterLabel varchar(2) NULL
  , FiscalMonth int NULL
  , FiscalMonthLabel varchar(8) NULL
  , IsWorkDay varchar(7) NULL
  , IsHoliday int NULL
  , HolidayName varchar(4) NULL
  , EuropeSeason varchar(15) NULL
  , NorthAmericaSeason varchar(23) NULL
  , AsiaSeason varchar(21) NULL
)
WITH (
    LOCATION='DimDate.txt.gz'
  , DATA_SOURCE = wttdatacampdwwestus
  , FILE_FORMAT = gzip_tab_delimited_text_file
);

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimGeography') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimGeography;
GO

CREATE EXTERNAL TABLE asb.DimGeography
(
    GeographyKey int NULL
  , GeographyType varchar(14) NULL
  , ContinentName varchar(13) NULL
  , CityName varchar(21) NULL
  , StateProvinceName varchar(35) NULL
  , RegionCountryName varchar(15) NULL
  , ETLLoadID int NULL
  , LoadDate datetime NULL
  , UpdateDate datetime NULL
)
WITH (
    LOCATION='DimGeography.txt.gz'
  , DATA_SOURCE = wttdatacampdwwestus
  , FILE_FORMAT = gzip_tab_delimited_text_file
);

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimPerformer') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimPerformer;
GO

CREATE EXTERNAL TABLE asb.DimPerformer
(
    PerformerKey int NULL
  , PerformerName varchar(100) NULL
  , PerformerSkill varchar(100) NULL
)
WITH (
    LOCATION='DimPerformer.txt.gz'
  , DATA_SOURCE = wttdatacampdwwestus
  , FILE_FORMAT = gzip_tab_delimited_text_file
);

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimConcert') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimConcert;
GO

CREATE EXTERNAL TABLE asb.DimConcert
(
    ConcertKey int NULL
  , ConcertName varchar(50) NULL
  , ConcertDescription varchar(100) NULL
  , ConcertDate datetime NULL
  , Duration int NULL
  , VenueKey int NULL
  , PerformerKey int NULL
)
WITH (
    LOCATION='DimConcert.txt.gz'
  , DATA_SOURCE = wttdatacampdwwestus
  , FILE_FORMAT = gzip_tab_delimited_text_file
);

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimPromotion') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimPromotion;
GO

CREATE EXTERNAL TABLE asb.DimPromotion
(
    PromotionKey int NULL
  , PromotionLabel varchar(3) NULL
  , PromotionName varchar(38) NULL
  , PromotionDescription varchar(38) NULL
  , DiscountPercent float NULL
  , PromotionType varchar(17) NULL
  , PromotionCategory varchar(11) NULL
  , StartDate datetime NULL
  , EndDate datetime NULL
  , MinQuantity int NULL
  , MaxQuantity int NULL
  , ETLLoadID int NULL
  , LoadDate datetime NULL
  , UpdateDate datetime NULL
)
WITH (
    LOCATION='DimPromotion.txt.gz'
  , DATA_SOURCE = wttdatacampdwwestus
  , FILE_FORMAT = gzip_tab_delimited_text_file
);

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimSalesTerritory') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimSalesTerritory;
GO

CREATE EXTERNAL TABLE asb.DimSalesTerritory
(
    SalesTerritoryKey int NULL
  , GeographyKey int NULL
  , SalesTerritoryLabel varchar(9) NULL
  , SalesTerritoryName varchar(19) NULL
  , SalesTerritoryRegion varchar(27) NULL
  , SalesTerritoryCountry varchar(15) NULL
  , SalesTerritoryGroup varchar(13) NULL
  , SalesTerritoryLevel varchar(1) NULL
  , SalesTerritoryManager int NULL
  , StartDate datetime NULL
  , EndDate datetime NULL
  , Status varchar(7) NULL
  , ETLLoadID int NULL
  , LoadDate datetime NULL
  , UpdateDate datetime NULL
)
WITH (
    LOCATION='DimSalesTerritory.txt.gz'
  , DATA_SOURCE = wttdatacampdwwestus
  , FILE_FORMAT = gzip_tab_delimited_text_file
);

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimVenue') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimVenue;
GO

CREATE EXTERNAL TABLE asb.DimVenue
(
    VenueKey int NULL
  , GeographyKey int NULL
  , VenueManager int NULL
  , VenueType varchar(15) NULL
  , VenueName varchar(34) NULL
  , VenueDescription varchar(33) NULL
  , Status varchar(3) NULL
  , OpenDate datetime NULL
  , CloseDate datetime NULL
  , EntityKey int NULL
  , ZipCode varchar(7) NULL
  , ZipCodeExtension varchar(7) NULL
  , VenuePhone varchar(15) NULL
  , VenueFax varchar(14) NULL
  , CloseReason varchar(10) NULL
  , EmployeeCount int NULL
  , SellingAreaSize float NULL
  , LastRemodelDate datetime NULL
  , ETLLoadID int NULL
  , LoadDate datetime NULL
  , UpdateDate datetime NULL
)
WITH (
    LOCATION='DimVenue.txt.gz'
  , DATA_SOURCE = wttdatacampdwwestus
  , FILE_FORMAT = gzip_tab_delimited_text_file
);

-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.FactSales') IS NOT NULL
    DROP EXTERNAL TABLE asb.FactSales;
GO

CREATE EXTERNAL TABLE asb.FactSales
(
    OnlineSalesKey bigint NULL
  , DateKey datetime NULL
  , VenueKey int NULL
  , ConcertKey int NULL
  , PromotionKey int NULL
  , CurrencyKey int NULL
  , CustomerKey int NULL
  , SalesOrderNumber varchar(18) NULL
  , SalesOrderLineNumber int NULL
  , SalesQuantity int NULL
  , SalesAmount money NULL
  , ReturnQuantity int NULL
  , ReturnAmount money NULL
  , DiscountQuantity int NULL
  , DiscountAmount money NULL
  , TotalCost money NULL
  , UnitCost money NULL
  , UnitPrice money NULL
  , ETLLoadID int NULL
  , LoadDate datetime NULL
  , UpdateDate datetime NULL
)
WITH (
    LOCATION='FactSales.txt.gz'
  , DATA_SOURCE = wttdatacampdwwestus
  , FILE_FORMAT = gzip_tab_delimited_text_file
);