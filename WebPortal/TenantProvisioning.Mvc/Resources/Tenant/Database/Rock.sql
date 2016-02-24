-- ===========================================================================================
-- DROP DATA
-- ===========================================================================================

Delete From Customers
Delete From Organizers
Delete From SeatSection
Delete From Venues
Delete From City
Delete From States
Delete From Country
Delete From WebSiteActionLog
Delete From Concerts
Delete From Performers
Delete From TicketLevels
Delete From Tickets

-- ===========================================================================================
-- INSERT CUSTOMERS
-- ===========================================================================================

SET Identity_INSERT [dbo].[Customers] ON 

INSERT [dbo].[Customers] ([CustomerId], [FirstName], [LastName], [Email], [Password]) VALUES (1, N'admin', N'admin', N'admin@admin.com', N'P@ssword1')

SET Identity_INSERT [dbo].[Customers] OFF

-- ===========================================================================================
-- INSERT COUNTRY
-- ===========================================================================================

SET Identity_INSERT [dbo].[Country] ON 

INSERT [dbo].[Country] ([CountryId], [CountryName], [Description]) VALUES (1, N'United States', NULL)

SET Identity_INSERT [dbo].[Country] OFF

-- ===========================================================================================
-- INSERT STATES
-- ===========================================================================================

SET Identity_INSERT [dbo].[States] ON 

INSERT [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) VALUES (1, N'CA', NULL, 1)
INSERT [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) VALUES (2, N'CO', NULL, 1)
INSERT [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) VALUES (3, N'FL', NULL, 1)
INSERT [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) VALUES (4, N'MA', NULL, 1)
INSERT [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) VALUES (5, N'MI', NULL, 1)
INSERT [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) VALUES (6, N'NY', NULL, 1)
INSERT [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) VALUES (7, N'OR', NULL, 1)
INSERT [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) VALUES (8, N'TX', NULL, 1)
INSERT [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) VALUES (9, N'UT', NULL, 1)
INSERT [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) VALUES (10, N'WA', NULL, 1)

SET Identity_INSERT [dbo].[States] OFF

-- ===========================================================================================
-- INSERT CITY
-- ===========================================================================================

SET Identity_INSERT [dbo].[City] ON
					 
INSERT [dbo].[City] ([CityId], [CityName], [Description], [StateId]) VALUES (1, N'Los Angeles', NULL, 1)
INSERT [dbo].[City] ([CityId], [CityName], [Description], [StateId]) VALUES (2, N'Denver', NULL, 2)
INSERT [dbo].[City] ([CityId], [CityName], [Description], [StateId]) VALUES (3, N'Jacksonville', NULL, 3)
INSERT [dbo].[City] ([CityId], [CityName], [Description], [StateId]) VALUES (4, N'Boston', NULL, 4)
INSERT [dbo].[City] ([CityId], [CityName], [Description], [StateId]) VALUES (5, N'Detroit', NULL, 5)
INSERT [dbo].[City] ([CityId], [CityName], [Description], [StateId]) VALUES (6, N'Syracuse', NULL, 6)
INSERT [dbo].[City] ([CityId], [CityName], [Description], [StateId]) VALUES (7, N'Portland', NULL, 7)
INSERT [dbo].[City] ([CityId], [CityName], [Description], [StateId]) VALUES (8, N'Austin', NULL, 8)
INSERT [dbo].[City] ([CityId], [CityName], [Description], [StateId]) VALUES (9, N'Salt Lake City', NULL, 9)
INSERT [dbo].[City] ([CityId], [CityName], [Description], [StateId]) VALUES (10, N'Seattle', NULL, 10)
INSERT [dbo].[City] ([CityId], [CityName], [Description], [StateId]) VALUES (11, N'Spokane', NULL, 10)

SET Identity_INSERT [dbo].[City] OFF

-- ===========================================================================================
-- INSERT VENUES
-- ===========================================================================================

SET Identity_INSERT [dbo].[Venues] ON 

INSERT [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) VALUES (1, N'Conrad Fischer Stands', 1000, N'', 1)
INSERT [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) VALUES (2, N'Hayden Lawrence Gardens', 1000, N'', 2)
INSERT [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) VALUES (3, N'Rene Charron Highrise', 1000, N'', 3)
INSERT [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) VALUES (4, N'Aldo Richter Hall', 1000, N'', 4)
INSERT [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) VALUES (5, N'Harriet Collier Auditorium', 1000, N'', 5)
INSERT [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) VALUES (6, N'Samuel Boyle Center', 1000, N'', 6)
INSERT [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) VALUES (7, N'Millie Stevens Memorial Plaza', 1000, N'', 7)
INSERT [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) VALUES (8, N'Louisa Zimmerman Stadium', 1000, N'', 8)
INSERT [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) VALUES (9, N'Lara Ehrle Amphitheter', 1000, N'', 9)
INSERT [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) VALUES (10, N'Antione Lacroix Dome', 1000, N'', 10)
INSERT [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) VALUES (11, N'Claude LAngelier Field', 1000, N'', 11)
INSERT [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) VALUES (12, N'Maya Haynes Arena', 1000, N'', 10)

SET Identity_INSERT [dbo].[Venues] OFF

-- ===========================================================================================
-- INSERT SEAT SECTIONS
-- ===========================================================================================

SET Identity_INSERT [dbo].[SeatSection] ON 

DECLARE @index numeric = 1
DECLARE @venueIndex numeric = 1
DECLARE @seatIndex numeric = 1

WHILE @venueIndex <= 16
BEGIN
    SET @seatIndex = 1

    WHILE @seatIndex <= 10
    BEGIN
        INSERT [dbo].[SeatSection] ([SeatSectionId], [SeatCount], [VenueId], [Description])
        VALUES (@index, 100, @venueIndex, N'')
        SET @index = @index + 1
        SET @seatIndex = @seatIndex + 1
    END

    SET @venueIndex = @venueIndex + 1
END

SET Identity_INSERT [dbo].[SeatSection] OFF

-- ===========================================================================================
-- INSERT CONCERTS
-- ===========================================================================================

SET Identity_INSERT [dbo].[Concerts] ON 

INSERT [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) VALUES (1,  N'Archie Boyle Live', N'', CAST(N'2015-01-28 00:54:01.870' AS DateTime), 3, 1, 1, 0)
INSERT [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) VALUES (2,  N'Archie Boyle Live', N'', CAST(N'2015-01-29 00:54:01.877' AS DateTime), 3, 2, 1, 0)
INSERT [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) VALUES (3,  N'Archie Boyle Live', N'', CAST(N'2015-01-30 00:54:01.880' AS DateTime), 3, 3, 1, 0)
INSERT [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) VALUES (4,  N'Archie Boyle Live', N'', CAST(N'2015-01-31 00:54:01.887' AS DateTime), 3, 4, 1, 0)
INSERT [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) VALUES (5,  N'Archie Boyle Live', N'', CAST(N'2015-02-01 00:54:01.890' AS DateTime), 3, 5, 1, 0)
INSERT [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) VALUES (6,  N'Archie Boyle Live', N'', CAST(N'2015-02-02 00:54:01.893' AS DateTime), 3, 6, 1, 0)
INSERT [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) VALUES (7,  N'Archie Boyle Live', N'', CAST(N'2015-02-03 00:54:01.897' AS DateTime), 3, 7, 1, 0)
INSERT [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) VALUES (8,  N'Archie Boyle Live', N'', CAST(N'2015-02-04 00:54:01.900' AS DateTime), 3, 8, 1, 0)
INSERT [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) VALUES (9,  N'Archie Boyle Live', N'', CAST(N'2015-02-05 00:54:01.903' AS DateTime), 3, 9, 1, 0)
INSERT [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) VALUES (10, N'Archie Boyle Live', N'', CAST(N'2015-02-06 00:54:01.907' AS DateTime), 3, 10, 1, 0)
INSERT [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) VALUES (11, N'Archie Boyle Live', N'', CAST(N'2015-02-07 00:54:01.910' AS DateTime), 3, 11, 1, 0)
INSERT [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) VALUES (12, N'Archie Boyle Live', N'', CAST(N'2015-02-08 00:54:01.910' AS DateTime), 3, 12, 1, 0)

SET Identity_INSERT [dbo].[Concerts] OFF

-- ===========================================================================================
-- INSERT PERFORMERS
-- ===========================================================================================

SET IDENTITY_INSERT [dbo].[Performers] ON     
					 
INSERT [dbo].[Performers] ([PerformerId], [FirstName], [LastName], [Skills], [ContactNbr], [ShortName]) VALUES (1, N'Archie', N'Boyle', N'RockMusic', CAST(1234567891 AS Numeric(15, 0)), N'The Archie Boyle Band')                

SET IDENTITY_INSERT [dbo].[Performers] OFF

-- ===========================================================================================
-- INSERT TICKET LEVELS
-- ===========================================================================================

SET Identity_INSERT [dbo].[TicketLevels] ON 
                    
SELECT @index = 1
SELECT @venueIndex = 1
SELECT @seatIndex = 1

WHILE @venueIndex <= 16
BEGIN
    SET @seatIndex = 1

    WHILE @seatIndex <= 10
    BEGIN
        INSERT [dbo].[TicketLevels] ([TicketLevelId], [TicketLevel], [Description], [SeatSectionId], [ConcertId], [TicketPrice])
        VALUES (@index, null, N'Level-' + CAST(@index as nvarchar(8)), @index, @venueIndex, 50 + (5*@seatIndex))
        SET @index = @index + 1
        SET @seatIndex = @seatIndex + 1
    END

    SET @venueIndex = @venueIndex + 1
END

SET Identity_INSERT [dbo].[TicketLevels] OFF

-- ===========================================================================================
-- INSERT CUSTOMERS LINKED TO RECOMMENDATIONS DATA
-- ===========================================================================================
INSERT INTO [dbo].[Customers]([FirstName], [LastName], [Email], [Password]) VALUES 
	(N'Mike', N'Flasko', N'mike.flasko@microsoft.com', N'P@ssword1'),
	(N'Gaurav', N'Malhotra', N'gamal@microsoft.com', N'P@ssword1')