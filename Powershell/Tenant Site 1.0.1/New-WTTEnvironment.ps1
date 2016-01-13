<#
.Synopsis
    WingtipTickets (WTT) Demo Environment.
 .DESCRIPTION
    This script is used to create a new WingtipTickets (WTT) Demo Environment.
 .EXAMPLE
    New-WTTEnvironment 
WingTipTickets PowerShell Version 2.5 - Azure Data Warehouse
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
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'EastUS', 'WestUS', 'SouthCentralUS', 'NorthCentralUS', 'CentralUS', 'EastAsia', 'WestEurope', 'EastUS2', 'JapanEast', 'JapanWest', 'BrazilSouth', 'NorthEurope', 'SoutheastAsia', 'AustraliaEast', 'AustraliaSoutheast')]
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
        $AzureActiveDirectoryTenantName,
		
		#Mode of deployment for ADF
		[Parameter()]
		[Alias("mode")]
		[string]
		$global:mode,
		
		#Azure ADF SQL Database Server Name
        [Parameter()]
		[Alias("adfsqlservername")]
        [String]$global:sqlserverName,

		#Azure ADF SQL Server Login
        [Parameter()]
        [Alias("sqllogin")]
        [string]$global:sqlServerLogin = 'mylogin',
        
		#Azure ADF SQL Server User Password
        [Parameter()]
        [Alias("sqlpassword")]
        [string]$global:sqlServerPassword = 'pass@word1',
        
        #Azure ADF SQL Database Name
        [Parameter(Mandatory=$false)]
        [Alias("sqldbname")]
        [String]$global:sqlDBName,

        # Path to Azure ADF Web Site WebDeploy Package
        [Parameter(Mandatory = $false)]
        [Alias("ADFWebSiteDeployPackagePath")] 
        [String]$azureADFWebSiteWebDeployPackagePath
		
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

        if($AzureSqlDWDatabaseName -eq "")
        {
            $AzureSqlDWDatabaseName = "CustomerDW"
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
		$azureDocumentDbName = $wTTEnvironmentApplicationName
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
            Write-Host "### Checking whether installed Azure PowerShell Version is at least 1.0.1. ###" -foregroundcolor "yellow"

            $installedAzurePowerShellVersion = CheckInstalledPowerShellVersion
            if ($installedAzurePowerShellVersion -gt 0)
            {
                Write-Host "### Installed Azure PowerShell Version is at least 1.0.1. ###" -foregroundcolor "yellow"
                 
                    Write-Host "### Unblocking all PowerShell Scripts in the '$localPath' folder. ###" -foregroundcolor "yellow"
                    # Unblock Files
                    Get-ChildItem -Path $localPath -Filter *.ps1 | Unblock-File                               

                    Write-Host "### Loading all PowerShell Scripts in the '$localPath' folder. ###" -foregroundcolor "yellow"
                    # Load (DotSource) Scripts
                    Get-ChildItem -Path $localPath -Filter *.ps1 | ForEach { . $_.FullName }
                    
                    #Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
                    Write-Host "### Checking whether Azure Resource Group '$azureResourceGroupName' already exists. ###" -foregroundcolor "yellow"
                    $azureResourceGroupNameExists = Get-AzureRMResourceGroup -Name $azureResourceGroupName -ErrorVariable azureResourceGroupNameExistsErrors -ErrorAction SilentlyContinue
                    If($azureResourceGroupNameExists.Count -gt 0) 
                    {
                        Write-Host "### Azure Resource Group '$azureResourceGroupName' exists. ###" -foregroundcolor "yellow"

                        ### Check if Primary Azure SQL Database Server Exists ###
                        Write-Host "### Checking whether Primary Azure SQL Database Server '$azureSqlDatabaseServerPrimaryName' already exists. ###" -foregroundcolor "yellow"
                        $azureSqlDatabaseServerPrimaryNameExists = Get-AzureRMSqlServer -ServerName $azureSqlDatabaseServerPrimaryName -ResourceGroupName $azureResourceGroupName -ErrorVariable azureSqlDatabaseServerPrimaryNameExistsErrors -ErrorAction SilentlyContinue
                        
                        ### Check if Secondary Azure SQL Database Server Exists ###
                        Write-Host "### Checking whether Secondary Azure SQL Database Server '$azureSqlDatabaseServerSecondaryName' already exists. ###" -foregroundcolor "yellow"
                        $azureSqlDatabaseServerSecondaryNameExists = Get-AzureRMSqlServer -ServerName $azureSqlDatabaseServerSecondaryName -ResourceGroupName $azureResourceGroupName -ErrorVariable azureSqlDatabaseServerSecondaryNameExistsErrors -ErrorAction SilentlyContinue
                        
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
                            $null = Remove-AzureRMResourceGroup -Name $azureResourceGroupName -Force -PassThru
                            $azureResourceGroupNameExists = $null
                            $azureSqlDatabaseServerPrimaryNameExists = $null
                            $azureSqlDatabaseServerSecondaryNameExists = $null
                        }
                        elseif($azureSqlDatabaseServerPrimaryNameExists.Count -eq 0 -and $azureSqlDatabaseServerSecondaryNameExists.Count -gt 0) 
                        {
                            Write-Host "### Primary Azure SQL Database Server '$azureSqlDatabaseServerPrimaryName' doesn't exists. ###" -foregroundcolor "yellow"
                            Write-Host "### Secondary Azure SQL Database Server '$azureSqlDatabaseServerSecondaryName' already exists ###" -foregroundcolor "yellow"
                            Write-Host "### Removing '$azureResourceGroupName' Resource Group and all related resources. ###" -foregroundcolor "yellow"    
                            $null = Remove-AzureRMResourceGroup -Name $azureResourceGroupName -Force -PassThru
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
                                        

                    #Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
					#Remove Switch-AzureMode
                                
                    # Create Azure Resource Group
                    if ($azureResourceGroupNameExists.Count -eq 0)
                    {
                        New-WTTAzureResourceGroup -AzureResourceGroupName $azureResourceGroupName -AzureResourceGroupLocation $WTTEnvironmentPrimaryServerLocation
                        Start-Sleep -Seconds 10
                    }
            
                    # Create Storage Account                    
                    New-WTTAzureStorageAccount -AzureStorageAccountResourceGroupName $azureResourceGroupName -AzureStorageAccountName $azureStorageAccountName -AzureStorageAccountType "Standard_GRS" -AzureStorageLocation $WTTEnvironmentPrimaryServerLocation
                    Start-Sleep -Seconds 30
                    #Create DocumentDB location based off the closest available location.
					#switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
					#Remove Switch-AzureMode
                    Start-Sleep -Seconds 30    

                    $WTTDocumentDbLocation = Switch ($WTTEnvironmentPrimaryServerLocation)
                           {
                              'West US' {'West US'}
                              'North Europe' {'North Europe'}
                              'West Europe' {'West Europe'}
                              'East US' {'East US'}
                              'North Central US' {'East US'}
                              'EastUS2' {'East US'}
                              'South Central US' {'East US'}
                              'Central US' {'East US'}
                              'North Central US' {'East US'}
                              'Brazil South' {'East US'}
                              'Southeast Asia' {'Southeast Asia'}
                              'Australia Southeast' {'Southeast Asia'}
                              'Australia East' {'Southeast Asia'}
                              'East Asia' {'East Asia'}
                              'Japan East' {'East Asia'}
                              'Japan West' {'East Asia'}
                              default {'West US'}
                            }
                        
                    #Creat DocumentDB     						
					write-Host "### Creating DocumentDB if it doesn't already exist. ###" -foregroundcolor "yellow"
					if($AzureActiveDirectoryTenantName -eq "")
                      {
                          $azureDocumentDBService = New-WTTAzureDocumentDb -WTTResourceGroupName $azureResourceGroupName -WTTDocumentDbName $azureDocumentDbName -WTTDocumentDbLocation $WTTDocumentDbLocation
                          if($azureDocumentDBService.Count -eq 0)
                          {
                              Start-Sleep -s 30
                              $azureDocuemtnDBService = New-WTTAzureDocumentDb -WTTResourceGroupName $azureResourceGroupName -WTTDocumentDbName $azureDocumentDbName -WTTDocumentDbLocation $WTTDocumentDbLocation
                              $azureDocumentDBService
                          }
                      }
                    else
                      {
                          $azureDocumentDBService = New-WTTAzureDocumentDb -WTTResourceGroupName $azureResourceGroupName -WTTDocumentDbName $azureDocumentDbName -WTTDocumentDbLocation $WTTDocumentDbLocation -AzureActiveDirectoryTenantName $AzureActiveDirectoryTenantName
                          if($azureSearchService.Count -eq 0)
                          {
                              Start-Sleep -s 30
                              $azureDocumentDBService = New-WTTAzureDocumentDb -WTTResourceGroupName $azureResourceGroupName -WTTDocumentDbName $azureDocumentDbName -WTTDocumentDbLocation $WTTDocumentDbLocation -AzureActiveDirectoryTenantName $AzureActiveDirectoryTenantName
                              $azureDocumentDBService

                          }
                       } 
                    Start-sleep -Seconds 30 
                    # If a WTTEnvironmentPrimaryServerLocation value was specified, Get Secondary Server Datacenter Location
                    if ($wTTEnvironmentSecondaryServerLocation -eq "")
                    {                        
                        $wTTEnvironmentSecondaryServerLocation = (Get-AzureRMStorageAccount -ResourceGroupName $azureResourceGroupName -StorageAccountName $azureStorageAccountName).SecondaryLocation                     
                    }
                                        
                    if ($azureSqlDatabaseServerPrimaryNameExists.Count -eq 0)
                    {
                        # Create Primary Azure SQL Database Server if it doesn't already exist
                        New-WTTAzureSqlDatabaseServer -AzureSqlDatabaseServerName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseServerVersion $AzureSqlDatabaseServerVersion -AzureSqlDatabaseServerResourceGroupName $azureResourceGroupName                        
                        Start-Sleep -Seconds 30
                        $azureSqlDatabaseServerPrimaryNameExists = Get-AzureRMSqlServer -ServerName $azureSqlDatabaseServerPrimaryName -ResourceGroupName $azureResourceGroupName -ErrorVariable azureSqlDatabaseServerPrimaryNameExistsErrors -ErrorAction SilentlyContinue                                                
                    }

                    if ($azureSqlDatabaseServerPrimaryNameExists.Count -gt 0)
                    {   
                        Deploy-DBSchema -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -ServerName $azureSqlDatabaseServerPrimaryName -DatabaseEdition "Basic" -UserName $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -ServerLocation $WTTEnvironmentPrimaryServerLocation -DatabaseName $AzureSqlDatabaseName            
                        Populate-DBSchema -ServerName $azureSqlDatabaseServerPrimaryName -Username $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -DatabaseName $AzureSqlDatabaseName                    
                    }
                                                            
                    if ($azureSqlDatabaseServerSecondaryNameExists.Count -eq 0)
                    {
                        #Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
						#Remove Switch-AzureMode
                        # Create Secondary Azure SQL Database Server if it doesn't already exist
                        New-WTTAzureSqlDatabaseServer -AzureSqlDatabaseServerName $azureSqlDatabaseServerSecondaryName -AzureSqlDatabaseServerLocation $wTTEnvironmentSecondaryServerLocation -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseServerVersion $AzureSqlDatabaseServerVersion -AzureSqlDatabaseServerResourceGroupName $azureResourceGroupName   
                        Start-Sleep -s 30
                        # Added from Mark's email after working with Audit team to address the bug
                        $azureSqlDatabaseServerSecondaryNameExists = Get-AzureRMSqlServer -ServerName $azureSqlDatabaseServerSecondaryName -ResourceGroupName $azureResourceGroupName -ErrorVariable azureSqlDatabaseServerSecondaryNameExists -ErrorAction SilentlyContinue                                 
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
                                Start-Sleep -s 30
                            }
                        }
                        else
                        {
                            $azureSearchService = New-WTTAzureSearchService -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -WTTEnvironmentResourceGroupName $azureResourceGroupName -AzureSearchServiceLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseName $AzureSqlDatabaseName -AzureActiveDirectoryTenantName $AzureActiveDirectoryTenantName
                            if($azureSearchService.Count -eq 0)
                            {
                                Start-Sleep -s 30
                                $azureSearchService = New-WTTAzureSearchService -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -WTTEnvironmentResourceGroupName $azureResourceGroupName -AzureSearchServiceLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseName $AzureSqlDatabaseName -AzureActiveDirectoryTenantName $AzureActiveDirectoryTenantName
                                Start-Sleep -s 30
                            }
                        }
                        
                        Write-Host "### Azure Search Service in Primary Datacenter Region '$WTTEnvironmentPrimaryServerLocation' successfully deployed" -ForegroundColor Green
				
						# Create Service Plans
                        Write-Host "### Creating Primary App Service Plan '$azureSqlDatabaseServerPrimaryName' if it doesn't already exist. ###" -foregroundcolor "yellow"
                        #$null = New-AzureAppServicePlan -Name $azureSqlDatabaseServerPrimaryName -Location $WTTEnvironmentPrimaryServerLocation -Sku Standard -ResourceGroupName $azureResourceGroupName
                        $null = New-AzureRMAppServicePlan -Name $azureSqlDatabaseServerPrimaryName -Location $WTTEnvironmentPrimaryServerLocation -Tier Standard -ResourceGroupName $azureResourceGroupName
                        Write-Host "### Creating Secondary App Service Plan '$azureSqlDatabaseServerSecondaryName' if it doesn't already exist. ###" -foregroundcolor "yellow"
                        $null = New-AzureRMAppServicePlan -Name $azureSqlDatabaseServerSecondaryName -Location $wTTEnvironmentSecondaryServerLocation -Tier Standard -ResourceGroupName $azureResourceGroupName

						# Create Web Applications
                        Write-Host "### Creating a Primary Web App '$azureSqlDatabaseServerPrimaryName' in Primary App Service Plan '$azureSqlDatabaseServerPrimaryName' if it doesn't already exist. ###" -foregroundcolor "yellow"
                        $null = New-AzureRMWebApp -Location $WTTEnvironmentPrimaryServerLocation -AppServicePlan $azureSqlDatabaseServerPrimaryName -ResourceGroupName $azureResourceGroupName -Name $azureSqlDatabaseServerPrimaryName
                        Start-Sleep -Seconds 10
                        Write-Host "### Creating a Secondary Web App '$azureSqlDatabaseServerSecondaryName' in Secondary App Service Plan '$azureSqlDatabaseServerSecondaryName' if it doesn't already exist. ###" -foregroundcolor "yellow"
                        $null = New-AzureRMWebApp -Location $wTTEnvironmentSecondaryServerLocation -AppServicePlan $azureSqlDatabaseServerSecondaryName -ResourceGroupName $azureResourceGroupName -Name $azureSqlDatabaseServerSecondaryName
                        Start-Sleep -Seconds 10

						# Deploy Web Applications
                        #Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue
						#Remove Switch-AzureMode
                        
                        start-sleep -s 30
                                                
                        Write-Host "### Deploying Primary WebDeploy Package '$azureWebSitePrimaryWebDeployPackageName' to Primary Web App '$azureSqlDatabaseServerPrimaryName'. ###" -foregroundcolor "yellow"
                        Publish-AzureWebsiteProject -Name $azureSqlDatabaseServerPrimaryName -Package $azureWebSitePrimaryWebDeployPackagePath
                    
                        Start-Sleep -s 10

                        Write-Host "### Deploying Secondary WebDeploy Package '$azureWebSiteSecondaryWebDeployPackageName' to Secondary Web App '$azureSqlDatabaseServerSecondaryName'. ###" -foregroundcolor "yellow"
                        Publish-AzureWebsiteProject -Name $azureSqlDatabaseServerSecondaryName -Package $azureWebSiteSecondaryWebDeployPackagePath
                        
                        # Create Traffic Manager Profile
                        # ARM - currently having an issue with the ARM preview cmdlets.  Working ps1s are in the 2.2 folder
                        # New-WTTAzureTrafficManagerProfile -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName -AzureTrafficManagerResourceGroupName $azureResourceGroupName
                        # ASM
                        New-WTTAzureTrafficManagerProfile -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName

                        # Add Azure WebSite Endpoints to Traffic Manager Profile 
                        Add-WTTAzureTrafficManagerEndpoint -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName -AzureWebSiteName $azureSqlDatabaseServerPrimaryName -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -AzureTrafficManagerEndpointStatus "Enabled"
                        Add-WTTAzureTrafficManagerEndpoint -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName -AzureWebSiteName $azureSqlDatabaseServerSecondaryName -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -AzureTrafficManagerEndpointStatus "Disabled"

                        #Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
						#Remove Switch-AzureMode
                        # Enable Auditing on Azure SQL Database Server
                        # Appears to be a name resolution issue if Auditing is enabled, as Azure Search will not redirect to the database server
                        if ($azureSqlDatabaseServerPrimaryNameExists.Count -gt 0)
                        {   
                            #$setPrimaryAzureSqlDatabaseServerAuditingPolicy = Set-AzureSqlDatabaseServerAuditingPolicy -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlDatabaseServerPrimaryName -StorageAccountName $azureStorageAccountName -TableIdentifier "wtt" -EventType PlainSQL_Success, PlainSQL_Failure, ParameterizedSQL_Success, ParameterizedSQL_Failure, StoredProcedure_Success, StoredProcedure_Success -WarningVariable null -WarningAction SilentlyContinue                                                 
                            $setPrimaryAzureSqlDatabaseServerAuditingPolicy = Set-AzureRmSqlDatabaseServerAuditingPolicy -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlDatabaseServerPrimaryName -StorageAccountName $azureStorageAccountName -TableIdentifier "wtt" -EventType PlainSQL_Success, PlainSQL_Failure, ParameterizedSQL_Success, ParameterizedSQL_Failure, StoredProcedure_Success, StoredProcedure_Success -WarningVariable null -WarningAction SilentlyContinue                                                 
                        }
                        if ($azureSqlDatabaseServerSecondaryNameExists.Count -gt 0)
                        {
                            #$setSecondaryAzureSqlDatabaseServerAuditingPolicy = Set-AzureSqlDatabaseServerAuditingPolicy -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlDatabaseServerSecondaryName -StorageAccountName $azureStorageAccountName -TableIdentifier "wtt" -EventType PlainSQL_Success, PlainSQL_Failure, ParameterizedSQL_Success, ParameterizedSQL_Failure, StoredProcedure_Success, StoredProcedure_Success -WarningVariable null -WarningAction SilentlyContinue
                            $setSecondaryAzureSqlDatabaseServerAuditingPolicy = Set-AzureRmSqlDatabaseServerAuditingPolicy -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlDatabaseServerSecondaryName -StorageAccountName $azureStorageAccountName -TableIdentifier "wtt" -EventType PlainSQL_Success, PlainSQL_Failure, ParameterizedSQL_Success, ParameterizedSQL_Failure, StoredProcedure_Success, StoredProcedure_Success -WarningVariable null -WarningAction SilentlyContinue
                        }
                    } 
                    
                    #Deploy Azure Data Warehouse on the primary database server. This may run between 2-3 hours.
                    <#if ($azureSqlDatabaseServerPrimaryNameExists.Count -gt 0)
                    {   
                        Deploy-WTTAzureDWDatabase -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -ServerName $azureSqlDatabaseServerPrimaryName -ServerLocation $WTTEnvironmentPrimaryServerLocation -DatabaseEdition "DataWarehouse" -UserName $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -DWDatabaseName $AzureSqlDWDatabaseName
                    }#>  

                        #Deploy ADF environment
						Write-Host "###Deploying Azure Data Factory demo. There will be several prompts during the script.###" -ForegroundColor Yellow
		                New-WTTADFEnvironment -Mode deploy -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -azureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName
						
                        Start-Sleep -Seconds 30
						  
                        #set the ADF site URL in the WTT web.config
						#Set-WTTEnvironmentWebConfigDay2                 

                        # Set the Application Settings
                        if($azureSearchService.Count -eq 1)
                        {
                            $searchServicePrimaryManagementKey = $azureSearchService
                            $documentDbPrimaryKey = Import-Clixml .\docdbkey.xml
                            
                            Write-Host "### Setting the appSettings Values in the web.config for the '$azureWebSitePrimaryWebDeployPackageName' Azure WebSites WebDeploy Package. ###" -foregroundcolor "yellow"
                            Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -AzureWebSiteWebDeployPackagePath $azureWebSitePrimaryWebDeployPackagePath -SearchServicePrimaryManagementKey $searchServicePrimaryManagementKey -azureDocumentDbName $azureDocumentDbName -documentDbPrimaryKey  $documentDbPrimaryKey
                            Write-Host "### Setting the appSettings Values in the web.config for the '$azureWebSiteSecondaryWebDeployPackageName' Azure WebSites WebDeploy Package. ###" -foregroundcolor "yellow"
                            Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -AzureWebSiteWebDeployPackagePath $azureWebSiteSecondaryWebDeployPackagePath -SearchServicePrimaryManagementKey $searchServicePrimaryManagementKey -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerSecondaryName -AzureSqlDatabaseServerSecondaryName $azureSqlDatabaseServerPrimaryName -azureDocumentDbName $azureDocumentDbName -documentDbPrimaryKey  $documentDbPrimaryKey
                        }
                    
                
                }

            
            else
            {
                ### Error if installed Azure PowerShell Version is older than minimum required version ###
                Write-Host "### Error: Installed Azure PowerShell Version is older than 1.0.1.  Please install the latest version from: ###" -foregroundcolor "red"
                Write-Host "### http://azure.microsoft.com/en-us/downloads/, under Command-line tools, under Windows PowerShell, click Install ###" -foregroundcolor "red"
            }
            
      
                        						
    	}			
        Catch
        {
	        Write-Error "Error: $Error "
        }  	    
	 }
}
<#
# Check Installed Azure PowerShell Version
# Bitwise left shift
function Lsh([UInt32] $n, [Byte] $bits) 
    {
        $n * [Math]::Pow(1, $bits)
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

        $installedVersion = ((Get-Module Azure*).Version.Major -as [string]) +'.'+ ((Get-Module Azure*).Version.Minor -as [string]) +'.'+ ((Get-Module Azure*).Version.Build -as [string])    
        $minimumRequiredVersion = '1.0.1'        
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
}#>

function CheckInstalledPowerShellVersion() 
    {

        $installedVersion = (Get-Module AzureRM.Profile).Version
        $minimumRequiredVersion = '1.0.1'        
        $ver1 = ($installedVersion)
        $ver2 = ($minimumRequiredVersion)
        if ($ver1 -lt $ver2) 
        {
            $out = -1
        }
        else 
            {
                $out = 1
            }
        return $out
}