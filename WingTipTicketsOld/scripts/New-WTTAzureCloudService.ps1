<#
.Synopsis
    Azure Cloud Service.
 .DESCRIPTION
    This script is used to create an Azure Cloud Service.
 .EXAMPLE
    New-WTTAzureCloudService -AzureCloudServiceName <string> -AzureCloudServiceLocation <location>
#>
function New-WTTAzureCloudService
{
    [CmdletBinding()]
    Param
    (   
    
        #Cloud Service Name 
        [Parameter(Mandatory = $true)] 
        [String] $AzureCloudServiceName, 

        #Azure Cloud Service Location
        [Parameter(Mandatory=$true, HelpMessage="Please specify location for your Azure Cloud Service ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String] $AzureCloudServiceLocation
    )
    Process
    { 
    	#Add-AzureAccount

        if ($AzureCloudServiceName.ToString().Contains(".cloudapp.net"))
            {
                $azureCloudServiceDomainName = $AzureCloudServiceName
                $azureCloudServiceName = $AzureCloudServiceName.TrimEnd(".cloudapp.net")
            }

        else
            {
                $azureCloudServiceDomainName = $AzureCloudServiceName + ".cloudapp.net"
            }        

        Try 
        {
            ### Check if Azure Cloud Service Exists ###
            Write-Host "### Checking whether Azure Cloud Service '$azureCloudServiceDomainName' already exists. ###" -foregroundcolor "yellow"
            $azureAzureCloudServiceExists = Test-AzureName -Service $azureCloudServiceName
            if(!$azureAzureCloudServiceExists)
            {
                # ******  Create Azure Cloud Service If Doesn't Already Exist ******
                Write-Host "### Creating new Azure Cloud Service '$azureCloudServiceDomainName' ###" -foregroundcolor "yellow"
                $newAzureCloudService = New-AzureService -ServiceName $azureCloudServiceName -Location $AzureCloudServiceLocation -Label $azureCloudServiceName -ErrorVariable newAzureCloudServiceErrors -ErrorAction SilentlyContinue
                if($newAzureCloudService.OperationStatus -eq "Succeeded")
                {
                    Write-Host "### Success: New Azure Cloud Service '$azureCloudServiceName' created. ###" -foregroundcolor "green"
                }
                elseif($newAzureCloudService.OperationStatus -eq "Failed")
                {
                    Write-Host "### Failure: New Azure Cloud Service '$azureCloudServiceName' not created due to the following exception: '$newAzureCloudServiceErrors[0].Exception'. ###" -foregroundcolor "red"
                }
            }
            elseif($azureAzureCloudServiceExists)
            {
                Write-Host "### Azure Cloud Service '$azureCloudServiceName' already exists. ###" -foregroundcolor "yellow"
            }            
        }
        Catch
        {
	        Write-Error "Error: $Error "
        }  	    
   }
 }