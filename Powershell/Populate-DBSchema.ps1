<#
.Synopsis
	Azure Sql Databases - Dummy Data Population
.DESCRIPTIOn
	This script is used to populate dummy data for use with the WingtipTickets application.
.EXAMPLE
	Populate-DBSchema 'ServerName', 'UserName', 'Password', 'DatabaseName'
.INPUTS
	1. ServerName
		Azure sql database server name for connection.
	2. UserName
		Username for sql database connection.
	3. Password
		Password for sql database connection.
	4. DatabaseName
		Azure Sql Database Name

.OUTPUTS
	By executing this script, you will receive messages regarding success or failure of data Insertion.
.NOTES
	The server name, user name, and password parameters are mandatory.
#>
function Populate-DBSchema
{
	[CmdletBinding()]
	Param
	(
		# Azure SQL server name for connection.
		[Parameter(Mandatory=$true)]
		[String]
		$ServerName,

		# Azure SQL db user name for connection.
		[Parameter(Mandatory=$true)]
		[String]
		$UserName,

		# Azure SQL db password for connection.
		[Parameter(Mandatory=$true)]
		[String]
		$Password,

		# Azure SQL database name.
		[Parameter(Mandatory=$true)]
		[String]
		$DatabaseName
	)

	Process
	{
		Try
		{
			# Build the required connection details
			$ConnectionString = "Server=tcp:$ServerName.database.windows.net; Database=$DatabaseName; User ID=$UserName; Password=$Password; Trusted_Connection=False; Encrypt=True;"

			$Connection = New-object system.data.SqlClient.SqlConnection($ConnectionString)
			$Command = New-Object System.Data.SqlClient.SqlCommand('',$Connection)
            $Command.CommandTimeout = 0

			# Open the connection to the Database
			WriteLabel("Connecting to database")
			$Connection.Open()
			If(!$Connection)
			{
				throw "Failed to Connect $ConnectionString"
			}
			WriteValue("Successful")

			# Clean Tables
			LineBreak
			WriteLabel("Cleaning Customers table")
			$Command.CommandText = "Delete From Customers"
			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			WriteLabel("Cleaning Organizers table")
			$Command.CommandText = "Delete From Organizers"
			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			WriteLabel("Cleaning SeatSection table")
			$Command.CommandText = "Delete From SeatSection"
			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			WriteLabel("Cleaning Venues table")
			$Command.CommandText = "Delete From Venues"
			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			WriteLabel("Cleaning City table")
			$Command.CommandText = "Delete From City"
			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			WriteLabel("Cleaning States table")
			$Command.CommandText = "Delete From States"
			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			WriteLabel("Cleaning Country table")
			$Command.CommandText = "Delete From Country"
			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			WriteLabel("Cleaning WebSiteActionLog table")
			$Command.CommandText = "Delete From WebSiteActionLog"
			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			WriteLabel("Cleaning Concerts table")
			$Command.CommandText = "Delete From Concerts"
			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			WriteLabel("Cleaning Performers table")
			$Command.CommandText = "Delete From Performers"
			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			WriteLabel("Cleaning TicketLevels table")
			$Command.CommandText = "Delete From TicketLevels"
			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			WriteLabel("Cleaning Tickets table")
			$Command.CommandText = "Delete From Tickets"
			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			# Populate Customers Table
			$Command.CommandText =
				"INSERT INTO [dbo].[Customers]([FirstName], [LastName], [Email], [Password]) VALUES 
					(N'admin', N'admin', N'admin@admin.com', N'P@ssword1'),
					(N'Mike', N'Flasko', N'mike.flasko@microsoft.com', N'P@ssword1'),
					(N'Gaurav', N'Malhotra', N'gamal@microsoft.com', N'P@ssword1')
				"

			LineBreak
			WriteLabel("Populating Customers table")
			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			# Populate Countries Table
			WriteLabel("Populating Countries table")
			$Command.CommandText =
				"
					Set Identity_Insert [dbo].[Country] On 
					Insert [dbo].[Country] ([CountryId], [CountryName], [Description]) Values (1, N'United States', NULL)
					Set Identity_Insert [dbo].[Country] Off
				"

			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			# Populate States Table
			WriteLabel("Populating States table")
			$Command.CommandText =
				"
					Set Identity_Insert [dbo].[States] On
					Insert [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) Values (1, N'CA', NULL, 1)
					Insert [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) Values (2, N'CO', NULL, 1)
					Insert [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) Values (3, N'FL', NULL, 1)
					Insert [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) Values (4, N'MA', NULL, 1)
					Insert [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) Values (5, N'MI', NULL, 1)
					Insert [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) Values (6, N'NY', NULL, 1)
					Insert [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) Values (7, N'OR', NULL, 1)
					Insert [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) Values (8, N'TX', NULL, 1)
					Insert [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) Values (9, N'UT', NULL, 1)
					Insert [dbo].[States] ([StateId], [StateName], [Description], [CountryId]) Values (10, N'WA', NULL, 1)
					Set Identity_Insert [dbo].[States] Off
				"

			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			# Populate City Table
			WriteLabel("Populating City table")
			$Command.CommandText =
				"
					Set Identity_Insert [dbo].[City] On 
					Insert [dbo].[City] ([CityId], [CityName], [Description], [StateId]) Values (1, N'Los Angeles', NULL, 1)
					Insert [dbo].[City] ([CityId], [CityName], [Description], [StateId]) Values (2, N'Denver', NULL, 2)
					Insert [dbo].[City] ([CityId], [CityName], [Description], [StateId]) Values (3, N'Jacksonville', NULL, 3)
					Insert [dbo].[City] ([CityId], [CityName], [Description], [StateId]) Values (4, N'Boston', NULL, 4)
					Insert [dbo].[City] ([CityId], [CityName], [Description], [StateId]) Values (5, N'Detroit', NULL, 5)
					Insert [dbo].[City] ([CityId], [CityName], [Description], [StateId]) Values (6, N'Syracuse', NULL, 6)
					Insert [dbo].[City] ([CityId], [CityName], [Description], [StateId]) Values (7, N'Portland', NULL, 7)
					Insert [dbo].[City] ([CityId], [CityName], [Description], [StateId]) Values (8, N'Austin', NULL, 8)
					Insert [dbo].[City] ([CityId], [CityName], [Description], [StateId]) Values (9, N'Salt Lake City', NULL, 9)
					Insert [dbo].[City] ([CityId], [CityName], [Description], [StateId]) Values (10, N'Seattle', NULL, 10)
					Insert [dbo].[City] ([CityId], [CityName], [Description], [StateId]) Values (11, N'Spokane', NULL, 10)
					Set Identity_Insert [dbo].[City] Off
				"

			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			# Populate Venues Table
			WriteLabel("Populating Venues table")
			$Command.CommandText =
				"
					Set Identity_Insert [dbo].[Venues] On 
					Insert [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) Values (1, N'Conrad Fischer Stands', 1000, N'', 1)
					Insert [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) Values (2, N'Hayden Lawrence Gardens', 1000, N'', 2)
					Insert [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) Values (3, N'Rene Charron Highrise', 1000, N'', 3)
					Insert [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) Values (4, N'Aldo Richter Hall', 1000, N'', 4)
					Insert [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) Values (5, N'Harriet Collier Auditorium', 1000, N'', 5)
					Insert [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) Values (6, N'Samuel Boyle Center', 1000, N'', 6)
					Insert [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) Values (7, N'Millie Stevens Memorial Plaza', 1000, N'', 7)
					Insert [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) Values (8, N'Louisa Zimmerman Stadium', 1000, N'', 8)
					Insert [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) Values (9, N'Lara Ehrle Amphitheter', 1000, N'', 9)
					Insert [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) Values (10, N'Antione Lacroix Dome', 1000, N'', 10)
					Insert [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) Values (11, N'Claude LAngelier Field', 1000, N'', 11)
					Insert [dbo].[Venues] ([VenueId], [VenueName], [Capacity], [Description], [CityId]) Values (12, N'Maya Haynes Arena', 1000, N'', 10)
					Set Identity_Insert [dbo].[Venues] Off
				"

			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			# Populate SeatSection Table
			WriteLabel("Populating SeatSection table")
			$Command.CommandText =
				"
					Set Identity_Insert [dbo].[SeatSection] On

					Declare @index numeric = 1
					Declare @venueIndex numeric = 1
					Declare @seatIndex numeric = 1

					While @venueIndex <= 12
					Begin
						Set @seatIndex = 1

						While @seatIndex <= 10
						Begin
							Insert [dbo].[SeatSection] ([SeatSectionId], [SeatCount], [VenueId], [Description])
							Values (@index, 100, @venueIndex, N'')

							Set @index = @index + 1
							Set @seatIndex = @seatIndex + 1
						End

						Set @venueIndex = @venueIndex + 1
					End

					Set Identity_Insert [dbo].[SeatSection] Off
				"

			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			# Populate Concerts Table
			WriteLabel("Populating Concerts table")
			$Command.CommandText =
				"
					Set Identity_Insert [dbo].[Concerts] On 
					Insert [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) Values (1, N'Julie and the Plantes Illumination Tour', N'', Cast(N'2015-01-28 00:54:01.870' AS DateTime), 3, 1, 1, 0)
					Insert [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) Values (2, N'Julie and the Plantes Illumination Tour', N'', Cast(N'2015-01-29 00:54:01.877' AS DateTime), 3, 2, 1, 0)
					Insert [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) Values (3, N'Julie and the Plantes Illumination Tour', N'', Cast(N'2015-01-30 00:54:01.880' AS DateTime), 3, 3, 1, 0)
					Insert [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) Values (4, N'Julie and the Plantes Illumination Tour', N'', Cast(N'2015-01-31 00:54:01.887' AS DateTime), 3, 4, 1, 0)
					Insert [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) Values (5, N'Julie and the Plantes Illumination Tour', N'', Cast(N'2015-02-01 00:54:01.890' AS DateTime), 3, 5, 1, 0)
					Insert [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) Values (6, N'Julie and the Plantes Illumination Tour', N'', Cast(N'2015-02-02 00:54:01.893' AS DateTime), 3, 6, 1, 0)
					Insert [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) Values (7, N'Julie and the Plantes Illumination Tour', N'', Cast(N'2015-02-03 00:54:01.897' AS DateTime), 3, 7, 1, 0)
					Insert [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) Values (8, N'Julie and the Plantes Illumination Tour', N'', Cast(N'2015-02-04 00:54:01.900' AS DateTime), 3, 8, 1, 0)
					Insert [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) Values (9, N'Julie and the Plantes Illumination Tour', N'', Cast(N'2015-02-05 00:54:01.903' AS DateTime), 3, 9, 1, 0)
					Insert [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) Values (10, N'Julie and the Plantes Illumination Tour', N'', Cast(N'2015-02-06 00:54:01.907' AS DateTime), 3, 10, 1, 0)
					Insert [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) Values (11, N'Julie and the Plantes Illumination Tour', N'', Cast(N'2015-02-07 00:54:01.910' AS DateTime), 3, 11, 1, 0)
					Insert [dbo].[Concerts] ([ConcertId], [ConcertName], [Description], [ConcertDate], [Duration], [VenueId], [PerformerId], [SaveToDbServerType]) Values (12, N'Julie and the Plantes Illumination Tour', N'', Cast(N'2015-02-08 00:54:01.910' AS DateTime), 3, 12, 1, 0)
					Set Identity_Insert [dbo].[Concerts] Off
				"

			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			# Populate Performers Table
			WriteLabel("Populating Performers table")
			$Command.CommandText =
				"
					SET IDENTITY_INSERT [dbo].[Performers] ON 
					INSERT [dbo].[Performers] ([PerformerId], [FirstName], [LastName], [Skills], [ContactNbr], [ShortName]) VALUES (1, N'Julie', N'Plantes', N'PopMusic', CAST(1234567891 AS Numeric(15, 0)), N'Julie and the Plantes')                
					SET IDENTITY_INSERT [dbo].[Performers] OFF
				"

			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")

			# Populate TicketLevels Table
			WriteLabel("Populating TicketLevels table")
			$Command.CommandText =
				"
					Set Identity_Insert [dbo].[TicketLevels] On 

					Declare @index numeric = 1
					Declare @venueIndex numeric = 1
					Declare @seatIndex numeric = 1

					While @venueIndex <= 12
					Begin
						Set @seatIndex = 1

						While @seatIndex <= 10
						Begin
							Insert [dbo].[TicketLevels] ([TicketLevelId], [TicketLevel], [Description], [SeatSectionId], [ConcertId], [TicketPrice])
							Values (@index, null, N'Level-' + Cast(@index as nvarchar(8)), @index, @venueIndex, 50 + (5*@seatIndex))
							Set @index = @index + 1
							Set @seatIndex = @seatIndex + 1
						End

						Set @venueIndex = @venueIndex + 1
					End

					UPDATE	TicketLevels
					SET		Description = 
								CASE
									WHEN TicketPrice = 55.00 THEN '219-221'
									WHEN TicketPrice = 60.00 THEN '218-214'
									WHEN TicketPrice = 65.00 THEN '222-226'
									WHEN TicketPrice = 70.00 THEN '210-213'
									WHEN TicketPrice = 75.00 THEN '201-204'
									WHEN TicketPrice = 80.00 THEN '114-119'
									WHEN TicketPrice = 85.00 THEN '120-126'
									WHEN TicketPrice = 90.00 THEN '104-110'
									WHEN TicketPrice = 95.00 THEN '111-113'
									ELSE '101-103'
								END

					Set Identity_Insert [dbo].[TicketLevels] Off
				"

			$Result = $Command.ExecuteNonQuery()
			WriteValue("Successful")
		}
		Catch 
		{ 
			WriteError("$Error")
		}
		Finally
		{
			$Command = $null
			$ConnectionString = $null

			if ($Connection -ne $null -and $Connection.State -eq "Open") 
			{ 
				$Connection.close(); 
				$Connection = $null; 
			}
		}
	}
}