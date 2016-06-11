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
		[Parameter(Mandatory=$true, HelpMessage="Please specify a location for your Azure Resource Group ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
		[ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
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
