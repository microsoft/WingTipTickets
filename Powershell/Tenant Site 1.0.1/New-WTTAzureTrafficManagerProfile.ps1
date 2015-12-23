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
        #Azure Traffic Manager Profile Name
        [Parameter(Mandatory=$true)]
        [String]
        $AzureTrafficManagerProfileName
		
    )
    Process
    { 
    	#Add-AzureAccount
        if ($AzureTrafficManagerProfileName.ToString().Contains(".trafficmanager.net"))
            {
                $azureTrafficManagerDomainName = $AzureTrafficManagerProfileName
                $azureTrafficManagerProfileName = $AzureTrafficManagerProfileName.TrimEnd(".trafficmanager.net")   
            }

        else
            {
                $azureTrafficManagerDomainName = $AzureTrafficManagerProfileName   
            }

        Try 
        {
            ### Check if Azure Traffic Manager Domain Name is Available ###
            Write-Host "### Checking whether Azure Traffic Manager Domain Name '$azureTrafficManagerDomainName' already exists. ###" -foregroundcolor "yellow"
            $azureTrafficManagerDomainNameExists = Test-AzureTrafficManagerDomainName -DomainName $azureTrafficManagerDomainName
            if($azureTrafficManagerDomainNameExists)
            {
                # ******  Creating Azure Traffic Manager Domain Profile ******
                Write-Host "### Creating new Azure Traffic Manager Profile '$azureTrafficManagerDomainName'. ###" -foregroundcolor "yellow"
                #$newAzureTrafficManagerDomain = New-AzureTrafficManagerProfile -Name $azureTrafficManagerProfileName -DomainName $azureTrafficManagerDomainName -LoadBalancingMethod Failover -MonitorPort 80 -MonitorProtocol Http -MonitorRelativePath "/" -Ttl 30
				$newAzureTrafficManagerDomain = New-AzureRMTrafficManagerProfile -Name $azureTrafficManagerProfileName -ResourceGroupName $AzureTrafficManagerProfileName -RelativeDnsName $azureTrafficManagerDomainName -TrafficRoutingMethod Weighted -MonitorPort 80 -MonitorProtocol HTTP -MonitorPath "/" -Ttl 30
                if($newAzureTrafficManagerDomain.ProfileStatus -eq "Enabled")
                {
                    Write-Host "### Success: New Azure Traffic Manager Profile '$azureTrafficManagerDomainName' created. ###" -foregroundcolor "green"
                }
                elseif($newAzureTrafficManagerDomain.ProfileStatus -eq "Failed")
                {
                    Write-Host "### Failure: New Azure Traffic Manager Domain Name '$azureTrafficManagerDomainName' not created. ###" -foregroundcolor "red"
                }
            }
            elseif($azureTrafficManagerDomainNameExists -eq $false)
            {
                Write-Host "### Azure Traffic Manager Domain Name '$azureTrafficManagerDomainName' already exists. ###" -foregroundcolor "yellow"
            }            
        }
        Catch
        {
	        Write-Error "Error: $Error "
        }  	    
   }
 }