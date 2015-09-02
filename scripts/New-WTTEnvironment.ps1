<#
.Synopsis
    WingtipTickets (WTT) Demo Environment.
 .DESCRIPTION
    This script is used to create a new WingtipTickets (WTT) Demo Environment.
 .EXAMPLE
    New-WTTEnvironment 
#>
function New-WTTEnvironment
{
    [CmdletBinding()]
    Param
    (   
        #WTT Environment Application Name
        [Parameter(Mandatory=$true)]
        [String]
        $WTTEnvironmentApplicationName,

        #Primary Server Location
        [Parameter(Mandatory=$false, HelpMessage="Please specify the primary location for your WTT Environment ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String]
        $WTTEnvironmentPrimaryServerLocation,

        #Azure SQL Database Server Administrator User Name
        [Parameter(Mandatory=$false)]
        [String]
        $AzureSqlDatabaseServerAdministratorUserName,

        #Azure SQL Database Server Adminstrator Password
        [Parameter(Mandatory=$false)]
        [String]
        $AzureSqlDatabaseServerAdministratorPassword,
        
        #Azure SQL Database Server Version
        [Parameter(Mandatory=$false, HelpMessage="Please specify the Azure SQL Database Server Version ('2.0', '12.0')?")]
        [ValidateSet('2.0', '12.0')]
        [String]
        $AzureSqlDatabaseServerVersion,
        
        #Azure SQL Database Name
        [Parameter(Mandatory=$false)]
        [String]
        $AzureSqlDatabaseName,

         #Path to Azure Web Site WebDeploy Packages
        [Parameter(Mandatory = $false)] 
        [String]$AzureWebSiteWebDeployPackagePath, 
        
        #Primary Azure Web Site WebDeploy Package Name
        [Parameter(Mandatory = $false)] 
        [String]$AzureWebSitePrimaryWebDeployPackageName,

        #Secondary Azure Web Site WebDeploy Package Name
        [Parameter(Mandatory = $false)] 
        [String]$AzureWebSiteSecondaryWebDeployPackageName,
        
        #Azure Active Directory Tenant Name
        [Parameter(Mandatory=$false)]
        [String]
        $AzureActiveDirectoryTenantName                
    )
    Process
    { 
        #Add-AzureAccount
        if($AzureSqlDatabaseServerAdministratorUserName -eq "")
        {
            $AzureSqlDatabaseServerAdministratorUserName = "developer"
        }

        if($AzureSqlDatabaseServerAdministratorPassword -eq "")
        {
            $AzureSqlDatabaseServerAdministratorPassword = "P@ssword1"
        }

        if($AzureSqlDatabaseServerVersion -eq "")
        {
            $AzureSqlDatabaseServerVersion = "12.0"
        }

        if($AzureSqlDatabaseName -eq "")
        {
            $AzureSqlDatabaseName = "Customer1"
        }

        if($AzureWebSiteWebDeployPackagePath -eq "")
        {
            $azureWebSiteWebDeployPackagePath = (Get-Item -Path ".\" -Verbose).FullName + "\Packages"
        }
        else
        {
            if($AzureWebSiteWebDeployPackagePath.EndsWith("\"))
            {
                $azureWebSiteWebDeployPackagePath = $AzureWebSiteWebDeployPackagePath.TrimEnd("\")
            }
            else
            {
                $azureWebSiteWebDeployPackagePath = $AzureWebSiteWebDeployPackagePath
            }
        }

        if($AzureWebSitePrimaryWebDeployPackageName -eq "")
        {
            $azureWebSitePrimaryWebDeployPackageName = "primarypackage.zip"
            $azureWebSitePrimaryWebDeployPackagePath = $azureWebSiteWebDeployPackagePath + "\" + $azureWebSitePrimaryWebDeployPackageName
        }
        else
        {
            $azureWebSitePrimaryWebDeployPackageName = $AzureWebSitePrimaryWebDeployPackageName
            $azureWebSitePrimaryWebDeployPackagePath = $azureWebSiteWebDeployPackagePath + "\" + $AzureWebSitePrimaryWebDeployPackageName
        }

        if($AzureWebSiteSecondaryWebDeployPackageName -eq "")
        {
            $azureWebSiteSecondaryWebDeployPackageName = "secondarypackage.zip"
            $azureWebSiteSecondaryWebDeployPackagePath = $azureWebSiteWebDeployPackagePath + "\" + $azureWebSiteSecondaryWebDeployPackageName
        }
        else
        {
            $azureWebSiteSecondaryWebDeployPackageName = $AzureWebSiteSecondaryWebDeployPackageName
            $azureWebSiteSecondaryWebDeployPackagePath = $azureWebSiteWebDeployPackagePath + "\" + $AzureWebSiteSecondaryWebDeployPackageName
        }
    	
        $localPath = (Get-Item -Path ".\" -Verbose).FullName

        $wTTEnvironmentApplicationName = $WTTEnvironmentApplicationName.ToLower()

        $azureStorageAccountName = $wTTEnvironmentApplicationName
        $azureSqlDatabaseServerPrimaryName = $wTTEnvironmentApplicationName + "primary"
        $azureSqlDatabaseServerSecondaryName = $wTTEnvironmentApplicationName + "secondary"        
        $azureResourceGroupName = $wTTEnvironmentApplicationName
        $azureCloudServicePrimaryName = $wTTEnvironmentApplicationName + "primary"
        $azureCloudServiceSecondaryName = $wTTEnvironmentApplicationName + "secondary"      

        $azureSqlDatabaseServerPrimaryNameExists = $null
        $azureSqlDatabaseServerSecondaryNameExists = $null

        $wTTEnvironmentSecondaryServerLocation = ""

        Try 
        {
            
            ### Silence Verbose Output ###
            Write-Host "### Silencing Verbose Output. ###" -foregroundcolor "yellow"
            $global:VerbosePreference = "SilentlyContinue"

            ### Check installed PowerShell Version ###
            Write-Host "### Checking whether installed Azure PowerShell Version is at least 0.9.7. ###" -foregroundcolor "yellow"

            $installedAzurePowerShellVersion = CheckInstalledPowerShellVersion
            if ($installedAzurePowerShellVersion -ge 0)
            {
                Write-Host "### Installed Azure PowerShell Version is at least 0.9.7. ###" -foregroundcolor "yellow"

                ### Check if both ASM and ARM are provisioned ###
                Write-Host "### Checking whether Azure Service Model (ASM) and Azure Resource Model (ARM) are provisioned. ###" -foregroundcolor "yellow"
                $supportedModes = (Get-AzureSubscription -Current).SupportedModes.Split(",")
                if ($supportedModes.Count -eq 2)
                {
                    Write-Host "### Both Azure Service Model (ASM) and Azure Resource Model (ARM) are provisioned. ###" -foregroundcolor "yellow"
                    
                    Write-Host "### Unblocking all PowerShell Scripts in the '$localPath' folder. ###" -foregroundcolor "yellow"
                    # Unblock Files
                    Get-ChildItem -Path $localPath -Filter *.ps1 | Unblock-File                               

                    Write-Host "### Loading all PowerShell Scripts in the '$localPath' folder. ###" -foregroundcolor "yellow"
                    # Load (DotSource) Scripts
                    Get-ChildItem -Path $localPath -Filter *.ps1 | ForEach { . $_.FullName }
                    
                    Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
                    Write-Host "### Checking whether Azure Resource Group '$azureResourceGroupName' already exists. ###" -foregroundcolor "yellow"
                    $azureResourceGroupNameExists = Get-AzureResourceGroup -Name $azureResourceGroupName -ErrorVariable azureResourceGroupNameExistsErrors -ErrorAction SilentlyContinue
                    If($azureResourceGroupNameExists.Count -gt 0) 
                    {
                        Write-Host "### Azure Resource Group '$azureResourceGroupName' exists. ###" -foregroundcolor "yellow"

                        ### Check if Primary Azure SQL Database Server Exists ###
                        Write-Host "### Checking whether Primary Azure SQL Database Server '$azureSqlDatabaseServerPrimaryName' already exists. ###" -foregroundcolor "yellow"
                        $azureSqlDatabaseServerPrimaryNameExists = Get-AzureSqlServer -ServerName $azureSqlDatabaseServerPrimaryName -ResourceGroupName $azureResourceGroupName -ErrorVariable azureSqlDatabaseServerPrimaryNameExistsErrors -ErrorAction SilentlyContinue
                        
                        ### Check if Secondary Azure SQL Database Server Exists ###
                        Write-Host "### Checking whether Secondary Azure SQL Database Server '$azureSqlDatabaseServerSecondaryName' already exists. ###" -foregroundcolor "yellow"
                        $azureSqlDatabaseServerSecondaryNameExists = Get-AzureSqlServer -ServerName $azureSqlDatabaseServerSecondaryName -ResourceGroupName $azureResourceGroupName -ErrorVariable azureSqlDatabaseServerSecondaryNameExistsErrors -ErrorAction SilentlyContinue
                        
                        If($azureSqlDatabaseServerPrimaryNameExists.Count -gt 0 -and $azureSqlDatabaseServerSecondaryNameExists.Count -gt 0) 
                        {
                            Write-Host "### Primary Azure SQL Database Server '$azureSqlDatabaseServerPrimaryName' already exists. ###" -foregroundcolor "yellow"
                            Write-Host "### Secondary Azure SQL Database Server '$azureSqlDatabaseServerSecondaryName' already exists. ###" -foregroundcolor "yellow"
                            $WTTEnvironmentPrimaryServerLocation = $azureSqlDatabaseServerPrimaryNameExists.Location
                            $wTTEnvironmentSecondaryServerLocation = $azureSqlDatabaseServerSecondaryNameExists.Location
                        }
                        
                        elseif($azureSqlDatabaseServerPrimaryNameExists.Count -gt 0 -and $azureSqlDatabaseServerSecondaryNameExists.Count -eq 0) 
                        {
                            Write-Host "### Primary Azure SQL Database Server '$azureSqlDatabaseServerPrimaryName' already exists. ###" -foregroundcolor "yellow"
                            Write-Host "### Secondary Azure SQL Database Server '$azureSqlDatabaseServerSecondaryName' doesn't exist. ###" -foregroundcolor "yellow"
                            Write-Host "### Removing '$azureResourceGroupName' Resource Group and all related resources. ###" -foregroundcolor "yellow"    
                            $null = Remove-AzureResourceGroup -Name $azureResourceGroupName -Force -PassThru
                            $azureResourceGroupNameExists = $null
                            $azureSqlDatabaseServerPrimaryNameExists = $null
                            $azureSqlDatabaseServerSecondaryNameExists = $null
                        }
                        elseif($azureSqlDatabaseServerPrimaryNameExists.Count -eq 0 -and $azureSqlDatabaseServerSecondaryNameExists.Count -gt 0) 
                        {
                            Write-Host "### Primary Azure SQL Database Server '$azureSqlDatabaseServerPrimaryName' doesn't exists. ###" -foregroundcolor "yellow"
                            Write-Host "### Secondary Azure SQL Database Server '$azureSqlDatabaseServerSecondaryName' already exists ###" -foregroundcolor "yellow"
                            Write-Host "### Removing '$azureResourceGroupName' Resource Group and all related resources. ###" -foregroundcolor "yellow"    
                            $null = Remove-AzureResourceGroup -Name $azureResourceGroupName -Force -PassThru
                            $azureResourceGroupNameExists = $null
                            $azureSqlDatabaseServerPrimaryNameExists = $null
                            $azureSqlDatabaseServerSecondaryNameExists = $null
                        }                        
                    }

                    if ($WTTEnvironmentPrimaryServerLocation -eq "")
                    {
                        Write-Host "### Finding a Datacenter that has Azure SQL Database Server version 12.0 capacity for your subscription. ###" -foregroundcolor "yellow"
                        if($AzureActiveDirectoryTenantName -eq "")
                        {
                            $azureSqlDatabaseServerV12RegionAvailability = Get-WTTSqlDatabaseServerV12RegionAvailability -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName
                        }
                        else
                        {
                            $azureSqlDatabaseServerV12RegionAvailability = Get-WTTSqlDatabaseServerV12RegionAvailability -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -AzureActiveDirectoryTenantName $AzureActiveDirectoryTenantName
                        }

                        if ($azureSqlDatabaseServerV12RegionAvailability.Count -eq 2)
                        {
                            $WTTEnvironmentPrimaryServerLocation = $azureSqlDatabaseServerV12RegionAvailability[0]
                            $wTTEnvironmentSecondaryServerLocation = $azureSqlDatabaseServerV12RegionAvailability[1]
                            Write-Host "### Primary Datacenter Region set to: '$WTTEnvironmentPrimaryServerLocation'. ###" -foregroundcolor "green"                            
                            Write-Host "### Secondary Datacenter Region set to: '$WTTEnvironmentSecondaryServerLocation'. ###" -foregroundcolor "green"
                            
                        }
                        else
                        {
                            if ($azureSqlDatabaseServerV12RegionAvailability.Count -ge 0)
                            {
                                $azureSqlDatabaseServerV12RegionAvailability[0]
                                $azureSqlDatabaseServerV12RegionAvailability[1]
                            }
                            Write-Host "### Error: A matching Primary and Secondary Datacenter Region that support Azure SQL Database Server version 12.0 could not be found for your subscription, please try a different subscription. ###" -foregroundcolor "red"
                            break
                        }
                    }
                                        

                    Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
                                
                    #Create Azure Resource Group
                    if ($azureResourceGroupNameExists.Count -eq 0)
                    {
                        New-WTTAzureResourceGroup -AzureResourceGroupName $azureResourceGroupName -AzureResourceGroupLocation $WTTEnvironmentPrimaryServerLocation
                    }
            
                    #Create Storage Account                    
                    New-WTTAzureStorageAccount -AzureStorageAccountResourceGroupName $azureResourceGroupName -AzureStorageAccountName $azureStorageAccountName -AzureStorageAccountType "Standard_GRS" -AzureStorageLocation $WTTEnvironmentPrimaryServerLocation
                    
                    #If a WTTEnvironmentPrimaryServerLocation value was specified, Get Secondary Server Datacenter Location
                    if ($wTTEnvironmentSecondaryServerLocation -eq "")
                    {                        
                        $wTTEnvironmentSecondaryServerLocation = (Get-AzureStorageAccount -ResourceGroupName $azureResourceGroupName -StorageAccountName $azureStorageAccountName).SecondaryLocation                     
                    }
                                        
                    if ($azureSqlDatabaseServerPrimaryNameExists.Count -eq 0)
                    {
                        #Create Primary Azure SQL Database Server if it doesn't already exist
                        New-WTTAzureSqlDatabaseServer -AzureSqlDatabaseServerName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseServerVersion $AzureSqlDatabaseServerVersion -AzureSqlDatabaseServerResourceGroupName $azureResourceGroupName                        
                        $azureSqlDatabaseServerPrimaryNameExists = Get-AzureSqlServer -ServerName $azureSqlDatabaseServerPrimaryName -ResourceGroupName $azureResourceGroupName -ErrorVariable azureSqlDatabaseServerPrimaryNameExistsErrors -ErrorAction SilentlyContinue                                                
                    }

                    if ($azureSqlDatabaseServerPrimaryNameExists.Count -gt 0)
                    {   
                        Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue                        
                        Deploy-DBSchema -ServerName $azureSqlDatabaseServerPrimaryName -DatabaseEdition "Basic" -UserName $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -ServerLocation $WTTEnvironmentPrimaryServerLocation -DatabaseName $AzureSqlDatabaseName            
                        Populate-DBSchema -ServerName $azureSqlDatabaseServerPrimaryName -Username $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -DatabaseName $AzureSqlDatabaseName                    
                    }
                                                            
                    if ($azureSqlDatabaseServerSecondaryNameExists.Count -eq 0)
                    {
                        Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
                        #Create Secondary Azure SQL Database Server if it doesn't already exist
                        New-WTTAzureSqlDatabaseServer -AzureSqlDatabaseServerName $azureSqlDatabaseServerSecondaryName -AzureSqlDatabaseServerLocation $wTTEnvironmentSecondaryServerLocation -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseServerVersion $AzureSqlDatabaseServerVersion -AzureSqlDatabaseServerResourceGroupName $azureResourceGroupName   
                        #Added from Mark's email after working with Audit team to address the bug
                        $azureSqlDatabaseServerSecondaryNameExists = Get-AzureSqlServer -ServerName $azureSqlDatabaseServerSecondaryName -ResourceGroupName $azureResourceGroupName -ErrorVariable azureSqlDatabaseServerSecondaryNameExists -ErrorAction SilentlyContinue                                 
                    }
                    
                    if ($WTTEnvironmentPrimaryServerLocation -notcontains "" -and $wTTEnvironmentSecondaryServerLocation -notcontains "")                 

                    {
                        if ($wTTEnvironmentApplicationName.Length -gt 15)
                        {
                            $azureSearchServiceName = $wTTEnvironmentApplicationName.Substring(0,15)
                        }
                        else
                        {
                            $azureSearchServiceName = $wTTEnvironmentApplicationName
                        }
                        Write-Host "### Creating Azure Search Service '$azureSearchServiceName' in Primary Datacenter Region '$WTTEnvironmentPrimaryServerLocation' if it doesn't already exist. ###" -foregroundcolor "yellow"
                        
                        if($AzureActiveDirectoryTenantName -eq "")
                        {
                            $azureSearchService = New-WTTAzureSearchService -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -WTTEnvironmentResourceGroupName $azureResourceGroupName -AzureSearchServiceLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseName $AzureSqlDatabaseName
                            if($azureSearchService.Count -eq 0)
                            {
                                Start-Sleep -s 30
                                $azureSearchService = New-WTTAzureSearchService -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -WTTEnvironmentResourceGroupName $azureResourceGroupName -AzureSearchServiceLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseName $AzureSqlDatabaseName
                            }
                        }
                        else
                        {
                            $azureSearchService = New-WTTAzureSearchService -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -WTTEnvironmentResourceGroupName $azureResourceGroupName -AzureSearchServiceLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseName $AzureSqlDatabaseName -AzureActiveDirectoryTenantName $AzureActiveDirectoryTenantName
                            if($azureSearchService.Count -eq 0)
                            {
                                Start-Sleep -s 30
                                $azureSearchService = New-WTTAzureSearchService -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -WTTEnvironmentResourceGroupName $azureResourceGroupName -AzureSearchServiceLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseName $AzureSqlDatabaseName -AzureActiveDirectoryTenantName $AzureActiveDirectoryTenantName
                            }
                        }
                        
                        if($azureSearchService.Count -eq 1)
                        {
                            $searchServicePrimaryManagementKey = $azureSearchService
                            
                            Write-Host "### Setting the appSettings Values in the web.config for the '$azureWebSitePrimaryWebDeployPackageName' Azure WebSites WebDeploy Package. ###" -foregroundcolor "yellow"
                            Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -AzureWebSiteWebDeployPackagePath $azureWebSitePrimaryWebDeployPackagePath -SearchServicePrimaryManagementKey $searchServicePrimaryManagementKey
                            Write-Host "### Setting the appSettings Values in the web.config for the '$azureWebSiteSecondaryWebDeployPackageName' Azure WebSites WebDeploy Package. ###" -foregroundcolor "yellow"
                            Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -AzureWebSiteWebDeployPackagePath $azureWebSiteSecondaryWebDeployPackagePath -SearchServicePrimaryManagementKey $searchServicePrimaryManagementKey -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerSecondaryName -AzureSqlDatabaseServerSecondaryName $azureSqlDatabaseServerPrimaryName
                        }

                        Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
                        Write-Host "### Creating Primary App Service Plan '$azureSqlDatabaseServerPrimaryName' if it doesn't already exist. ###" -foregroundcolor "yellow"
                        $null = New-AzureAppServicePlan -Name $azureSqlDatabaseServerPrimaryName -Location $WTTEnvironmentPrimaryServerLocation -Sku Standard -ResourceGroupName $azureResourceGroupName
                        Write-Host "### Creating Secondary App Service Plan '$azureSqlDatabaseServerSecondaryName' if it doesn't already exist. ###" -foregroundcolor "yellow"
                        $null = New-AzureAppServicePlan -Name $azureSqlDatabaseServerSecondaryName -Location $wTTEnvironmentSecondaryServerLocation -Sku Standard -ResourceGroupName $azureResourceGroupName

                        Write-Host "### Creating a Primary Web App '$azureSqlDatabaseServerPrimaryName' in Primary App Service Plan '$azureSqlDatabaseServerPrimaryName' if it doesn't already exist. ###" -foregroundcolor "yellow"
                        $null = New-AzureWebApp -Location $WTTEnvironmentPrimaryServerLocation -AppServicePlan $azureSqlDatabaseServerPrimaryName -ResourceGroupName $azureResourceGroupName -Name $azureSqlDatabaseServerPrimaryName
                        Write-Host "### Creating a Secondary Web App '$azureSqlDatabaseServerSecondaryName' in Secondary App Service Plan '$azureSqlDatabaseServerSecondaryName' if it doesn't already exist. ###" -foregroundcolor "yellow"
                        $null = New-AzureWebApp -Location $wTTEnvironmentSecondaryServerLocation -AppServicePlan $azureSqlDatabaseServerSecondaryName -ResourceGroupName $azureResourceGroupName -Name $azureSqlDatabaseServerSecondaryName

                        Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue
                                                
                        Write-Host "### Deploying Primary WebDeploy Package '$azureWebSitePrimaryWebDeployPackageName' to Primary Web App '$azureSqlDatabaseServerPrimaryName'. ###" -foregroundcolor "yellow"
                        Publish-AzureWebsiteProject -Name $azureSqlDatabaseServerPrimaryName -Package $azureWebSitePrimaryWebDeployPackagePath
                    
                        Write-Host "### Deploying Secondary WebDeploy Package '$azureWebSiteSecondaryWebDeployPackageName' to Secondary Web App '$azureSqlDatabaseServerSecondaryName'. ###" -foregroundcolor "yellow"
                        Publish-AzureWebsiteProject -Name $azureSqlDatabaseServerSecondaryName -Package $azureWebSiteSecondaryWebDeployPackagePath
                    
                    
                        #Create Traffic Manager Profile
                        #ARM - currently having an issue with the ARM preview cmdlets.  Working ps1s are in the 2.2 folder
                        #New-WTTAzureTrafficManagerProfile -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName -AzureTrafficManagerResourceGroupName $azureResourceGroupName
                        #ASM
                        New-WTTAzureTrafficManagerProfile -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName

                        #Add Azure WebSite Endpoints to Traffic Manager Profile 
                        Add-WTTAzureTrafficManagerEndpoint -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName -AzureWebSiteName $azureSqlDatabaseServerPrimaryName -AzureTrafficManagerEndpointStatus "Enabled"
                        Add-WTTAzureTrafficManagerEndpoint -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName -AzureWebSiteName $azureSqlDatabaseServerSecondaryName -AzureTrafficManagerEndpointStatus "Disabled"

                        Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
                        #Enable Auditing on Azure SQL Database Server
                        #Appears to be a name resolution issue if Auditing is enabled, as Azure Search will not redirect to the database server
                        if ($azureSqlDatabaseServerPrimaryNameExists.Count -gt 0)
                        {   
                            #$setPrimaryAzureSqlDatabaseServerAuditingPolicy = Set-AzureSqlDatabaseServerAuditingPolicy -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlDatabaseServerPrimaryName -StorageAccountName $azureStorageAccountName -EventType PlainSQL_Success, PlainSQL_Failure, ParameterizedSQL_Success, ParameterizedSQL_Failure, StoredProcedure_Success, StoredProcedure_Success -WarningVariable null -WarningAction SilentlyContinue                                                 
                        }
                        if ($azureSqlDatabaseServerSecondaryNameExists.Count -gt 0)
                        {
                            #$setSecondaryAzureSqlDatabaseServerAuditingPolicy = Set-AzureSqlDatabaseServerAuditingPolicy -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlDatabaseServerSecondaryName -StorageAccountName $azureStorageAccountName -EventType PlainSQL_Success, PlainSQL_Failure, ParameterizedSQL_Success, ParameterizedSQL_Failure, StoredProcedure_Success, StoredProcedure_Success -WarningVariable null -WarningAction SilentlyContinue
                        }
                    }                    
                    
                }

                else
                {
                    ### Error if both ASM and ARM aren't provisioned ###
                    Write-Host "### Error: Both Azure Service Model (ASM) and Azure Resource Model (ARM) need to be provisioned. ###" -foregroundcolor "red"
                    Write-Host "### You can run: (Get-AzureSubscription -Default).SupportedModes to verify which is/isn't provisioned. ###" -foregroundcolor "red"
                    Write-Host "### Please contact Microsoft Support to have them troubleshoot further. ###" -foregroundcolor "red"
                }
            }
            else
            {
                ### Error if installed Azure PowerShell Version is older than minimum required version ###
                Write-Host "### Error: Installed Azure PowerShell Version is older than 0.9.7.  Please install the latest version from: ###" -foregroundcolor "red"
                Write-Host "### http://azure.microsoft.com/en-us/downloads/, under Command-line tools, under Windows PowerShell, click Install ###" -foregroundcolor "red"
            }
            
        }
        Catch
        {
	        Write-Error "Error: $Error "
        }  	    
   }
 }
 
#Check Installed Azure PowerShell Version
# Bitwise left shift
function Lsh([UInt32] $n, [Byte] $bits) 
    {
        $n * [Math]::Pow(2, $bits)
    }

# Returns a version number "a.b.c.d" as a two-element numeric
# array. The first array element is the most significant 32 bits,
# and the second element is the least significant 32 bits.
function GetVersionStringAsArray([String] $version) 
{
    $parts = $version.Split(".")
    if ($parts.Count -lt 4) 
    {
        for ($n = $parts.Count; $n -lt 4; $n++) 
        {
            $parts += "0"
        }
    }
    [UInt32] ((Lsh $parts[0] 16) + $parts[1])
    [UInt32] ((Lsh $parts[2] 16) + $parts[3])
}

# Compares two version numbers "a.b.c.d". If $version1 < $version2,
# returns -1. If $version1 = $version2, returns 0. If
# $version1 > $version2, returns 1.
function CheckInstalledPowerShellVersion() 
    {
        Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue

        $installedVersion = ((Get-Module Azure).Version.Major -as [string]) +'.'+ ((Get-Module Azure).Version.Minor -as [string]) +'.'+ ((Get-Module Azure).Version.Build -as [string])        
        $minimumRequiredVersion = '0.9.7'        
        $ver1 = GetVersionStringAsArray $installedVersion
        $ver2 = GetVersionStringAsArray $minimumRequiredVersion
        if ($ver1[0] -lt $ver2[0]) 
        {
            $out = -1
        }
        elseif ($ver1[0] -eq $ver2[0]) 
        {
            if ($ver1[1] -lt $ver2[1]) 
            {
                $out = -1
            }
            elseif ($ver1[1] -eq $ver2[1]) 
            {
                $out = 0
            }
            else 
            {
                $out = 1
            }
        }
        else 
            {
                $out = 1
            }
        return $out
}