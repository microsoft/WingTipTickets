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
	$currentDate = Get-Date
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
					$randomDate = RandomDate
					$purchaseDate = Get-Date $randomDate -Format "yyyy-MM-dd HH:mm:ss"
					$tminusDaysToConcert = ($currentDate-$randomDate).duration().days
					$initialPrice = GetTicketIntialPrice $ticketLevel	
					$discount = RandomDiscount
					$finalPrice = $initialPrice - ($initialPrice*($discount)/100)
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber], [TMinusDaysToConcert], [InitialPrice], [Discount], [FinalPrice]) Values ($customerID, '$name', $ticketLevel, $concert, '$purchaseDate', $seat, $tminusDaysToConcert, $initialPrice, $discount, $finalPrice)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(Section102)
                foreach($seat in $seatArray)
                {
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[1]
					$randomDate = RandomDate
					$purchaseDate = Get-Date $randomDate -Format "yyyy-MM-dd HH:mm:ss"
					$tminusDaysToConcert = ($currentDate-$randomDate).duration().days
					$initialPrice = GetTicketIntialPrice $ticketLevel			
					$discount = RandomDiscount
					$finalPrice = $initialPrice - ($initialPrice*($discount)/100)
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber], [TMinusDaysToConcert], [InitialPrice], [Discount], [FinalPrice]) Values ($customerID, '$name', $ticketLevel, $concert, '$purchaseDate', $seat, $tminusDaysToConcert, $initialPrice, $discount, $finalPrice)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(Section103)
                foreach($seat in $seatArray)
                {     
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[2]
					$randomDate = RandomDate
					$purchaseDate = Get-Date $randomDate -Format "yyyy-MM-dd HH:mm:ss"
					$tminusDaysToConcert = ($currentDate-$randomDate).duration().days
					$initialPrice = GetTicketIntialPrice $ticketLevel	
					$discount = RandomDiscount
					$finalPrice = $initialPrice - ($initialPrice*($discount)/100)
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber], [TMinusDaysToConcert], [InitialPrice], [Discount], [FinalPrice]) Values ($customerID, '$name', $ticketLevel, $concert, '$purchaseDate', $seat, $tminusDaysToConcert, $initialPrice, $discount, $finalPrice)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(section201to04)
                foreach($seat in $seatArray)
                {
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[3]
					$randomDate = RandomDate
					$purchaseDate = Get-Date $randomDate -Format "yyyy-MM-dd HH:mm:ss"
					$tminusDaysToConcert = ($currentDate-$randomDate).duration().days
					$initialPrice = GetTicketIntialPrice $ticketLevel		
					$discount = RandomDiscount
					$finalPrice = $initialPrice - ($initialPrice*($discount)/100)
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber], [TMinusDaysToConcert], [InitialPrice], [Discount], [FinalPrice]) Values ($customerID, '$name', $ticketLevel, $concert, '$purchaseDate', $seat, $tminusDaysToConcert, $initialPrice, $discount, $finalPrice)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(section201to04)
                foreach($seat in $seatArray)
                { 
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[4]
					$randomDate = RandomDate
					$purchaseDate = Get-Date $randomDate -Format "yyyy-MM-dd HH:mm:ss"
					$tminusDaysToConcert = ($currentDate-$randomDate).duration().days
					$initialPrice = GetTicketIntialPrice $ticketLevel	
					$discount = RandomDiscount
					$finalPrice = $initialPrice - ($initialPrice*($discount)/100)
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber], [TMinusDaysToConcert], [InitialPrice], [Discount], [FinalPrice]) Values ($customerID, '$name', $ticketLevel, $concert, '$purchaseDate', $seat, $tminusDaysToConcert, $initialPrice, $discount, $finalPrice)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(section201to04)
                foreach($seat in $seatArray)
                {
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[5]
					$randomDate = RandomDate
					$purchaseDate = Get-Date $randomDate -Format "yyyy-MM-dd HH:mm:ss"
					$tminusDaysToConcert = ($currentDate-$randomDate).duration().days
					$initialPrice = GetTicketIntialPrice $ticketLevel			
					$discount = RandomDiscount
					$finalPrice = $initialPrice - ($initialPrice*($discount)/100)
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber], [TMinusDaysToConcert], [InitialPrice], [Discount], [FinalPrice]) Values ($customerID, '$name', $ticketLevel, $concert, '$purchaseDate', $seat, $tminusDaysToConcert, $initialPrice, $discount, $finalPrice)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(section201to04)
                foreach($seat in $seatArray)
                {
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[6]
					$randomDate = RandomDate
					$purchaseDate = Get-Date $randomDate -Format "yyyy-MM-dd HH:mm:ss"
					$tminusDaysToConcert = ($currentDate-$randomDate).duration().days
					$initialPrice = GetTicketIntialPrice $ticketLevel	
					$discount = RandomDiscount
					$finalPrice = $initialPrice - ($initialPrice*($discount)/100)
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber], [TMinusDaysToConcert], [InitialPrice], [Discount], [FinalPrice]) Values ($customerID, '$name', $ticketLevel, $concert, '$purchaseDate', $seat, $tminusDaysToConcert, $initialPrice, $discount, $finalPrice)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(Section205to07)
                foreach($seat in $seatArray)
                { 
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[7]
					$randomDate = RandomDate
					$purchaseDate = Get-Date $randomDate -Format "yyyy-MM-dd HH:mm:ss"
					$tminusDaysToConcert = ($currentDate-$randomDate).duration().days
					$initialPrice = GetTicketIntialPrice $ticketLevel	
					$discount = RandomDiscount
					$finalPrice = $initialPrice - ($initialPrice*($discount)/100)
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber], [TMinusDaysToConcert], [InitialPrice], [Discount], [FinalPrice]) Values ($customerID, '$name', $ticketLevel, $concert, '$purchaseDate', $seat, $tminusDaysToConcert, $initialPrice, $discount, $finalPrice)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(Section205to07)
                foreach($seat in $seatArray)
                {  
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[8]
					$randomDate = RandomDate
					$purchaseDate = Get-Date $randomDate -Format "yyyy-MM-dd HH:mm:ss"
					$tminusDaysToConcert = ($currentDate-$randomDate).duration().days
					$initialPrice = GetTicketIntialPrice $ticketLevel	
					$discount = RandomDiscount
					$finalPrice = $initialPrice - ($initialPrice*($discount)/100)
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber], [TMinusDaysToConcert], [InitialPrice], [Discount], [FinalPrice]) Values ($customerID, '$name', $ticketLevel, $concert, '$purchaseDate', $seat, $tminusDaysToConcert, $initialPrice, $discount, $finalPrice)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }

                $seatArray = @(Section208)
                foreach($seat in $seatArray)
                {
                    $name = "Ticket for user admin to concert-$concert"
                    $ticketLevel = $ticketLevelID[9]
					$randomDate = RandomDate
					$purchaseDate = Get-Date $randomDate -Format "yyyy-MM-dd HH:mm:ss"
					$tminusDaysToConcert = ($currentDate-$randomDate).duration().days
					$initialPrice = GetTicketIntialPrice $ticketLevel	
					$discount = RandomDiscount
					$finalPrice = $initialPrice - ($initialPrice*($discount)/100)
                    $command = "Insert [dbo].[Tickets]([CustomerID], [Name], [TicketLevelID], [ConcertID], [PurchaseDate], [SeatNumber], [TMinusDaysToConcert], [InitialPrice], [Discount], [FinalPrice]) Values ($customerID, '$name', $ticketLevel, $concert, '$purchaseDate', $seat, $tminusDaysToConcert, $initialPrice, $discount, $finalPrice)"
                    $updateDB = Invoke-Sqlcmd -Username "$AdminUserName@$AzureSqlServerName" -Password "$AdminPassword" -ServerInstance "$AzureSqlServerName.database.windows.net" -Database $AzureSqlDatabaseName -Query $command -QueryTimeout 0 -SuppressProviderContextWarning
                }       
        }
    }
}

function section101
{
    Get-Random -count 30 -InputObject (1..60)
}
function section201to04
{
    Get-Random -Count 10 -InputObject (1..8)
}
function Section102
{
    Get-Random -Count 50 -InputObject (1..100)
}
function Section103
{
    Get-Random -Count 150 -InputObject (1..175)
}
function Section205to07
{
    Get-Random -Count 30 -InputObject (1..32)
}
function Section208
{
    Get-Random -Count 150 -InputObject (1..175)
}
function RandomDate()
{
	$numberOfDays = (0, 5, 10, 15, 20, 25, 30, 95, 200, 365)
	
	$num = Get-Random -InputObject ($numberOfDays)
	$currentDate = Get-Date 
   	$dateMin = $currentDate.AddDays(-$num) 
	$dateMax = $currentDate.AddDays(1)

	new-object datetime (Get-Random -min $dateMin.ticks -max $dateMax.ticks)
}
function RandomDiscount()
{
	$discountRanges = (0, 10, 20, 30)
    Get-Random -InputObject ($discountRanges)
}
function GetTicketIntialPrice($ticketLevel)
{
	$ticketLevel = [string]$ticketLevel
	$lastDigit = [string]$ticketLevel.Substring($ticketLevel.Length - 1)
	
	$ticketPrice  = switch ($lastDigit)
	{
		1 {100.00} 
        2 {80.00} 
        3 {60.00} 
        4 {90.00} 
        5 {90.00} 
        6 {70.00} 
        7 {70.00}
        8 {50.00} 
		9 {50.00}
        0 {35.00} 
        default {0}
	}

	return $ticketPrice   
}