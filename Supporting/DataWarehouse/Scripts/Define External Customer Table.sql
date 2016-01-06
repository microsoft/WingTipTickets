-- ================================================================
-- Creating Dim External Table
-- ================================================================

IF OBJECT_ID('asb.DimCustomer') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimCustomer;
GO

CREATE EXTERNAL TABLE asb.DimCustomer
(
    CustomerKey int NULL
  , GeographyKey int NULL
  , CustomerLabel varchar(5) NULL
  , Title varchar(4) NULL
  , FirstName varchar(11) NULL
  , MiddleName varchar(10) NULL
  , LastName varchar(16) NULL
  , NameStyle bit NULL
  , BirthDate date NULL
  , MaritalStatus char(1) NULL
  , Suffix varchar(3) NULL
  , Gender varchar(1) NULL
  , EmailAddress varchar(33) NULL
  , YearlyIncome money NULL
  , TotalChildren tinyint NULL
  , NumberChildrenAtHome tinyint NULL
  , Education varchar(19) NULL
  , Occupation varchar(14) NULL
  , HouseOwnerFlag char(1) NULL
  , NumberCarsOwned tinyint NULL
  , AddressLine1 varchar(33) NULL
  , AddressLine2 varchar(21) NULL
  , Phone varchar(19) NULL
  , DateFirstPurchase date NULL
  , CustomerType varchar(7) NULL
  , CompanyName varchar(23) NULL
  , ETLLoadID int NULL
  , LoadDate datetime NULL
  , UpdateDate datetime NULL
)
WITH (
    LOCATION='DimCustomer.txt.gz'
  , DATA_SOURCE = wttdatacampdwwestus
  , FILE_FORMAT = gzip_tab_delimited_text_file
);
