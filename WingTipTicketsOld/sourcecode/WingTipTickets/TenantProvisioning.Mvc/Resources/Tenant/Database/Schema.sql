-- ===========================================================================================
-- CREATE TABLES
-- ===========================================================================================

CREATE TABLE Customers
(
	[CustomerId] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(50),
	[LastName] VARCHAR(50),
	[Email] VARCHAR(100),
	[ContactNbr] VARCHAR(30),
	[Password] VARCHAR(50),
	[CreditCardNbr] VARCHAR(50),
	[LastKnownLocation] GEOGRAPHY,
	[Address] VARCHAR(50),
	[CityId] INT,
	[Fax] VARCHAR(30)
)

CREATE TABLE Organizers
(
	[OrganizerId] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(50),
	[LastName] VARCHAR(50),
	[Email] VARCHAR(100),
	[ContactNbr] NUMERIC(15,0),
	[Password] VARCHAR(50),
	[Address] VARCHAR(50),
	[CityId] INT,
	[Fax] VARCHAR(30)
)

CREATE TABLE CustomerCreditCard
(
	[CustomerCreditCardI] INT PRIMARY KEY IDENTITY,
	[CustomerId] INT,
	[NameOnCard] VARCHAR(50),
	[CardType] VARCHAR(25),
	[CardNumber] VARCHAR(30),
	[ExpiryMonth] INT,
	[ExpiryYear] INT,
	[SecurityCode] VARCHAR(25)
)

CREATE TABLE Concerts
(
	[ConcertId] INT PRIMARY KEY IDENTITY,
	[ConcertName] VARCHAR(150),
	[Description] VARCHAR(250),
	[ConcertDate] DATETIME,
	[Duration] INT,
	[VenueId] INT,
	[PerformerId] INT,
	[SaveToDbServerType] INT DEFAULT 0,
	[RowVersion] ROWVERSION
)

CREATE TABLE Performers
(
	[PerformerId] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(50),
	[LastName] VARCHAR(50),
	[Skills] VARCHAR(100),
	[ContactNbr] NUMERIC(15,0),
	[ShortName] VARCHAR(30),
	[RowVersion] ROWVERSION
)

CREATE TABLE Country
(
	[CountryId] INT PRIMARY KEY IDENTITY,
	[CountryName] VARCHAR(50),
	[Description] VARCHAR(100)
)

CREATE TABLE States
(
	[StateId] INT PRIMARY KEY IDENTITY,
	[StateName] VARCHAR(50),
	[Description] VARCHAR(100),
	[CountryId] INT
)

CREATE TABLE City
(
	[CityId] INT PRIMARY KEY IDENTITY,
	[CityName] VARCHAR(50),
	[Description] VARCHAR(100),
	[StateId] INT
)

CREATE TABLE Venues
(
	[VenueId] INT PRIMARY KEY IDENTITY,
	[VenueName] VARCHAR(50),
	[Capacity] INT,
	[Description] VARCHAR(100),
	[CityId] INT,
	[RowVersion] ROWVERSION
)

CREATE TABLE SeatSection
(
	[SeatSectionId] INT PRIMARY KEY IDENTITY,
	[SeatCount] INT,
	[VenueId] INT,
	[Description] VARCHAR(100)
)

CREATE TABLE WebSiteActionLog
(
	[WebSiteActionLogId] INT PRIMARY KEY IDENTITY,
	[VenueId] INT,
	[Action] VARCHAR(100),
	[UpdatedBy] INT,
	[UpdatedDate] DATETIME
)

CREATE TABLE TicketLevels
(
	[TicketLevelId] INT PRIMARY KEY IDENTITY,
	[TicketLevel] VARCHAR(25),
	[Description] VARCHAR(100),
	[SeatSectionId] INT,
	[ConcertId] INT,
	[TicketPrice] NUMERIC(10,2)
)

CREATE TABLE Tickets
(
	[TicketId] INT PRIMARY KEY IDENTITY,
	[CustomerId] INT,
	[Name] VARCHAR(50),
	[TicketLevelId] INT,
	[ConcertId] INT,
	[PurchaseDate] DATETIME
)