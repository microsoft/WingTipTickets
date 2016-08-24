<#
.Synopsis
	WingtipTickets (WTT) Demo Environment.
.DESCRIPTION
	This script is used to create a new WingtipTickets (WTT) Demo Environment.
.EXAMPLE
	Populate-Tickets 
WingTipTickets PowerShell Version 2.6
#>

function Populate-Tickets
{
	[CmdletBinding()]
	Param
	(
		# Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureResourceGroupName,

        # Azure SQL Database Server Administrator User Name
		[Parameter(Mandatory=$true)]
		[String]
		$AdminUserName,

		# Azure SQL Database Server Adminstrator Password
		[Parameter(Mandatory=$true)]
		[String]
		$AdminPassword,
        
        # Azure Tenant SQL Database Name
		[Parameter(Mandatory=$false)]
		[String]		
        $AzureSqlDatabaseName,

		# Azure SQL server name for connection.
		[Parameter(Mandatory=$true)]
		[String]
		$AzureSqlServerName
    )

    $date = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    $customerID = 1

    #Test SQL Server Connection
	$testSQLConnection = Test-WTTAzureSQLConnection -AzureSqlServerName $AzureSqlServerName -adminUserName $AdminUserName -adminPassword $AdminPassword -AzureSqlDatabaseName $AzureSqlDatabaseName -azureResourceGroupName $azureResourceGroupName
	if ($testSQLConnection -notlike "success")
	{
		WriteError("Unable to connect to SQL Server")
	}
	Else
	{
        $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query "set Identity_insert dbo.tickets on" -QueryTimeout 0 -SuppressProviderContextWarning
        $concertID = @(1..12)

        foreach ($concert in $concertID)
        {
            $ticketLevelID = switch($concert)
            {
            '1' {@(1..10)}
            '2' {@(11..20)}
            '3' {@(21..30)}
            '4' {@(31..40)}
            '5' {@(41..50)}
            '6' {@(51..60)}
            '7' {@(61..70)}
            '8' {@(71..80)}
            '9' {@(81..90)}
            '10' {@(91..100)}
            '11' {@(101..110)}
            '12' {@(111..120)}
            }
                $seatArray = @(Section101)
                foreach($seat in $seatArray)
                {
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[0]
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber]) Values ($customerID, '$name', $ticketLevel, $concert, '$date', $seat)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(Section102)
                foreach($seat in $seatArray)
                {
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[1]
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber]) Values ($customerID, '$name', $ticketLevel, $concert, '$date', $seat)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(Section103)
                foreach($seat in $seatArray)
                {     
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[2]
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber]) Values ($customerID, '$name', $ticketLevel, $concert, '$date', $seat)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(section201to04)
                foreach($seat in $seatArray)
                {
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[3]
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber]) Values ($customerID, '$name', $ticketLevel, $concert, '$date', $seat)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(section201to04)
                foreach($seat in $seatArray)
                { 
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[4]
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber]) Values ($customerID, '$name', $ticketLevel, $concert, '$date', $seat)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(section201to04)
                foreach($seat in $seatArray)
                {
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[5]
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber]) Values ($customerID, '$name', $ticketLevel, $concert, '$date', $seat)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(section201to04)
                foreach($seat in $seatArray)
                {
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[6]
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber]) Values ($customerID, '$name', $ticketLevel, $concert, '$date', $seat)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(Section205to07)
                foreach($seat in $seatArray)
                { 
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[7]
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber]) Values ($customerID, '$name', $ticketLevel, $concert, '$date', $seat)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(Section205to07)
                foreach($seat in $seatArray)
                {  
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[8]
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber]) Values ($customerID, '$name', $ticketLevel, $concert, '$date', $seat)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(Section208)
                foreach($seat in $seatArray)
                {
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[9]
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber]) Values ($customerID, '$name', $ticketLevel, $concert, '$date', $seat)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }       
        }
    }
}

function section101
{
    Get-Random -count 15 -InputObject (1..60)
}
function section201to04
{
    Get-Random -Count 4 -InputObject (1..8)
}
function Section102
{
    Get-Random -Count 25 -InputObject (1..100)
}
function Section103
{
    Get-Random -Count 65 -InputObject (1..175)
}
function Section205to07
{
    Get-Random -Count 9 -InputObject (1..32)
}
function Section208
{
    Get-Random -Count 45 -InputObject (1..175)
}