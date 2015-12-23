<#
.Synopsis
    Azure Sql Databases - Dummy Data Population
 .DESCRIPTIOn
    This script is used to populate dummy data for use with the WingtipTickets application.
 .EXAMPLE
    Database-Populate 'ServerName', 'UserName', 'Password', 'DatabaseName'
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
function Database-Populate
{
    [CmdletBinding()]
    Param
    (
        # SQL server name for connection.
        [Parameter(Mandatory=$true)]
        [String]
        $ServerName,
		
        # SQL db user name for connection.
        [Parameter(Mandatory=$true)]
        [String]
        $UserName,
		
        # SQL db password for connection.
        [Parameter(Mandatory=$true)]
        [String]
        $Password,
		
        # SQL database name.
        [Parameter(Mandatory=$true)]
        [String]
        $DatabaseName
    )
    Process
    {
        Try
        {
            Write-Host "Beginning to refresh and populate database with data..." -ForegroundColor Yellow
			
			Invoke-SQLcmd -InputFile ".\Database-Populate.sql" -ServerInstance "tcp:$($ServerName).database.windows.net,1433" -Username $UserName -Password $Password -EncryptConnection -QueryTimeout 300 -Database WingTipTicketsProvisioningSite
			
            Write-Host "### Finished populating the database." -ForegroundColor Green
        }
        Catch 
		{ 
			Write-Error "Error -- $Error " 
		}
        Finally
        {
            if ($Connection -ne $null -and $Connection.State -eq "Open") { $Connection.close(); $Connection = $null; }
        }
    }
}