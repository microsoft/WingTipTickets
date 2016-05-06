/*
1. The first step to configuring load from a Storage Account is to create
a Master Key.
-- ================================================================
-- Creating master key
-- ================================================================

IF (NOT EXISTS(SELECT * FROM sys.symmetric_keys WHERE name LIKE '%MS_DatabaseMasterKey%'))
BEGIN
	CREATE MASTER KEY;
END

2. The second step is to create a Database Scoped Credential.
-- ================================================================
-- Create a database scoped credential
-- ================================================================

IF (NOT EXISTS(SELECT * FROM sys.database_credentials WHERE Name = 'ASB_WTTCredential'))
BEGIN
	CREATE DATABASE SCOPED CREDENTIAL ASB_WTTCredential 
	WITH IDENTITY = 'Storage Account Name', SECRET = 'Storage Key'
END;

3. The third step is to specify the storage account as an External Data Source.
-- ================================================================
-- Creating external data source (Azure Blob Storage)
-- ================================================================

IF (NOT EXISTS(SELECT * FROM sys.external_data_sources WHERE Name = '<storage Account Name'))
BEGIN
	CREATE EXTERNAL DATA SOURCE <storage Account Name>
	WITH (
		TYPE = HADOOP,
		LOCATION ='wasbs://<storage container>@<Storage Account Name>.blob.core.windows.net',
		CREDENTIAL = ASB_WTTCredential
	)
END;

4. The fourth step is to specify the delimination of the data to be loaded.
-- ================================================================
-- Creating external file format (tab delimited text file)
-- ================================================================

IF (NOT EXISTS(SELECT * FROM sys.external_file_formats WHERE Name = 'tab_delimited_text_file'))
BEGIN
	CREATE EXTERNAL FILE FORMAT tab_delimited_text_file
	WITH (
		FORMAT_TYPE = DELIMITEDTEXT,
		FORMAT_OPTIONS (
			FIELD_TERMINATOR ='\t',
			USE_TYPE_DEFAULT = TRUE
		)
	)
END;

5. The fifth step is to specify the external data source type to be loaded.
-- ================================================================
-- Creating external file format (gzip tab delimited text file)
-- ================================================================

IF (NOT EXISTS(SELECT * FROM sys.external_file_formats WHERE Name = 'gzip_tab_delimited_text_file'))
BEGIN
	CREATE EXTERNAL FILE FORMAT gzip_tab_delimited_text_file
	WITH (
		FORMAT_TYPE = DELIMITEDTEXT,
		DATA_COMPRESSION = 'org.apache.hadoop.io.compress.GzipCodec',
		FORMAT_OPTIONS (
			FIELD_TERMINATOR ='\t',
			USE_TYPE_DEFAULT = TRUE
		)
	)
END;
*/
-- ================================================================
-- Creating Dim Customer Table
-- ================================================================

IF OBJECT_ID('dbo.DimCustomer2') IS NOT NULL
    DROP TABLE dbo.DimCustomer2;
GO


CREATE TABLE dbo.DimCustomer2
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
FROM asb.DimCustomer;
GO

ALTER TABLE dbo.DimCustomer2 REBUILD;
GO

UPDATE STATISTICS dbo.DimCustomer2 WITH FULLSCAN;
GO

CREATE STATISTICS S_CustomerKey ON dbo.DimCustomer2 (CustomerKey) WITH FULLSCAN;
CREATE STATISTICS S_GeographyKey ON dbo.DimCustomer2 (GeographyKey) WITH FULLSCAN;
CREATE STATISTICS S_CustomerType ON dbo.DimCustomer2 (CustomerType) WITH FULLSCAN;
GO