<#
.Synopsis
	Azure SQL Database Server operation.
.DESCRIPTION
	This script is used to create an Azure SQL Database Server.
.EXAMPLE
	New-WTTAzureSqlDatabaseServer -AzureSqlDatabaseServerName <string> -AzureSqlDatabaseServerLocation <location> -AzureSqlDatabaseServerAdministratorUserName <string> -AzureSqlDatabaseServerAdministratorPassword <string> -AzureSqlDatabaseServerVersion <version> -AzureSqlDatabaseServerResourceGroupName <string>
#>
function New-WTTAzureSqlDatabaseServer
{
	[CmdletBinding()]
	Param
	(
		# Azure SQL Database Server Name
		[Parameter(Mandatory=$true)]
		[String]
		$AzureSqlDatabaseServerName,

		# Azure SQL Database Server Location
		[Parameter(Mandatory=$true, HelpMessage="Please specify location for Azure SQL Database Server ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
		[ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'EastUS', 'WestUS', 'SouthCentralUS', 'NorthCentralUS', 'CentralUS', 'EastAsia', 'WestEurope', 'EastUS2', 'JapanEast', 'JapanWest', 'BrazilSouth', 'NorthEurope', 'SoutheastAsia', 'AustraliaEast', 'AustraliaSoutheast')]
		[String]
		$AzureSqlDatabaseServerLocation,

		# Azure SQL Database Server Administrator User Name
		[Parameter(Mandatory=$true)]
		[String]
		$AzureSqlDatabaseServerAdministratorUserName,

		# Azure SQL Database Server Administrator Password
		[Parameter(Mandatory=$true)]
		[String]
		$AzureSqlDatabaseServerAdministratorPassword,

		# Azure SQL Database Server Version
		[Parameter(Mandatory=$true, HelpMessage="Please specify the Azure SQL Database Server Version ('2.0', '12.0')?")]
		[ValidateSet('2.0', '12.0')]
		[String]
		$AzureSqlDatabaseServerVersion,

		# Azure SQL Database Server Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$AzureSqlDatabaseServerResourceGroupName
	)

	Process
	{ 
		Try 
		{
			$azureSqlDatabaseServerResourceGroup = (Find-AzureRMResourceGroup).Name -contains $AzureSqlDatabaseServerResourceGroupName

			If($azureSqlDatabaseServerResourceGroup -eq $true)
			{
				# Check if Azure SQL Server Exists ###
				LineBreak
				WriteLabel("Checking for SQL Database Server '$AzureSqlDatabaseServerName'")

				$azureSqlDatabaseServer = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains $AzureSqlDatabaseServerName -ResourceGroupNameContains $AzureSqlDatabaseServerResourceGroupName

				If($azureSqlDatabaseServer -ne $null)
				{
					# SQL Server Exists
					WriteValue("Found")
				}
				else
				{
					# Create SQL Server
					WriteValue("Not Found")
					WriteLabel("Creating SQL Server '$AzureSqlDatabaseServerName'")

					$sqlAdministratorCredentials = new-object System.Management.Automation.PSCredential($AzureSqlDatabaseServerAdministratorUserName, ($AzureSqlDatabaseServerAdministratorPassword | ConvertTo-SecureString -asPlainText -Force))

                    $serverExists = $false
                    Do
                    {
            
            		    $newAzureSqlDatabaseServer = New-AzureRMSqlServer -ResourceGroupName $AzureSqlDatabaseServerResourceGroupName -ServerName $AzureSqlDatabaseServerName -Location $AzureSqlDatabaseServerLocation -ServerVersion $AzureSqlDatabaseServerVersion –SqlAdministratorCredentials $sqlAdministratorCredentials -ErrorVariable newAzureSqlDatabaseServerErrors -ErrorAction Stop
                        If($newAzureSqlDatabaseServer.ServerName -eq $AzureSqlDatabaseServerName) 
                        {
                            $serverExists = $true
                        }
                        else
                        {
                            $serverExists = $false
                        }

                    }While($serverExists = $false)
                    
                    $firewallExists = $false
                    Do
                    {
					    If($newAzureSqlDatabaseServer.ServerName -eq $AzureSqlDatabaseServerName) 
					    {
                            $azureSQLServerFirewallSet = Get-AzureRmSqlServerFirewallRule -ResourceGroupName $AzureSqlDatabaseServerResourceGroupName -ServerName $AzureSqlDatabaseServerName -ErrorAction SilentlyContinue -ErrorVariable getAzureRMSqlServerFirewallRule
                                if(!$azureSQLServerFirewallSet)
                                {
						            WriteValue("Successful")
						            WriteLabel("Adding firewall rule to allow access from all IP Addresses")
						            $newAzureSqlFirewallRule1 = New-AzureRMSqlServerFirewallRule -FirewallRuleName AllOpen -StartIPAddress 0.0.0.0 -EndIPAddress 255.255.255.255 -ServerName $AzureSqlDatabaseServerName -ResourceGroup $AzureSqlDatabaseServerResourceGroupName -WarningVariable newAzureSqlFirewallRule1Errors -WarningAction SilentlyContinue
						            WriteValue("Successful")

						            WriteLabel("Adding firewall rule to allow access from all Azure Services")
						            $newAzureSqlFirewallRule2 = New-AzureRMSqlServerFirewallRule -AllowAllAzureIPs -ServerName $AzureSqlDatabaseServerName -ResourceGroup $AzureSqlDatabaseServerResourceGroupName -WarningVariable newAzureSqlFirewallRule2Errors -WarningAction SilentlyContinue
						            WriteValue("Successful")
                                    $firewallExists = $true
                                }
					    }
					    else
					    {
						    WriteValue("Unsuccessful")
                            $firewallExists = $false
					    }
                    }until($firewallExists -eq $true)

				}
			}
			else
			{
				Write-Host "### Azure Resource Group '$AzureSqlDatabaseServerResourceGroupName' does not exist.  Please run New-WTTAzureResourceGroup.ps1 first. ###" -foregroundcolor "yellow"
			}
		}
		Catch
		{
			Write-Error "Error: $Error "            
		}
	}
}
