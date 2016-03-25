<#
.Synopsis
	WingtipTickets (WTT) Demo Environment.
 .DESCRIPTION
	This script is used to retrieve the list of Azure SQL Database Server datacenter capabilities.
 .EXAMPLE
	Get-WTTAzureSqlDatabaseServerRegionCapabilities
#>
function Get-WTTAzureSqlDatabaseServerRegionCapabilities
{
	Process
	{
        try
		{
			$azureDatacenterLocationsList = (Get-AzureRmResourceProvider -ListAvailable | Where-Object {$_.ProviderNamespace -eq 'Microsoft.Sql'}).Locations
			$azureDatacenterLocationsList = ($azureDatacenterLocationsList -replace '\s','').ToLower()
			[System.Collections.ArrayList]$locationsWithV12CapabilityList = @()

			foreach ($location in $azureDatacenterLocationsList)
			{
				$locationsWithV12CapabilityList.Add($location) > $null
			}
			$locationsWithV12CapabilityList | Sort-Object -Descending
		}
		Catch
		{
			Write-Error "Error: $Error "
		}
	}
}