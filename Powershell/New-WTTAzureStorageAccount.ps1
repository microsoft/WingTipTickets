<#
.Synopsis
	Azure Storage Account operation.
.DESCRIPTION
	This script is used to create an Azure Storage Account.
.EXAMPLE
	New-WTTAzureStorageAccount -AzureStorageAccountResourceGroupName <string> -AzureStorageAccountName <string> -AzureStorageAccountType <type> -AzureStorageLocation <location>
#>
function New-WTTAzureStorageAccount
{
	[CmdletBinding()]
	Param
	(
		# Azure Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$AzureResourceGroupName,

		# Azure Storage Account Name
		[Parameter(Mandatory=$true)]
		[String] $AzureStorageAccountName,

		# Azure Storage Account Type
		[Parameter(Mandatory=$true)]
		[String] $AzureStorageAccountType,

		# Azure Storage Location
		[Parameter(Mandatory=$false, HelpMessage="Please specify the primary location for your WTT Environment ('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East', 'West Central US')?")]
		[ValidateSet('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East', 'West Central US', 'EastUS', 'WestUS', 'SouthCentralUS', 'NorthCentralUS', 'CentralUS', 'EastAsia', 'WestEurope', 'EastUS2', 'JapanEast', 'JapanWest', 'BrazilSouth', 'NorthEurope', 'SoutheastAsia', 'AustraliaEast', 'AustraliaSoutheast', 'CanadaCentral', 'CanadaEast', 'UKSouth', 'UKWest', 'WestUS2', 'WestCentralUS')]
		[String] $AzureStorageLocation
	)

	Process
	{ 
		Try 
		{
			# Check if Azure Storage Account Exists
			LineBreak
			WriteLabel("Checking for Storage Account '$AzureStorageAccountName'")
			$azureStorageAccount = Find-AzureRmResource -ResourceType "Microsoft.Storage/storageaccounts" -ResourceNameContains $AzureStorageAccountName -ResourceGroupNameContains $AzureResourceGroupName

			if($azureStorageAccount -eq $null)
			{                
				WriteValue("Not Found")
				WriteLabel("Creating Storage Account '$AzureStorageAccountName'")
				$newAzureStorageAccount = New-AzureRMStorageAccount -ResourceGroupName $AzureResourceGroupName -Name $AzureStorageAccountName -Type $AzureStorageAccountType -Location $AzureStorageLocation

				if($newAzureStorageAccount.Count -gt 0)
				{
					WriteValue("Successful")
				}
				elseif($newAzureStorageAccount.OperationStatus -eq "Failed")
				{
					WriteValue("Failed")
				}
			}
			elseif($azureStorageAccount)
			{
				WriteValue("Found")
			}
		}
		Catch
		{
			Write-Error "Error: $Error"
		}
	}
}