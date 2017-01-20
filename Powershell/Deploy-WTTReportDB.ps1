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
        $StorageUri = "http://$azureStorageAccountName.blob.core.windows.net/wttreportingdb/wingtipreporting.bacpac"
        $storageAccountKey = "UFvFpA56CeOKi4Ectf6UEg+XB/ZfTO7GEQgAeYrRsoVM9y1xR4gIwdAqrQbHEFqjmSqAxx1MLNwLiCVg3hik5Q=="
        $sqlAdminPassword = ConvertTo-SecureString -String $adminPassword -AsPlainText -Force

		LineBreak

		Try 
		{
			# Check if Server Exists
			WriteLabel("Checking for SQL database")
            $existingDbServer = Get-AzureRmSqlServer -resourcegroupname $azureResourceGroupName -ServerName $AzureSqlServerName -ErrorVariable existingDbServerErrors -ErrorAction SilentlyContinue
			if ($existingDbServer -ne $null)
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

				if ($azureSqlDatabase -ne $null)
				{
					$dbExists = $true
					WriteValue("Found")

                    $sqlServer = (Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains "primary" -ExpandProperties -ResourceGroupNameContains $azureResourceGroupName).properties.FullyQualifiedDomainName
                    $tables = Invoke-Sqlcmd -Username "$adminUserName@$azureSqlServerName" -Password $adminPassword -ServerInstance $sqlServer -Database $azureSqlDatabaseName -Query "select name from sys.tables" -QueryTimeout 0 -SuppressProviderContextWarning -IgnoreProviderContext -ErrorAction SilentlyContinue
                    if($tables.count -gt 0)
                    {
                        foreach($table in $tables)
                        {
                            $table = $table.name
                            $dropTables = Invoke-Sqlcmd -Username "$adminUserName@$azureSqlServerName" -Password $adminPassword -ServerInstance $sqlServer -Database $azureSqlDatabaseName -Query "DROP TABLE $table" -QueryTimeout 0 -SuppressProviderContextWarning -IgnoreProviderContext -ErrorAction SilentlyContinue
                        }
                    }
                    
                    $view = Invoke-Sqlcmd -Username "$adminUserName@$azureSqlServerName" -Password $adminPassword -ServerInstance $sqlServer -Database $azureSqlDatabaseName -Query "select name from sys.views" -QueryTimeout 0 -SuppressProviderContextWarning -IgnoreProviderContext -ErrorAction SilentlyContinue
                    if($view.count -gt 0)
                    {
                        $dropView = Invoke-Sqlcmd -Username "$adminUserName@$azureSqlServerName" -Password $adminPassword -ServerInstance $sqlServer -Database $azureSqlDatabaseName -Query "DROP View SalesReport" -QueryTimeout 0 -SuppressProviderContextWarning -IgnoreProviderContext -ErrorAction SilentlyContinue
                    }    
				}
                else
                {
                    $dbExists = $true
                    WriteValue("Not Found")
                }

				if ($dbExists -eq $true)
				{					
					$dbExists = $false
					
                    if(!$azureSqlDatabase )
                    {
                        WriteLabel("Creating database '$azureSqlDatabaseName'")
		    			$importRequest = New-AzureRmSqlDatabaseImport -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlServerName -DatabaseName $azureSqlDatabaseName -StorageKeytype $StorageKeyType -StorageKey $storageAccountKey -StorageUri $StorageUri -AdministratorLogin $adminUserName -AdministratorLoginPassword $sqlAdminPassword -Edition "Standard" -ServiceObjectiveName S1 -DatabaseMaxSizeBytes 50000
	    				start-sleep -Seconds 330
                    }
    				
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