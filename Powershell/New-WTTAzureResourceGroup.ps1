<#
.Synopsis
	Azure Resource Group operation.
.DESCRIPTION
	This script is used to create a new Azure Resource Group.
.EXAMPLE
	New-WTTAzureResourceGroup -AzureResourceGroupLocation <location> -AzureResourceGroupName <string>
#>
function New-WTTAzureResourceGroup
{
	[CmdletBinding()]
	Param
	(
		# Azure Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureResourceGroupName,

		# Azure Resource Group Location
		[Parameter(Mandatory=$true, HelpMessage="Please specify the primary location for your WTT Environment ('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East')?")]
		[ValidateSet('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East', 'EastUS', 'WestUS', 'SouthCentralUS', 'NorthCentralUS', 'CentralUS', 'EastAsia', 'WestEurope', 'EastUS2', 'JapanEast', 'JapanWest', 'BrazilSouth', 'NorthEurope', 'SoutheastAsia', 'AustraliaEast', 'AustraliaSoutheast', 'CanadaCentral', 'CanadaEast', 'UKSouth', 'UKWest', 'WestUS2')]
		[String]
		$azureResourceGroupLocation
	)

	Process
	{ 
		Try 
		{
			$azureResourceGroupNameExists = (Find-AzureRMResourceGroup).Name -contains $azureResourceGroupName

			# Resource group does not exist - Create
			If($azureResourceGroupNameExists -eq $false)
			{
				WriteLabel("Creating Resource Group '$AzureResourceGroupName'")

				$newAzureResourceGroup = New-AzureRMResourceGroup -Name $AzureResourceGroupName -Location $AzureResourceGroupLocation -ErrorVariable newAzureResourceGroupErrors -ErrorAction SilentlyContinue

				$AzureResourceGroupNameExists = Get-AzureRMResourceGroup -Name $AzureResourceGroupName -ErrorVariable AzureResourceGroupNameExistsErrors -ErrorAction SilentlyContinue

				WriteValue((IIf ($AzureResourceGroupNameExists.Count -gt 0) "Successful" "Failed"))
			}
		}
		Catch
		{
			WriteError($Error)
		}
	}
}
