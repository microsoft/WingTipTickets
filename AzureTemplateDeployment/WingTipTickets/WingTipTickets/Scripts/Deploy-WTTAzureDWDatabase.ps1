<#
.Synopsis
	Azure SQL database operation.
.DESCRIPTION
	This script is used to create object in azure sql database.
.EXAMPLE
	Deploy-DBSchema 'ServerName', 'UserName', 'Password', 'Location', 'DatabaseEdition', 'DatabaseName'

.INPUTS    
	1. ServerName
		Azure sql database server name for connection.
	2. UserName
		Username for sql database connection.
	3. Password
		Password for sql database connection.
	4. Location
		Location ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast') for object creation
	5. DatabaseEdition
		DatabaseEdition ('Basic','Standard', 'Premium') for object creation    
	6. DatabaseName
		Azure sql database name.

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
function Deploy-WTTAzureDWDatabase
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

		# Azure SQL database server location
		[Parameter(Mandatory=$true, HelpMessage="Please specify edition for AzureSQL database ('DataWarehouse')?")]
		[ValidateSet('DataWarehouse')]
		[String]
		$databaseEdition,

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
		$azureDWDatabaseName
	)

	Process 
	{
		# Set Defaults
		$dbServerExists=$true
		$dbExists=$true

		Try 
		{
			# Check if Server Exists
			$existingDbServer = Get-AzureRmSqlServer -resourcegroupname $azureResourceGroupName -ServerName $azureSqlServerName -ErrorVariable existingDbServerErrors -ErrorAction SilentlyContinue

			if ($existingDbServer -ne $null)
			{
				$dbServerExists = $true
			}
			else
			{
				$dbServerExists = $false
				$dbExists = $false
			}
		}
		Catch
		{
			Write-Host("Azure SQL Server could not be found")
			$dbServerExists = $false
			$dbExists = $false
		}

		# Check if Database Exists
		if($dbServerExists) 
		{
			Try
			{
				Write-Host("Checking for DataWarehouse Database")
				$azureSqlDatabase = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers/databases" -ResourceNameContains $azureDWDatabaseName -ResourceGroupNameContains $azureResourceGroupName

				if ($azureSqlDatabase -ne $null)
				{
					$dbExists = $true
					Write-Host("Found")
				}
				else
				{
                    Write-Host("Not Found")
                    $dbExists = $false
                    
                    # Create database using 2000 units
					Write-Host("Creating database '$DWDatabaseName'")
					
                    $dwExist = 1
                    $retryCount = 0
                    Do
                    {
                        $retryCount++
                        $azureDWExist = New-AzureRMSqlDatabase -RequestedServiceObjectiveName "DW2000" -ServerName $azureSqlServerName -DatabaseName $azureDWDatabaseName -Edition $DatabaseEdition -ResourceGroupName $azureResourceGroupName -Verbose:$false
                        if(!$azureDWExist)
                        {
					        Write-Host("Unsuccessful, Retrying")
                            $dwExist = 1
                            Start-Sleep -Seconds 60
                        }
                        else
                        {
                            Write-Host("Successful")
                            $dwExist = 2
                        }
                        if($retryCount -eq 3)
                        {
                            Write-Host("Unable to create Azure DW Database")
                            $dwExist = 2
                            return
                        }
                    }While($dwExist -eq 1)

                    
					    $DWServer = (Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains "primary" -ExpandProperties -ResourceGroupNameContains $azureResourceGroupName).properties.FullyQualifiedDomainName
					    # Set working location
					    Push-Location -StackName wtt
					    # Create Database tables
					    ForEach($file in Get-ChildItem ".\Resources\Datawarehouse" -Filter *.sql)
					    {
						    Write-Host("Executing Script '$file'")
						    $result = Invoke-Sqlcmd -Username "$adminUserName@$azureSqlServerName" -Password $adminPassword -ServerInstance $DWServer -Database $azureDWDatabaseName -InputFile ".\Resources\Datawarehouse\$file" -QueryTimeout 0 -SuppressProviderContextWarning -IgnoreProviderContext -ErrorAction SilentlyContinue
						    Write-Host("Successful")
                            Start-Sleep -Seconds 60
					    }

					    # Set working location
					    Pop-Location -StackName wtt

					    # Downgrade to 100 units
					    Write-Host("Downgrading DataWarehouse database to 100 Units")
					    $null = Set-AzureRmSqlDatabase -RequestedServiceObjectiveName "DW100" -ServerName $azureSqlServerName -DatabaseName $azureDWDatabaseName -ResourceGroupName $azureResourceGroupName -ErrorAction SilentlyContinue
					    Write-Host("Successful")
                        Start-Sleep -s 180
                    }
			}
			Catch
			{
				Write-Host($Error)
				$dbExists = $false
			}
		}
	}
}
