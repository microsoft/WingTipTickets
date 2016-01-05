
-- ================================================================
-- Creating Dim External Table
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
