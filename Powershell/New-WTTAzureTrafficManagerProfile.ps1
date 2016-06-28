<#
.Synopsis
	Azure Traffic Manager operation.
.DESCRIPTION
	This script is used to create an object in Azure Traffic Manager Profile.
.EXAMPLE
	New-WTTAzureTrafficManagerProfile -AzureTrafficManagerProfileName <string>
#>
function New-WTTAzureTrafficManagerProfile
{
	[CmdletBinding()]
	Param
	(    
		# Azure Traffic Manager Profile Name
		[Parameter(Mandatory=$true)]
		[String]
		$AzureTrafficManagerProfileName,

		# Azure Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$AzureResourceGroupName
	)

	Process
	{ 
		# Build the Traffic Manager Profile Name
		if ($AzureTrafficManagerProfileName.ToString().Contains(".trafficmanager.net"))
		{
			$AzureTrafficManagerDomainName = $AzureTrafficManagerProfileName
			$AzureTrafficManagerProfileName = $AzureTrafficManagerProfileName.TrimEnd(".trafficmanager.net")   
		}
		else
		{
			$AzureTrafficManagerDomainName = $AzureTrafficManagerProfileName
		}

		Try 
		{
			# Check if Azure Traffic Manager Domain Name is Available
			LineBreak
			WriteLabel("Checking for Azure Traffic Manager '$AzureTrafficManagerDomainName'")
			$azureTrafficManager = Find-AzureRmResource -ResourceType "Microsoft.Network/trafficmanagerprofiles" -ResourceNameContains $AzureTrafficManagerProfileName -ResourceGroupNameContains $AzureResourceGroupName

			if($azureTrafficManager -eq $null)
			{
				WriteValue("Not Found")

				# Create Traffic Manage Profile
				WriteLabel("Creating Traffic Manager Profile '$AzureTrafficManagerDomainName'")
				#$newAzureTrafficManagerDomain = New-AzureTrafficManagerProfile -Name $azureTrafficManagerProfileName -DomainName $AzureTrafficManagerDomainName -LoadBalancingMethod Failover -MonitorPort 80 -MonitorProtocol Http -MonitorRelativePath "/" -Ttl 30
				$newAzureTrafficManagerDomain = New-AzureRMTrafficManagerProfile -Name $AzureTrafficManagerProfileName -ResourceGroupName $AzureResourceGroupName -RelativeDnsName $AzureTrafficManagerDomainName -TrafficRoutingMethod Weighted -MonitorPort 80 -MonitorProtocol HTTP -MonitorPath "/" -Ttl 30

				if($newAzureTrafficManagerDomain.ProfileStatus -eq "Enabled")
				{
					WriteValue("Successful")
				}
				elseif($newAzureTrafficManagerDomain.ProfileStatus -eq "Failed")
				{
					WriteValue("Failed")
				}
			}
			else
			{
				WriteValue("Found")
			}
		}
		Catch
		{
			WriteError($Error)
		}  	    
	}
}