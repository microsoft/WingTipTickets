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
		# WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$WTTEnvironmentApplicationName,

		# Azure SQL server name for connection.
		[Parameter(Mandatory=$true)]
		[String]
		$ServerName,

		# Azure SQL database server location
		[Parameter(Mandatory=$true, HelpMessage="Please specify location for AzureSQL server ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
		[ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
		[String]
		$ServerLocation,

		# Azure SQL database server location
		[Parameter(Mandatory=$true, HelpMessage="Please specify edition for AzureSQL database ('DataWarehouse')?")]
		[ValidateSet('DataWarehouse')]
		[String]
		$DatabaseEdition,

		# Azure SQL db user name for connection.
		[Parameter(Mandatory=$true)]
		[String]
		$UserName,

		# Azure SQL db password for connection.
		[Parameter(Mandatory=$true)]
		[String]
		$Password,

		# Azure SQL Database name.
		[Parameter(Mandatory=$true)]
		[String]        
		$DWDatabaseName
	)

	Process 
	{
		# Set Defaults
		$dbServerExists=$true
		$dbExists=$true

		Try 
		{
			# Check if Server Exists
			$existingDbServer = Get-AzureRmSqlServer -resourcegroupname $WTTEnvironmentApplicationName -ServerName $ServerName -ErrorVariable existingDbServerErrors -ErrorAction SilentlyContinue

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
			WriteError("Azure SQL Server could not be found")
			$dbServerExists = $false
			$dbExists = $false
		}

		# Check if Database Exists
		if($dbServerExists) 
		{
			Try
			{
				LineBreak
				WriteLabel("Checking for DataWarehouse Database")
				$azureSqlDatabase = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers/databases" -ResourceNameContains $DWDatabaseName -ResourceGroupNameContains $WTTEnvironmentApplicationName

				if ($azureSqlDatabase -ne $null)
				{
					$dbExists = $true
					WriteValue("Found")
				}
				else
				{
                    WriteValue("Not Found")
                    $dbExists = $false
                    
                    # Create database using 2000 units
					WriteLabel("Creating database '$DWDatabaseName'")
					$azureDWExist = New-AzureRMSqlDatabase -RequestedServiceObjectiveName "DW2000" -ServerName $ServerName -DatabaseName $DWDatabaseName -Edition $DatabaseEdition -ResourceGroupName $WTTEnvironmentApplicationName -Verbose:$false
                    if(!$azureDWExist)
                    {
					    WriteValue("Unsuccessful")
                    }
                    else
                    {
                        WriteValue("Successful")
                    }
                    $testSQLConnection = Test-WTTAzureSQLConnection -ServerName $ServerName -UserName $UserName -Password $Password -DatabaseName $DWDatabaseName -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName
                    if ($testSQLConnection -notlike "success")
                    {
                        WriteError("Unable to connect to SQL Server")
                    }
                    Else
                    {
					    $DWServer = (Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains "primary" -ExpandProperties).properties.FullyQualifiedDomainName
					    # Set working location
					    Push-Location -StackName wtt
					    # Create Database tables
					    ForEach($file in Get-ChildItem ".\Scripts\Datawarehouse" -Filter *.sql)
					    {
						    WriteLabel("Executing Script '$file'")
						    $result = Invoke-Sqlcmd -Username "$UserName@$ServerName" -Password $Password -ServerInstance $DWServer -Database $DWDatabaseName -InputFile ".\Scripts\Datawarehouse\$file" -QueryTimeout 0 -SuppressProviderContextWarning
						    WriteValue("Successful")
                            Start-Sleep -Seconds 60
					    }

					    # Set working location
					    Pop-Location -StackName wtt

					    # Downgrade to 400 units
					    WriteLabel("Downgrading DataWarehouse database to 400 Units")
					    $null = Set-AzureRmSqlDatabase -RequestedServiceObjectiveName "DW400" -ServerName $ServerName -DatabaseName $DWDatabaseName -ResourceGroupName $WTTEnvironmentApplicationName
					    WriteValue("Successful")

    					WriteLabel("Pausing DataWarehouse database")
	    				$null = Suspend-AzureRMSqlDatabase –ResourceGroupName $WTTEnvironmentApplicationName –ServerName $ServerName –DatabaseName $DWDatabaseName
		    			WriteValue("Successful")
			    		Start-Sleep -s 180
                    }
				}
			}
			Catch
			{
				WriteError($Error)
				$dbExists = $false
			}
		}
	}
}
