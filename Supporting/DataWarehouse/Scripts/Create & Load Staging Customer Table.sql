
-- ================================================================
-- Creating Dim External Table
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
