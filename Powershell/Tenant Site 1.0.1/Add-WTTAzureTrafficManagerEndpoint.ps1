<#
.Synopsis
    Azure Traffic Manager operation.
 .DESCRIPTION
    This script is used to add an endpoint to an Azure Traffic Manager Profile.
 .EXAMPLE
    Add-WTTAzureTrafficManagerEndpoint -TrafficManagerProfileName <string> -AzureWebSiteName <string>
#>
function Add-WTTAzureTrafficManagerEndpoint
{
    [CmdletBinding()]
    Param
    (   
        #WTT Environment Application Name
        [Parameter(Mandatory=$true)]
        [String]
        $WTTEnvironmentApplicationName,
 
        #Azure Traffic Manager Profile Name
        [Parameter(Mandatory=$true)]
        [String]
        $AzureTrafficManagerProfileName,

        #Azure Traffic Manager Endpoint WebSite Name
        [Parameter(Mandatory=$true)]
        [String]
        $AzureWebSiteName,

        #Azure Traffic Manager Endpoint Status
        [Parameter(Mandatory=$false)]
        [String]
        $AzureTrafficManagerEndpointStatus

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
            $azureTrafficManagerDomainName = $AzureTrafficManagerProfileName + ".trafficmanager.net"
        }
        
        if ($AzureWebSiteName.ToString().Contains(".azurewebsites.net"))
        {
            $azureWebSiteDomainName = $AzureWebSiteName
            $azureWebSiteName = $AzureWebSiteName.TrimEnd(".azurewebsites.net")
        }

        else
        {
            $azureWebSiteDomainName = $AzureWebSiteName + ".azurewebsites.net"
        }
            
        if($AzureTrafficManagerEndpointStatus -eq "")
        {
            $azureTrafficManagerEndpointStatus = "Enabled"
        }        
        else
        {
            $azureTrafficManagerEndpointStatus = $AzureTrafficManagerEndpointStatus
        }

        Try 
        {
            ### Check if Azure Traffic Manager Profile Exists ###
            Write-Host "### Checking whether Azure Traffic Manager Domain Name '$azureTrafficManagerDomainName' ###" -foregroundcolor "yellow"
            Write-Host "### and Azure WebSite '$azureWebSiteDomainName' exists. ###" -foregroundcolor "yellow"
            
            #Returns false if domain name is not available i.e. already exists
            $azureTrafficManagerDomainNameExists = Test-AzureTrafficManagerDomainName -DomainName $azureTrafficManagerDomainName
            
            #Returns true if domain name is taken i.e. already exists
            $azureWebSiteExists = Test-AzureName -Website $azureWebSiteName
                        
            if(!$azureTrafficManagerDomainNameExists)
            {
                Write-Host "### Azure Traffic Manager Domain Name '$azureTrafficManagerDomainName' exists. ###" -foregroundcolor "yellow"
                Write-Host "### Retrieving Traffic Manager Profile. ###" -foregroundcolor "yellow"
                $azureTrafficManagerProfile = Get-AzureRmTrafficManagerProfile -ResourceGroupName $WTTEnvironmentApplicationName -Name $azureTrafficManagerProfileName

                if($azureWebSiteExists)
                {
                    Write-Host "### Azure WebSite '$azureWebSiteDomainName' exists. ###" -foregroundcolor "yellow"
                    Write-Host "### Checking if Azure WebSite $azureWebSiteDomainName' is already an endpoint in the Traffic Manager Profile '$azureTrafficManagerDomainName'. ###" -foregroundcolor "yellow"

                    $azureTrafficManagerProfileEndpoints = (Get-AzureRmTrafficManagerProfile -ResourceGroupName $WTTEnvironmentApplicationName -Name $azureTrafficManagerProfileName).Endpoints
                    #if($azureTrafficManagerProfileEndpoints.DomainName -notcontains $azureWebSiteDomainName -and $azureTrafficManagerProfileEndpoints.DomainName)
                    if($azureTrafficManagerProfileEndpoints.DomainName -notcontains $azureWebSiteDomainName)
                    {
                        Write-Host "### Adding $azureWebSiteDomainName' to Traffic Manager Profile '$azureTrafficManagerDomainName'. ###" -foregroundcolor "yellow"                    
                        $newAzureTrafficManagerEndpoint = Add-AzureTrafficManagerEndpoint -TrafficManagerProfile $azureTrafficManagerProfile -DomainName $azureWebSiteDomainName -Status $azureTrafficManagerEndpointStatus -Type AzureWebsite | Set-AzureTrafficManagerProfile
                        Write-Host "### Success: $azureWebSiteDomainName' added to Azure Traffic Manager Profile '$azureTrafficManagerDomainName'. ###" -foregroundcolor "green"
                    }
                    elseif($azureTrafficManagerProfileEndpoints.DomainName -contains $azureWebSiteDomainName)
                    {
                        Write-Host "### $azureWebSiteDomainName' Endpoint already exists in Traffic Manager Profile '$azureTrafficManagerDomainName'. ###" -foregroundcolor "yellow"                                            
                    }             
                }
                
                elseif(!$azureWebSiteExists)
                    {
                        Write-Host "### Error: Azure WebSite '$azureWebSiteDomainName' does not exist.  Please run New-WTTNewAzureWebApp.ps1 to create a new Azure WebSite. ###" -foregroundcolor "red"                                                                                          
                    }

            }
            
            elseif($azureTrafficManagerDomainNameExists)
            {
                Write-Host "### Error: Azure Traffic Manager Profile '$azureTrafficManagerDomainName' does not exist.  Please re-run New-WTTAzureTrafficManagerProfile.ps1 to create a Traffic Manager Profile. ###" -foregroundcolor "red"                                
            }     
            
        }
        Catch
        {
	        Write-Error "### Error: $Error . ###"
        }  	    
   }
 }