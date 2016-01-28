-- ================================================================
-- Drop West US credentials
-- ================================================================
DROP EXTERNAL DATA SOURCE wttdatacampdwwestus
DROP DATABASE SCOPED CREDENTIAL ASB_WTTCredential

-- ================================================================
-- Create East US credentials
-- ================================================================
-- ================================================================
-- Creating master key
-- ================================================================

IF (NOT EXISTS(SELECT * FROM sys.symmetric_keys WHERE name LIKE '%MS_DatabaseMasterKey%'))
BEGIN
	CREATE MASTER KEY;
END

-- ================================================================
-- Create a database scoped credential
-- ================================================================

IF (NOT EXISTS(SELECT * FROM sys.database_credentials WHERE Name = 'ASB_WTTCredential'))
BEGIN
	CREATE DATABASE SCOPED CREDENTIAL ASB_WTTCredential 
	WITH IDENTITY = 'wttdatacampdweastus', SECRET = 's6bvZXAJ8nT7wLXh88CVDGKKRVyt05ksyC9dz20QGcMxbsjMx9F07KLfVRU1xVXFpkR2cEV0svkrWt2sALxuvw=='
END;

-- ================================================================
-- Creating external data source (Azure Blob Storage)
-- ================================================================

IF (NOT EXISTS(SELECT * FROM sys.external_data_sources WHERE Name = 'wttdatacampdweastus'))
BEGIN
	CREATE EXTERNAL DATA SOURCE wttdatacampdweastus
	WITH (
		TYPE = HADOOP,
		LOCATION ='wasbs://wttdatacampdw@wttdatacampdweastus.blob.core.windows.net',
		CREDENTIAL = ASB_WTTCredential
	)
END;


-- ================================================================
-- Creating DimCustomer External Table
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
  , DATA_SOURCE = wttdatacampdweastus
  , FILE_FORMAT = gzip_tab_delimited_text_file
);
-- ================================================================
-- Creating DimCustomer External Table Completed
-- ================================================================
-- ================================================================
-- Creating Dim Stage Customer Table
-- ================================================================

IF OBJECT_ID('stage.DimCustomer') IS NOT NULL
    DROP TABLE stage.DimCustomer;
GO

CREATE TABLE stage.DimCustomer
WITH (DISTRIBUTION = HASH(CustomerKey))
AS
SELECT
    CustomerKey
  , GeographyKey
  , CustomerLabel
  , Title
  , FirstName
  , MiddleName
  , LastName
  , NameStyle
  , BirthDate
  , MaritalStatus
  , Suffix
  , Gender
  , EmailAddress
  , YearlyIncome
  , TotalChildren
  , NumberChildrenAtHome
  , Education
  , Occupation
  , HouseOwnerFlag
  , NumberCarsOwned
  , AddressLine1
  , AddressLine2
  , Phone
  , DateFirstPurchase
  , CustomerType
  , CompanyName
  , ETLLoadID
  , LoadDate
  , UpdateDate
FROM asb.DimCustomer;
-- ================================================================
-- Creating Dim Stage Customer Table Completed
-- ================================================================
-- ================================================================
-- Creating Dim Customer Table
-- ================================================================

IF OBJECT_ID('dbo.DimCustomer') IS NOT NULL
    DROP TABLE dbo.DimCustomer;
GO


CREATE TABLE dbo.DimCustomer
WITH (DISTRIBUTION = HASH(CustomerKey), CLUSTERED COLUMNSTORE INDEX)
AS
SELECT
    CustomerKey
  , GeographyKey
  , CustomerLabel
  , Title
  , FirstName
  , MiddleName
  , LastName
  , NameStyle
  , BirthDate
  , MaritalStatus
  , Suffix
  , Gender
  , EmailAddress
  , YearlyIncome
  , TotalChildren
  , NumberChildrenAtHome
  , Education
  , Occupation
  , HouseOwnerFlag
  , NumberCarsOwned
  , AddressLine1
  , AddressLine2
  , Phone
  , DateFirstPurchase
  , CustomerType
  , CompanyName
  , ETLLoadID
  , LoadDate
  , UpdateDate
FROM stage.DimCustomer;
GO

ALTER TABLE dbo.DimCustomer REBUILD;
GO

UPDATE STATISTICS dbo.DimCustomer WITH FULLSCAN;
GO

CREATE STATISTICS S_CustomerKey ON dbo.DimCustomer (CustomerKey) WITH FULLSCAN;
CREATE STATISTICS S_GeographyKey ON dbo.DimCustomer (GeographyKey) WITH FULLSCAN;
CREATE STATISTICS S_CustomerType ON dbo.DimCustomer (CustomerType) WITH FULLSCAN;
GO
-- ================================================================
-- Creating Dim Customer Table Completed
-- ================================================================
-- ================================================================
-- Dropping Dim Stage Table
-- ================================================================

IF OBJECT_ID('stage.DimCustomer') IS NOT NULL
    DROP TABLE stage.DimCustomer;
GO

-- ================================================================
-- Dropping Dim ASB Table
-- ================================================================

IF OBJECT_ID('asb.DimCustomer') IS NOT NULL
    DROP EXTERNAL TABLE asb.DimCustomer;
GO