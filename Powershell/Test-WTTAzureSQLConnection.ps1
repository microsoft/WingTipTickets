<#
.Synopsis
	Azure SQL database operation.
.DESCRIPTION
	This script is used to test connection to azure sql database.
.EXAMPLE
	Test-WTTAzureSQLConnection 'ServerName', 'UserName', 'Password', 'DatabaseName', 'WTTEnvironmentApplicationName'

.INPUTS    
	1. ServerName
		Azure sql database server name for connection.
	2. UserName
		Username for sql database connection.
	3. Password
		Password for sql database connection.
	4. DatabaseName
		Azure sql database name.
	5. WTTEnvironmentApplicationName
		WTT Environment Application Name

.OUTPUTS
	Message creation of DB schema.
.NOTES
	All parameters are mandatory.
.COMPONENT
	The component this cmdlet belongs to Azure Sql.
.ROLE
	The role this cmdlet belongs to the person having azure sql access.
.FUNCTIONALITY
	The functionality that best describes this cmdlet.
#>
Function Test-WTTAzureSQLConnection
{
    [CmdletBinding()]
	Param
	(   

   		# Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
        $azureResourceGroupName,

		# Azure SQL server name for connection.
		[Parameter(Mandatory=$true)]
		[String]
		$AzureSqlServerName,

		# Azure SQL db user name for connection.
		[Parameter(Mandatory=$true)]
		[String]
		$AdminUserName,

		# Azure SQL db password for connection.
		[Parameter(Mandatory=$true)]
		[String]
		$AdminPassword,

		# Azure SQL Database name.
		[Parameter(Mandatory=$true)]
		[String]        
		$AzureSqlDatabaseName
	)

    $azureSqlDatabase = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains $AzureSqlServerName -ResourceGroupNameContains $azureResourceGroupName

    if($azureSqlDatabase.Name -like $AzureSqlServerName)
    {
        $Stoploop = $false
        [int]$Retrycount = "0"
        do 
        {
	        try 
            {
		        $sql = $azureSqlDatabase.Name
                $ConnectionString = "Server=tcp:$sql.database.windows.net; Database=$AzureSqlDatabaseName; User ID=$AdminUserName; Password=$AdminPassword; Trusted_Connection=False; Encrypt=True;"
                $sqlConn = new-object ("Data.SqlClient.SqlConnection") $connectionString
                $sqlConn.Open()
                    if ($sqlConn.State -eq 'Open')
                    {
                        $sqlConn.Close();
                        Return "success"
                    }
		        $Stoploop = $true
		    }
	        catch 
            {
		        if ($Retrycount -gt 6)
                {
			        Write-Host "Could not send Information after 6 retrys."
			        $Stoploop = $true
		        }
		        else 
                {
                    Write-Host "Could not connect to SQL Server."
                    Return "Error"
		        }
	        }
            Start-Sleep -Seconds 20
        }
        While ($Stoploop -eq $false)
    }
}