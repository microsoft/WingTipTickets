<#
.Synopsis
	WingtipTickets (WTT) Demo Environment.
 .DESCRIPTION
	This script is used to retrieve the Matching Geo Secondary Azure SQL Database Server Region.
 .EXAMPLE
	Get-WTTSqlDatabaseServerV12RegionAvailability -WTTEnvironmentApplicationName <string>
#>
function Get-WTTSqlDatabaseServerV12RegionAvailability()
{
	[CmdletBinding()]
	Param 
	(
		# Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureResourceGroupName
	)
	$global:VerbosePreference = "SilentlyContinue"

	$wttEnvironmentPrimaryServerLocation = $null
	$wttEnvironmentSecondaryServerLocation = $null    

	$azureSqlDatabaseServerV12RegionAvailabilityArray = Get-WTTAzureSqlDatabaseServerRegionCapabilities 

	foreach ($azureDatacenterLocation in $azureSqlDatabaseServerV12RegionAvailabilityArray)
	{

		$azureResourceGroupNameWithIndex =  $azureResourceGroupName + $azureSqlDatabaseServerV12RegionAvailabilityArray.IndexOf($azureDatacenterLocation)        
		$azureStorageAccountPrimaryName = $azureResourceGroupName + $azureSqlDatabaseServerV12RegionAvailabilityArray.IndexOf($azureDatacenterLocation) + "primary"
		$azureStorageAccountResourceGroupName = $azureResourceGroupName + $azureSqlDatabaseServerV12RegionAvailabilityArray.IndexOf($azureDatacenterLocation)        

		$wTTEnvironmentPrimaryServerLocation = $azureDatacenterLocation                

		if ((AzureStorageAccountExists -AzureStorageAccountName $azureStorageAccountPrimaryName -AzureStorageAccountResourceGroupName $azureStorageAccountResourceGroupName))
		{
			break
		}

		# ******  Create Azure Storage Account ******
		else
		{
			WriteLabel("Creating Test Azure Resource Group '$azureResourceGroupNameWithIndex' in Primary region '$wTTEnvironmentPrimaryServerLocation'")
			$newAzureResourceGroup = New-AzureRMResourceGroup -Name $azureStorageAccountResourceGroupName -Location $wTTEnvironmentPrimaryServerLocation
			WriteValue("Successful")

			WriteLabel("Creating Test Azure Storage Account '$azureResourceGroupNameWithIndex' in Primary region '$wTTEnvironmentPrimaryServerLocation' to obtain Matching Geo Secondary region.")
			$newAzureStorageAccount = New-AzureRMStorageAccount -ResourceGroupName $azureStorageAccountResourceGroupName -Name $azureResourceGroupNameWithIndex -Location $wTTEnvironmentPrimaryServerLocation -Type "Standard_GRS"
			If($newAzureStorageAccount.Count -gt 0) 
			{
				WriteValue("Successful")
				
				WriteLabel("Retrieving Matching Geo Secondary region from Test Azure Storage Account '$azureResourceGroupNameWithIndex'.")
				WriteValue("Successful")
				$wTTEnvironmentSecondaryServerLocation = (Get-AzureRMStorageAccount -ResourceGroupName $azureResourceGroupNameWithIndex -StorageAccountName $azureResourceGroupNameWithIndex).SecondaryLocation                    

				If($azureSqlDatabaseServerV12RegionAvailabilityArray.Contains($wTTEnvironmentSecondaryServerLocation)) 
				{
					WriteLabel("Removing '$azureStorageAccountResourceGroupName' Test Resource Group and all related resources.")
					$null = Remove-AzureRMResourceGroup -Name $azureStorageAccountResourceGroupName -Force                       
					WriteValue("Successful")
					$wTTEnvironmentPriServerLocation = 
					Switch ($wTTEnvironmentPrimaryServerLocation)
					{
						'WestUS' {'West US'}
						'NorthEurope' {'North Europe'}
						'WestEurope' {'West Europe'}
						'EastUS' {'East US'}
						'NorthCentralUS' {'East US'}
						'SouthCentralUS' {'South Central US'}
						'EastUS2' {'East US 2'}
						'CentralUS' {'Central US'}
						'BrazilSouth' {'Brazil South'}
						'SoutheastAsia' {'Southeast Asia'}
						'EastAsia' {'EastAsia'}
						'JapanEast' {'Japan East'}
						'JapanWest' {'Japan West'}
					}

					$wTTEnvironmentSecondServerLocation = 
					Switch ($wTTEnvironmentSecondaryServerLocation)
					{
						'WestUS' {'West US'}
						'NorthEurope' {'North Europe'}
						'WestEurope' {'West Europe'}
						'EastUS' {'East US'}
						'NorthCentralUS' {'East US'}
						'SouthCentralUS' {'South Central US'}
						'EastUS2' {'East US 2'}
						'CentralUS' {'Central US'}
						'BrazilSouth' {'Brazil South'}
						'SoutheastAsia' {'Southeast Asia'}
						'EastAsia' {'EastAsia'}
						'JapanEast' {'Japan East'}
						'JapanWest' {'Japan West'}
					}

					return $wTTEnvironmentPriServerLocation, $wTTEnvironmentSecondServerLocation
					break
				}

				WriteLabel("Removing '$azureStorageAccountResourceGroupName' Test Resource Group and all related resources.")
				$null = Remove-AzureRMResourceGroup -Name $azureStorageAccountResourceGroupName -Force
				WriteValue("Successful")
			}
			else
			{
				WriteLabel("Removing '$azureStorageAccountResourceGroupName' Test Resource Group and all related resources.")
				$null = Remove-AzureRMResourceGroup -Name $azureStorageAccountResourceGroupName -Force
				WriteValue("Successful")
			}

		}
	}
}

function AzureStorageAccountExists()
{
	[CmdletBinding()]
	Param 
	(
		[Parameter(Mandatory=$true)]
		[String]$AzureStorageAccountName,
		[Parameter(Mandatory=$true)]
		[String]$AzureStorageAccountResourceGroupName
	)

	$azureStorageAccountName = $AzureStorageAccountName    
	### Check if Azure Storage Account Exists ###
	WriteLabel("Checking whether Test Azure Storage Account '$azureStorageAccountName' already exists.")
	$azureStorageAccountExists = Get-AzureRMStorageAccount -Name $AzureStorageAccountName -ResourceGroupName $AzureStorageAccountResourceGroupName -ErrorVariable azureStorageAccountExistsErrors -ErrorAction SilentlyContinue

	If($azureStorageAccountExists.Count -gt 0) 
	{
		WriteValue("Unsuccessful")
		$out = 1
	}
	else
	{
		WriteValue("Successful")
		$out = 0
	}

	return $out
}