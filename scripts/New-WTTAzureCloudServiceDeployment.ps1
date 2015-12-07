<#
.Synopsis
    Azure Cloud Service Deployment.
 .DESCRIPTION
    This script is used to create/update an Azure Cloud Service Deployment.
 .EXAMPLE
    New-WTTAzureCloudServiceDeployment -AzureCloudServiceName <string> -AzureCloudServiceLocation <location> -AzureCloudServiceConfigurationFile <path\<>.cscfg> -AzureCloudServicePackageFile <path\<>.cspkg> -AzureCloudServiceCertificate <path\<>.pfx> -AzureCloudServiceCertificatePassword <string> -AzureStorageAccountName <string>

#>
function New-WTTAzureCloudServiceDeployment
{
    [CmdletBinding()]
    Param
    (   
    
        #Cloud Service Name 
        [Parameter(Mandatory = $true)] 
        [String] $AzureCloudServiceName, 

        #Azure Cloud Service Deployment Location
        [Parameter(Mandatory=$true, HelpMessage="Please specify location for your Azure Cloud Service Deployment ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String] $AzureCloudServiceLocation,

         #Path to Azure Cloud Service Configuration File (*.cscfg) 
        [Parameter(Mandatory = $true)] 
        [String]$AzureCloudServiceConfigurationFile, 
        
        #Path to Azure Cloud Service Package File (*.cspkg) 
        [Parameter(Mandatory = $true)] 
        [String]$AzureCloudServicePackageFile,

        #Path to Azure Cloud Service Certificate (*.pfx) 
        [Parameter(Mandatory = $true)] 
        [String]$AzureCloudServiceCertificate,

        #Azure Cloud Service Certificate Password 
        [Parameter(Mandatory = $true)] 
        [String]$AzureCloudServiceCertificatePassword,
     
        #Azure Storage Account Name
        [Parameter(Mandatory=$true)]
        [String] $AzureStorageAccountName
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
            if($azureAzureCloudServiceExists)
            {
                ### Check if Azure Cloud Service Deployment Exists ###
                Write-Host "### Checking whether a Deployed Instance for Azure Cloud Service '$azureCloudServiceDomainName' already exists. ###" -foregroundcolor "yellow"
                $azureAzureCloudServiceDeploymentExists = Get-AzureDeployment -ServiceName $azureCloudServiceName -ErrorVariable azureAzureCloudServiceDeploymentExistsErrors -ErrorAction SilentlyContinue
                if($azureAzureCloudServiceDeploymentExists.Count -eq 0)
                {
                
                    # ******  Deploy New Azure Cloud Service Instance  ******                
                    Write-Host "### Creating a new Deployment for Azure Cloud Service '$azureCloudServiceDomainName'. ###" -foregroundcolor "yellow"
                    $currentAzureSubscriptionName = Get-AzureSubscription -Current
                    Set-AzureSubscription -CurrentStorageAccountName $AzureStorageAccountName -SubscriptionName $currentAzureSubscriptionName.SubscriptionName
                
                    Write-Host "### Adding Certificate '$AzureCloudServiceCertificate' to Azure Cloud Service '$azureCloudServiceDomainName'. ###" -foregroundcolor "yellow"
                    Add-AzureCertificate -ServiceName $azureCloudServiceName -CertToDeploy $AzureCloudServiceCertificate -Password $AzureCloudServiceCertificatePassword
                                
                    New-AzureDeployment -ServiceName $azureCloudServiceName -Package $AzureCloudServicePackageFile -Configuration $AzureCloudServiceConfigurationFile -Slot Production -Label "'$AzureCloudServiceName' production"
                
                    $azureAzureCloudServiceDeploymentExists = Get-AzureDeployment -ServiceName $azureCloudServiceName
                    if($azureAzureCloudServiceDeploymentExists.Count -gt 0)
                    {
                        Write-Host "### Success: New Instance Deployed to Azure Cloud Service '$azureCloudServiceDomainName'. ###" -foregroundcolor "green"
                    }
                }
            
                elseif($azureAzureCloudServiceDeploymentExists.Count -gt 0)
                {
                    # ******  Update Existing Azure Cloud Service Deployment ******
                    Write-Host "### Updating existing Azure Cloud Service Deployment '$azureCloudServiceDomainName' ###" -foregroundcolor "yellow"
                    $newAzureCloudService = Set-AzureDeployment -ServiceName $azureCloudServiceName -Upgrade -Package $AzureCloudServicePackageFile -Configuration $AzureCloudServiceConfigurationFile -Slot Production -Mode Simultaneous
                    if($newAzureCloudService.OperationStatus -eq "Succeeded")
                    {
                        Write-Host "### Success: Existing Azure Cloud Service Instance for '$azureCloudServiceDomainName' updated. ###" -foregroundcolor "green"
                    }                  
                }        
            }
            elseif(!$azureAzureCloudServiceExists)
            {
                Write-Host "### Error: Azure Cloud Service '$azureCloudServiceDomainName' does not exist.  Please run New-WTTAzureCloudService.ps1 first. ###" -foregroundcolor "red"                
            }         
        }
        Catch
        {
	        Write-Error "Error: $Error "
        }  	    
   }
 }