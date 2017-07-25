<#
.Synopsis
	Azure SQL database operation.
.DESCRIPTION
	This script is used to create object in azure sql database.
.EXAMPLE
	Deploy-WTTReportDB -azureResourceGroupName -azureSqlServerName <string> -adminUserName developer -adminPassword P@ssword1 -azureSqlDatabaseName <string> -azureStorageAccountName <string>
.INPUTS    
	1. azureResourceGroupName
		WTT Azure Resource Group Name
	2. adminUserName
		Username for sql database connection.
	3. adminPassword
		Password for sql database connection.
	4. azureSqlDatabaseName
        Azure SQL Database name.
	5. azureStorageAccountName
		Azure Storage Account Name.
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
function Deploy-WTTReportDB
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
		$azureSqlServerName,

		# Azure SQL db user name for connection.
		[Parameter(Mandatory=$true)]
		[String]
		$adminUserName,

		# Azure SQL db password for connection.
		[Parameter(Mandatory=$true)]
		[String]
		$adminPassword,

		# Azure SQL Database name.
		[Parameter(Mandatory=$true)]
		[String]       
		$azureSqlDatabaseName,

		# Azure Storage Account Name.
		[Parameter(Mandatory=$true)]
		[String] 
        $azureStorageAccountName
    )

	Process
	{
		$dbServerExists = $true
		$dbExists = $true
        $StorageKeyType = "StorageAccessKey"
        $StorageUri = "http://wttdatacampdwwestus.blob.core.windows.net/wttreportingdb/wingtipreporting.bacpac"
        $storageAccountKey = "aAmHC7LQYx9Sz3f/wvUb0HW31+HqGC9at6FjqSy+O5TBy7j9Gn9LUO1L12sdoup8L4OBjOhpIQt1fCJ7rMoOyw=="
        $sqlAdminPassword = ConvertTo-SecureString -String $adminPassword -AsPlainText -Force

		LineBreak

		Try 
		{
			# Check if Server Exists
			WriteLabel("Checking for SQL database")
            $existingDbServer = Get-AzureRmSqlServer -resourcegroupname $azureResourceGroupName -ServerName $AzureSqlServerName -ErrorVariable existingDbServerErrors -ErrorAction SilentlyContinue
			if ($existingDbServer)
			{
				$dbServerExists = $true
                WriteValue("Found")
			}
			else
			{
				$dbServerExists = $false
				$dbExists = $false
                WriteError("Not Found")
			}
		}
		Catch
		{
			WriteError("Azure SQL Server could not be found")
			$dbServerExists = $false
			$dbExists = $false
		}

		# Check if Database Exists
		if($dbServerExists) 
		{
			Try
			{
				WriteLabel("Checking for SQL database")
				$azureSqlDatabase = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers/databases" -ResourceNameContains $azureSqlDatabaseName -ResourceGroupNameContains $azureResourceGroupName

				if ($azureSqlDatabase)
				{
					WriteValue("Found")
                    Remove-AzureRmSqlDatabase -DatabaseName $azureSqlDatabaseName -ServerName $azureSqlServerName -ResourceGroupName $azureResourceGroupName -Force
                    $dbExists = $true
				}
                else
                {
                    $dbExists = $true
                    WriteValue("Not Found")
                }

				if ($dbExists -eq $true)
                {	

                    WriteLabel("Creating database '$azureSqlDatabaseName'")
		    		$importRequest = New-AzureRmSqlDatabaseImport -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlServerName -DatabaseName $azureSqlDatabaseName -StorageKeytype $StorageKeyType -StorageKey $storageAccountKey -StorageUri $StorageUri -AdministratorLogin $adminUserName -AdministratorLoginPassword $sqlAdminPassword -Edition "Standard" -ServiceObjectiveName S1 -DatabaseMaxSizeBytes 50000
	    			start-sleep -Seconds 330
    				
					#Test SQL Server Connection
					$testSQLConnection = Test-WTTAzureSQLConnection -AzureSqlServerName $AzureSqlServerName -adminUserName $adminUserName -adminPassword $adminPassword -AzureSqlDatabaseName $azureSqlDatabaseName -azureResourceGroupName $azureResourceGroupName
					if ($testSQLConnection -notlike "success")
					{
						WriteError("Unable to connect to SQL Server")
					}
                    else
                    {
                        WriteValue("Success")
                    }
				}
			}
			Catch
			{
				Write-Error "Error -- $Error "
				$dbExists=$false
			}
		}
	}
}