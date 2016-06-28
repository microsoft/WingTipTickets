<#
.Synopsis
	Azure Traffic Manager operation.
.DESCRIPTION
	This script is used to add an endpoint to an Azure Traffic Manager Profile.
.EXAMPLE
	Add-WTTAzureTrafficManagerEndpoint -TrafficManagerProfileName <string> -AzurePrimaryWebSiteName <string> -AzureSecondaryWebSiteName <string>
#>
function Add-WTTAzureTrafficManagerEndpoint
{
	[CmdletBinding()]
	Param
	(
		# Azure Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$AzureResourceGroupName,

		# Azure Traffic Manager Profile Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureTrafficManagerProfileName,

		# Primary WebSite Name
		[Parameter(Mandatory=$true)]
		[String]
		$azurePrimaryWebAppName,

		# Secondary WebSite Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureSecondaryWebAppName,

		# Azure Traffic Manager Endpoint Status
		[Parameter(Mandatory=$false)]
		[String]
		$azureTrafficManagerEndpointStatus
	)

	Process
	{
		# Build the Traffic Manager Profile
		$AzureTrafficManagerDomainName = $AzureTrafficManagerProfileName + ".trafficmanager.net"

		# Build the Primary Website Profile
		$AzurePrimaryWebSiteDomainName = $azurePrimaryWebAppName + ".azurewebsites.net"
		
		# Build the Secondary Website Profile
		$AzureSecondaryWebSiteDomainName = $azureSecondaryWebAppName + ".azurewebsites.net"

		# Set Defaults
		if($AzureTrafficManagerEndpointStatus -eq "")
		{
			$AzureTrafficManagerEndpointStatus = "Enabled"
		}

		Try 
		{
			# Check if Traffic Manager Exists
			$AzureTrafficManager = Find-AzureRmResource -ResourceType "Microsoft.Network/trafficmanagerprofiles" -ResourceNameContains $AzureTrafficManagerProfileName -ResourceGroupNameContains $AzureResourceGroupName

			if(!$AzureTrafficManager -ne $null)
			{
				# Retrieve Traffic Manager Profile
				$AzureTrafficManagerProfile = Get-AzureRmTrafficManagerProfile -ResourceGroupName $AzureResourceGroupName -Name $AzureTrafficManagerProfileName

				# Check if Website Exists
				$AzureWebSite = Find-AzureRmResource -ResourceType "Microsoft.Web/sites" -ResourceNameContains $azurePrimaryWebAppName -ResourceGroupNameContains $AzureResourceGroupName -Verbose:$false

				if($AzureWebSite -ne $null)
				{
					WriteLabel("Checking for '$AzurePrimaryWebSiteDomainName' endpoint")
					$AzureTrafficManagerProfileEndpoints = (Get-AzureRmTrafficManagerProfile -ResourceGroupName $AzureResourceGroupName -Name $AzureTrafficManagerProfileName).Endpoints

					if ($AzureTrafficManagerProfileEndpoints.Target -notcontains $AzurePrimaryWebSiteDomainName)
					{
						WriteValue("Not Found")
						
						# Retrieve Web Application
						$TargetResourceID = (Get-AzureRMWebApp -Name $azurePrimaryWebAppName).id

						# Add Endpoint
						WriteLabel("Adding '$AzurePrimaryWebSiteDomainName' to Traffic Manager Profile")
						$newAzureTrafficManagerEndpoint = Add-AzureRmTrafficManagerEndpointConfig -TrafficManagerProfile $AzureTrafficManagerProfile -TargetResourceID $TargetResourceID -EndpointName $azurePrimaryWebAppName -EndpointStatus $azureTrafficManagerEndpointStatus -Type AzureEndpoints -priority 1
						WriteValue("Successful")
					}
					else
					{
						WriteValue("Found")
					}
				}
				else
				{
					WriteError("Azure WebSite '$AzurePrimaryWebSiteDomainName' does not exist.")
				}
				
				# Check if Website Exists
				$AzureWebSite = Find-AzureRmResource -ResourceType "Microsoft.Web/sites" -ResourceNameContains $azureSecondaryWebAppName -ResourceGroupNameContains $AzureResourceGroupName -Verbose:$false

				if($AzureWebSite -ne $null)
				{
					WriteLabel("Checking for '$AzurePrimaryWebSiteDomainName' endpoint")
					$AzureTrafficManagerProfileEndpoints = (Get-AzureRmTrafficManagerProfile -ResourceGroupName $AzureResourceGroupName -Name $AzureTrafficManagerProfileName).Endpoints

					if ($AzureTrafficManagerProfileEndpoints.Target -notcontains $AzureSecondaryWebSiteDomainName)
					{
						WriteValue("Not Found")
						
						# Retrieve Web Application
						$TargetResourceID = (Get-AzureRMWebApp -Name $azureSecondaryWebAppName).id

						# Add Endpoint
						WriteLabel("Adding '$AzureSecondaryWebSiteDomainName' to Traffic Manager Profile")
						$newAzureTrafficManagerEndpoint = Add-AzureRmTrafficManagerEndpointConfig -TrafficManagerProfile $AzureTrafficManagerProfile -TargetResourceID $TargetResourceID -EndpointName $azureSecondaryWebAppName -EndpointStatus "Disabled" -Type AzureEndpoints -priority 2
						WriteValue("Successful")
					}
					else
					{
						WriteValue("Found")
					}
				}
				else
				{
					WriteError("Azure WebSite '$AzureSecondaryWebSiteDomainName' does not exist.")
				}

				$result = Set-AzureRMTrafficManagerProfile -TrafficManagerProfile $AzureTrafficManagerProfile
			}
			else
			{
				WriteError("Azure Traffic Manager Profile '$AzureTrafficManagerDomainName' does not exist.")
			}
		}
		Catch
		{
			WriteError($Error)
		}
	}
}