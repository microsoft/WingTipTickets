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
		$AzureSqlServerName,

		# Azure SQL Database Server Location
		[Parameter(Mandatory=$false, HelpMessage="Please specify the primary location for your WTT Environment ('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East', 'West Central US')?")]
		[ValidateSet('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East', 'West Central US', 'EastUS', 'WestUS', 'SouthCentralUS', 'NorthCentralUS', 'CentralUS', 'EastAsia', 'WestEurope', 'EastUS2', 'JapanEast', 'JapanWest', 'BrazilSouth', 'NorthEurope', 'SoutheastAsia', 'AustraliaEast', 'AustraliaSoutheast', 'CanadaCentral', 'CanadaEast', 'UKSouth', 'UKWest', 'WestUS2', 'WestCentralUS')]
		[String]
		$AzureSqlServerLocation,

		# Azure SQL Database Server Administrator User Name
		[Parameter(Mandatory=$true)]
		[String]
		$AdminUserName,

		# Azure SQL Database Server Administrator Password
		[Parameter(Mandatory=$true)]
		[String]
		$AdminPassword,

		# Azure SQL Database Server Version
		[Parameter(Mandatory=$true, HelpMessage="Please specify the Azure SQL Database Server Version ('2.0', '12.0')?")]
		[ValidateSet('2.0', '12.0')]
		[String]
		$AzureSqlServerVersion,

		# Azure SQL Database Server Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureResourceGroupName
	)

	Process
	{ 
		Try 
		{
			$azureResourceGroup = (Find-AzureRMResourceGroup).Name -contains $azureResourceGroupName

			If($azureResourceGroup -eq $true)
			{
				# Check if Azure SQL Server Exists ###
				LineBreak
				WriteLabel("Checking for SQL Database Server '$AzureSqlServerName'")

				$azureSqlDatabaseServer = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains $AzureSqlServerName -ResourceGroupNameContains $azureResourceGroupName

				If($azureSqlDatabaseServer -ne $null)
				{
					# SQL Server Exists
					WriteValue("Found")
				}
				else
				{
					# Create SQL Server
					WriteValue("Not Found")
					WriteLabel("Creating SQL Server '$AzureSqlServerName'")

					$sqlAdministratorCredentials = new-object System.Management.Automation.PSCredential($AdminUserName, ($AdminPassword | ConvertTo-SecureString -asPlainText -Force))

                    $serverExists = $false
                    Do
                    {
            
            		    $newAzureSqlServer = New-AzureRMSqlServer -ResourceGroupName $azureResourceGroupName -ServerName $AzureSqlServerName -Location $AzureSqlServerLocation -ServerVersion $AzureSqlServerVersion –SqlAdministratorCredentials $sqlAdministratorCredentials -ErrorVariable newAzureSqlDatabaseServerErrors -ErrorAction Stop
                        If($newAzureSqlServer.ServerName -eq $AzureSqlServerName) 
                        {
                            $serverExists = $true
                        }
                        else
                        {
                            $serverExists = $false
                        }

                    }While($serverExists = $false)
                    
                    Start-Sleep -Seconds 30

                    $firewallExists = $false
                    Do
                    {
					    If($newAzureSqlServer.ServerName -eq $AzureSqlServerName) 
					    {
                            $azureSQLServerFirewallSet = Get-AzureRmSqlServerFirewallRule -ResourceGroupName $azureResourceGroupName -ServerName $AzureSqlServerName -ErrorAction SilentlyContinue -ErrorVariable getAzureRMSqlServerFirewallRule
                            if(!$azureSQLServerFirewallSet)
                            {
						        WriteValue("Successful")
						        WriteLabel("Adding firewall rule to allow access from all IP Addresses")
						        $newAzureSqlFirewallRule1 = New-AzureRMSqlServerFirewallRule -FirewallRuleName AllOpen -StartIPAddress 0.0.0.0 -EndIPAddress 255.255.255.255 -ServerName $AzureSqlServerName -ResourceGroup $azureResourceGroupName -WarningVariable newAzureSqlFirewallRule1Errors -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
						        WriteValue("Successful")

						        WriteLabel("Adding firewall rule to allow access from all Azure Services")
						        $newAzureSqlFirewallRule2 = New-AzureRMSqlServerFirewallRule -AllowAllAzureIPs -ServerName $AzureSqlServerName -ResourceGroup $azureResourceGroupName -WarningVariable newAzureSqlFirewallRule2Errors -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
						        WriteValue("Successful")
                                $firewallExists = $true
                            }
					    }
					    else
					    {
						    WriteValue("Unsuccessful")
                            $firewallExists = $false
                            Start-Sleep -Seconds 20
					    }
                    }until($firewallExists -eq $true)
				}
			}
			else
			{
				WriteError("Azure Resource Group '$azureResourceGroupName' does not exist.  Please run New-WTTAzureResourceGroup.ps1 first.")
			}
		}
		Catch
		{
			Write-Error "Error: $Error "            
		}
	}
}
