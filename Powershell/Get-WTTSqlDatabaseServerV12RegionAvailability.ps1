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
		[Parameter(Mandatory=$true)]
		[string]$WTTEnvironmentApplicationName
	)
	$global:VerbosePreference = "SilentlyContinue"

	$azureStorageAccountAdministratorUserName = "developer"
	$azureStorageAccountAdministratorPassword = "P@ssword1"
	$wTTEnvironmentPrimaryServerLocation = $null
	$wTTEnvironmentSecondaryServerLocation = $null    
	$wTTEnvironmentApplicationName = $WTTEnvironmentApplicationName

	$azureSqlDatabaseServerV12RegionAvailabilityArray = Get-WTTAzureSqlDatabaseServerRegionCapabilities 

	foreach ($azureDatacenterLocation in $azureSqlDatabaseServerV12RegionAvailabilityArray)
	{

		$wTTEnvironmentApplicationNameWithIndex =  $wTTEnvironmentApplicationName + $azureSqlDatabaseServerV12RegionAvailabilityArray.IndexOf($azureDatacenterLocation)        
		$azureStorageAccountPrimaryName = $wTTEnvironmentApplicationName + $azureSqlDatabaseServerV12RegionAvailabilityArray.IndexOf($azureDatacenterLocation) + "primary"
		$azureStorageAccountResourceGroupName = $wTTEnvironmentApplicationName + $azureSqlDatabaseServerV12RegionAvailabilityArray.IndexOf($azureDatacenterLocation)        

		$wTTEnvironmentPrimaryServerLocation = $azureDatacenterLocation                

		if ((AzureStorageAccountExists -AzureStorageAccountName $azureStorageAccountPrimaryName -AzureStorageAccountResourceGroupName $azureStorageAccountResourceGroupName))
		{
			break
		}

		# ******  Create Azure Storage Account ******
		else
		{
			#Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue

			WriteLabel("Creating Test Azure Resource Group '$wTTEnvironmentApplicationNameWithIndex' in Primary region '$wTTEnvironmentPrimaryServerLocation'")
			#Write-Host "### Creating Test Azure Resource Group '$wTTEnvironmentApplicationNameWithIndex' in Primary region '$wTTEnvironmentPrimaryServerLocation'. ###" -foregroundcolor "yellow"
			#$newAzureResourceGroup = New-AzureResourceGroup -Name $azureStorageAccountResourceGroupName -Location $wTTEnvironmentPrimaryServerLocation
			$newAzureResourceGroup = New-AzureRMResourceGroup -Name $azureStorageAccountResourceGroupName -Location $wTTEnvironmentPrimaryServerLocation
			WriteValue("Successful")

			WriteLabel("Creating Test Azure Storage Account '$wTTEnvironmentApplicationNameWithIndex' in Primary region '$wTTEnvironmentPrimaryServerLocation' to obtain Matching Geo Secondary region.")
			#Write-Host "### Creating Test Azure Storage Account '$wTTEnvironmentApplicationNameWithIndex' in Primary region '$wTTEnvironmentPrimaryServerLocation' to obtain Matching Geo Secondary region. ###" -foregroundcolor "yellow"
			#$newAzureStorageAccount = New-AzureStorageAccount -ResourceGroupName $azureStorageAccountResourceGroupName -Name $wTTEnvironmentApplicationNameWithIndex -Location $wTTEnvironmentPrimaryServerLocation -Type "Standard_GRS"
			$newAzureStorageAccount = New-AzureRMStorageAccount -ResourceGroupName $azureStorageAccountResourceGroupName -Name $wTTEnvironmentApplicationNameWithIndex -Location $wTTEnvironmentPrimaryServerLocation -Type "Standard_GRS"
			If($newAzureStorageAccount.Count -gt 0) 
			{
				WriteValue("Successful")
				#Write-Host "### Success: New Test Azure Storage Account '$wTTEnvironmentApplicationNameWithIndex' created. ###" -foregroundcolor "yellow"

				WriteLabel("Retrieving Matching Geo Secondary region from Test Azure Storage Account '$wTTEnvironmentApplicationNameWithIndex'.")
				WriteValue("Successful")
				#Write-Host "### Retrieving Matching Geo Secondary region from Test Azure Storage Account '$wTTEnvironmentApplicationNameWithIndex'. ###" -foregroundcolor "yellow"
				#$wTTEnvironmentSecondaryServerLocation = (Get-AzureStorageAccount -ResourceGroupName $wTTEnvironmentApplicationNameWithIndex -StorageAccountName $wTTEnvironmentApplicationNameWithIndex).SecondaryLocation                    
				$wTTEnvironmentSecondaryServerLocation = (Get-AzureRMStorageAccount -ResourceGroupName $wTTEnvironmentApplicationNameWithIndex -StorageAccountName $wTTEnvironmentApplicationNameWithIndex).SecondaryLocation                    

				#Write-Host "### Verifying Matching Geo Secondary region '$wTTEnvironmentSecondaryServerLocation' has Azure SQL Database Server version 12.0 Capacity for your subscription. ###" -foregroundcolor "yellow"                

				If($azureSqlDatabaseServerV12RegionAvailabilityArray.Contains($wTTEnvironmentSecondaryServerLocation)) 
				{
					#Write-Host "### Success: Matching Geo Secondary Region '$wTTEnvironmentSecondaryServerLocation' has Azure SQL Database Server version 12.0 Capacity for your subscription. ###" -foregroundcolor "yellow"                                        

					WriteLabel("Removing '$azureStorageAccountResourceGroupName' Test Resource Group and all related resources.")
					#Write-Host "### Removing '$azureStorageAccountResourceGroupName' Test Resource Group and all related resources. ###" -foregroundcolor "yellow"    
					#$null = Remove-AzureResourceGroup -Name $azureStorageAccountResourceGroupName -Force -PassThru                             
					#$null = Remove-AzureResourceGroup -Name $azureStorageAccountResourceGroupName -Force -PassThru                             
					$null = Remove-AzureRMResourceGroup -Name $azureStorageAccountResourceGroupName -Force                       
					WriteValue("Successful")
					$wTTEnvironmentPrimaryServerLocation = 
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

					$wTTEnvironmentSecondaryServerLocation = 
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

					return ,$wTTEnvironmentPrimaryServerLocation, $wTTEnvironmentSecondaryServerLocation > $null
					break
				}

				WriteLabel("Removing '$azureStorageAccountResourceGroupName' Test Resource Group and all related resources.")
				#Write-Host "### Removing '$azureStorageAccountResourceGroupName' Test Resource Group and all related resources. ###" -foregroundcolor "yellow"    
				#$null = Remove-AzureResourceGroup -Name $azureStorageAccountResourceGroupName -Force -PassThru
				$null = Remove-AzureRMResourceGroup -Name $azureStorageAccountResourceGroupName -Force
				WriteValue("Successful")
			}
			else
			{
				WriteLabel("Removing '$azureStorageAccountResourceGroupName' Test Resource Group and all related resources.")
				#Write-Host "### Removing '$azureStorageAccountResourceGroupName' Test Resource Group and all related resources. ###" -foregroundcolor "yellow"    
				#$null = Remove-AzureResourceGroup -Name $azureStorageAccountResourceGroupName -Force -PassThru
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
	#Write-Host "### Checking whether Test Azure Storage Account '$azureStorageAccountName' already exists. ###" -foregroundcolor "yellow"
	#$azureStorageAccountExists = Get-AzureStorageAccount -Name $AzureStorageAccountName -ResourceGroupName $AzureStorageAccountResourceGroupName -ErrorVariable azureStorageAccountExistsErrors -ErrorAction SilentlyContinue
	$azureStorageAccountExists = Get-AzureRMStorageAccount -Name $AzureStorageAccountName -ResourceGroupName $AzureStorageAccountResourceGroupName -ErrorVariable azureStorageAccountExistsErrors -ErrorAction SilentlyContinue

	If($azureStorageAccountExists.Count -gt 0) 
	{
		WriteValue("Unsuccessful")
		#Write-Host "### Test Azure Storage Account '$azureStorageAccountName' already exists.  Please use a unique Storage Account name. ###" -foregroundcolor "red"
		$out = 1
	}
	else
	{
		WriteValue("Successful")
		#Write-Host "### Test Azure Storage Account '$azureStorageAccountName' doesn't exist. ###" -foregroundcolor "yellow"
		$out = 0
	}

	return $out
}