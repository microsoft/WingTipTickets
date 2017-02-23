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
			Try
			{
				
				$DWServer = (Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains "primary" -ExpandProperties -ResourceGroupNameContains $azureResourceGroupName).properties.FullyQualifiedDomainName
				# Set working location
				Push-Location -StackName wtt
				# Create Database tables
				ForEach($file in Get-ChildItem ".\Scripts\Datawarehouse" -Filter *.sql)
				{
					WriteLabel("Executing Script '$file'")
					$result = Invoke-Sqlcmd -Username "$adminUserName@$azureSqlServerName" -Password $adminPassword -ServerInstance $DWServer -Database $azureDWDatabaseName -InputFile ".\Scripts\Datawarehouse\$file" -QueryTimeout 0 -SuppressProviderContextWarning -IgnoreProviderContext -ErrorAction SilentlyContinue
					WriteValue("Successful")
                    Start-Sleep -Seconds 60
				}

				# Set working location
				Pop-Location -StackName wtt

				# Downgrade to 100 units
				WriteLabel("Downgrading DataWarehouse database to 100 Units")
				$null = Set-AzureRmSqlDatabase -RequestedServiceObjectiveName "DW100" -ServerName $azureSqlServerName -DatabaseName $azureDWDatabaseName -ResourceGroupName $azureResourceGroupName -ErrorAction SilentlyContinue
				WriteValue("Successful")
                Start-Sleep -s 180
			}
			Catch
			{
				WriteError($Error)
			}
		}
}
