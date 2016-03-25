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
		# WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$WTTEnvironmentApplicationName,

		# Primary Server Location
		[Parameter(Mandatory=$false, HelpMessage="Please specify the primary location for your WTT Environment ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
		[ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'EastUS', 'WestUS', 'SouthCentralUS', 'NorthCentralUS', 'CentralUS', 'EastAsia', 'WestEurope', 'EastUS2', 'JapanEast', 'JapanWest', 'BrazilSouth', 'NorthEurope', 'SoutheastAsia', 'AustraliaEast', 'AustraliaSoutheast')]
		[String]
		$WTTEnvironmentPrimaryServerLocation,

		# Azure SQL Database Server Administrator User Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseServerAdministratorUserName,

		# Azure SQL Database Server Adminstrator Password
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseServerAdministratorPassword,

		# Azure SQL Database Server Version
		[Parameter(Mandatory=$false, HelpMessage="Please specify the Azure SQL Database Server Version ('2.0', '12.0')?")]
		[ValidateSet('2.0', '12.0')]
		[String]
		$AzureSqlDatabaseServerVersion,

		# Azure Tenant SQL Database Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseName,

		# Azure DataWarehouse SQL Database Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDWDatabaseName,

		# Path to Azure Web Site WebDeploy Packages
		[Parameter(Mandatory = $false)] 
		[String]$AzureWebSiteWebDeployPackagePath, 

		# Primary Azure Web Site WebDeploy Package Name
		[Parameter(Mandatory = $false)] 
		[String]$AzureWebSitePrimaryWebDeployPackageName,

		# Secondary Azure Web Site WebDeploy Package Name
		[Parameter(Mandatory = $false)] 
		[String]$AzureWebSiteSecondaryWebDeployPackageName,

		# Azure Active Directory Tenant Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureActiveDirectoryTenantName,

		# Mode of deployment for ADF
		[Parameter()]
		[Alias("mode")]
		[string]
		$global:mode,

		# Azure ADF SQL Database Server Name
		[Parameter()]
		[Alias("adfsqlservername")]
		[String]$global:sqlserverName,

		# Azure ADF SQL Server Login
		[Parameter()]
		[Alias("sqllogin")]
		[string]$global:sqlServerLogin = 'mylogin',

		# Azure ADF SQL Server User Password
		[Parameter()]
		[Alias("sqlpassword")]
		[string]$global:sqlServerPassword = 'pass@word1',

		# Azure ADF SQL Database Name
		[Parameter(Mandatory=$false)]
		[Alias("sqldbname")]
		[String]$global:sqlDBName,

		# Path to Azure ADF Web Site WebDeploy Package
		[Parameter(Mandatory = $false)]
		[Alias("ADFWebSiteDeployPackagePath")] 
		[String]$azureADFWebSiteWebDeployPackagePath,

        #This parameter is used by deploy-wttenvironment.ps1
		[Parameter(Mandatory = $false)]
        [string]
		$deployADF,

        #This parameter is used by deploy-wttenvironment.ps1
		[Parameter(Mandatory = $false)]
        [string]
		$deployDW,

        #This parameter is used by deploy-wttenvironment.ps1
		[Parameter(Mandatory = $false)]
		[string]
		$installedAzurePowerShellVersion
	)

	Process
	{
		# Clear Screen and Error log
		Clear
		$Error.Clear()

		# Print Heading
		WriteLine("==============================================")
		WriteLine("Deploying WingTipTickets to Azure             ")
		WriteLine("==============================================")
		LineBreak

		# Setup Parameter Defaults
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
			# Print Script Path
			WriteLine("Script Path: '$localPath'")
			LineBreak

			# Set Defaults
			$azurePrimarySqlDatabaseServer = $null
			$azureSecondarySqlDatabaseServer = $null

			# Check installed PowerShell Version
			WriteLabel("Checking for Azure PowerShell Version 1.0.1 or later")
			if($installedAzurePowerShellVersion -lt 1)
			{
	            $module = Get-Module AzureRM.profile
	            $installedAzurePowerShellVersion = CheckInstalledPowerShell $module
	            if ($installedAzurePowerShellVersion -gt 0)
	            {
		            WriteValue("Done")
	            }
	            else
	            {
		            WriteValue("Failed")
		            WriteError("Make sure that you are signed in and that PowerShell is not older than version 1.0.1.")
		            WriteError("Please install from: http://azure.microsoft.com/en-us/downloads/, under Command-line tools, under Windows PowerShell, click Install")
		            break
	            }
			}
			# Silence Verbose Output
			WriteLabel("Silencing Verbose Output")
			$global:VerbosePreference = "SilentlyContinue"
			WriteValue("Done")

			# Unblock Script Files
			WriteLabel("Unblocking Scripts")
			Get-ChildItem -Path $localPath -Filter *.ps1 | Unblock-File
			WriteValue("Done")

			# Load Script Files
			WriteLabel("Loading Scripts")
			Get-ChildItem -Path $localPath -Filter *.ps1 | ForEach { . $_.FullName }
			WriteValue("Done")

			# Auto Find Location if not specified
			if ($WTTEnvironmentPrimaryServerLocation -eq "")
			{
				LineBreak
				WriteLine("Finding SQL Database Server capable region")

				if($AzureActiveDirectoryTenantName -eq "")
				{
					$azureSqlDatabaseServerV12RegionAvailability = Get-WTTSqlDatabaseServerV12RegionAvailability -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName
				}

				# Location Found
				if ($azureSqlDatabaseServerV12RegionAvailability.Count -eq 2)
				{
					$WTTEnvironmentPrimaryServerLocation = $azureSqlDatabaseServerV12RegionAvailability[0]
					$wTTEnvironmentSecondaryServerLocation = $azureSqlDatabaseServerV12RegionAvailability[1]
					
					WriteLabel("Primary Datacenter Region")
					WriteValue($WTTEnvironmentPrimaryServerLocation)
					
					WriteLabel("Secondary Datacenter Region")
					WriteValue($WTTEnvironmentSecondaryServerLocation)
				}

				# Location not Found
				else
				{
					if ($azureSqlDatabaseServerV12RegionAvailability.Count -ge 0)
					{
						$azureSqlDatabaseServerV12RegionAvailability[0]
						$azureSqlDatabaseServerV12RegionAvailability[1]
					}
					
					WriteError("A matching Primary and Secondary Datacenter Region that support Azure SQL Database Server version 12.0 could not be found for your subscription, please try a different subscription.")
					break
				}
			}

			# Find Resource Group
			LineBreak
			WriteLabel("Checking for Resource Group '$azureResourceGroupName'")
			$azureResourceGroupNameExists = (Find-AzureRMResourceGroup).Name -contains $azureResourceGroupName

			# Create Resource Group
			if ($azureResourceGroupNameExists -eq $true)
			{
				WriteValue("Found")
			}
			else
			{
				WriteValue("Not Found")
				New-WTTAzureResourceGroup -AzureResourceGroupName $azureResourceGroupName -AzureResourceGroupLocation $WTTEnvironmentPrimaryServerLocation
			}

			If($azureResourceGroupNameExists -eq $true)
			{
				# Check for Primary SQL Server
				WriteLabel("Checking for Primary SQL Server '$azureSqlDatabaseServerPrimaryName'")
				$azurePrimarySqlDatabaseServer = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains $azureSqlDatabaseServerPrimaryName -ResourceGroupNameContains $azureResourceGroupName
				WriteValue((IIf ($azurePrimarySqlDatabaseServer -ne $null) "Found" "Not Found"))

				# Check for Secondary SQL Server
				WriteLabel("Checking for Secondary SQL Server '$azureSqlDatabaseServerSecondaryName'")
				$azureSecondarySqlDatabaseServer = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains $azureSqlDatabaseServerSecondaryName -ResourceGroupNameContains $azureResourceGroupName
				WriteValue((IIf ($azureSecondarySqlDatabaseServer -ne $null) "Found" "Not Found"))

				# Get location if both exist
				If($azurePrimarySqlDatabaseServer -ne $null -and $azureSecondarySqlDatabaseServer -ne $null) 
				{
					$azurePrimarySqlDatabaseServer
					$azureSecondarySqlDatabaseServer
			}

				# Restart if Secondary SQL Server missing
				elseif($azurePrimarySqlDatabaseServer -ne $null -and $azureSecondarySqlDatabaseServer -eq $null) 
				{
					LineBreak
					WriteError("Removing '$azureResourceGroupName' Resource Group and all related resources.")

					$null = Remove-AzureRMResourceGroup -Name $azureResourceGroupName -Force
					$azureResourceGroupNameExists = $null
					$azurePrimarySqlDatabaseServer = $null
					$azureSecondarySqlDatabaseServer = $null
				}

				# Restart if Primary SQL Server missing
				elseif($azurePrimarySqlDatabaseServer -eq $null -and $azureSecondarySqlDatabaseServer -ne $null) 
				{
					LineBreak
					WriteError("Removing '$azureResourceGroupName' Resource Group and all related resources.")

					$null = Remove-AzureRMResourceGroup -Name $azureResourceGroupName -Force
					$azureResourceGroupNameExists = $null
					$azurePrimarySqlDatabaseServer = $null
					$azureSecondarySqlDatabaseServer = $null
				}
			}

			# Create Storage Account                    
			New-WTTAzureStorageAccount -AzureStorageAccountResourceGroupName $azureResourceGroupName -AzureStorageAccountName $azureStorageAccountName -AzureStorageAccountType "Standard_GRS" -AzureStorageLocation $WTTEnvironmentPrimaryServerLocation

			# Get Secondary Location
			if ($wTTEnvironmentSecondaryServerLocation -eq "")
			{
				WriteLabel("Checking for Secondary Location")
				$wTTEnvironmentSecondaryServerLocation = (Get-AzureRMStorageAccount -ResourceGroupName $azureResourceGroupName -StorageAccountName $azureStorageAccountName).SecondaryLocation                     
				WriteValue("Successful")
			}

			# Create DocumentDB location based off the closest available location
			LineBreak
			WriteLabel("Checking for DocumentDb Location")
			$WTTDocumentDbLocation = 
				Switch ($WTTEnvironmentPrimaryServerLocation)
				{
					'West US' {'West US'}
					'North Europe' {'North Europe'}
					'West Europe' {'West Europe'}
					'East US' {'East US'}
					'North Central US' {'East US'}
					'East US 2' {'East US'}
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
			WriteValue("Successful")

			# Create DocumentDB
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

			# Create Primary SQL Server
			$azurePrimarySqlDatabaseServer
			if ($azurePrimarySqlDatabaseServer -eq $null)
			{
				New-WTTAzureSqlDatabaseServer -AzureSqlDatabaseServerName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseServerVersion $AzureSqlDatabaseServerVersion -AzureSqlDatabaseServerResourceGroupName $azureResourceGroupName                        
				$azurePrimarySqlDatabaseServer = Get-AzureRMSqlServer -ServerName $azureSqlDatabaseServerPrimaryName -ResourceGroupName $azureResourceGroupName -ErrorVariable azureSqlDatabaseServerPrimaryNameExistsErrors -ErrorAction SilentlyContinue                                                
			}

			# Create Secondary SQL Server
			if ($azureSecondarySqlDatabaseServer -eq $null)
			{
				New-WTTAzureSqlDatabaseServer -AzureSqlDatabaseServerName $azureSqlDatabaseServerSecondaryName -AzureSqlDatabaseServerLocation $wTTEnvironmentSecondaryServerLocation -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseServerVersion $AzureSqlDatabaseServerVersion -AzureSqlDatabaseServerResourceGroupName $azureResourceGroupName   
				$azureSecondarySqlDatabaseServer = Get-AzureRMSqlServer -ServerName $azureSqlDatabaseServerSecondaryName -ResourceGroupName $azureResourceGroupName -ErrorVariable azureSqlDatabaseServerSecondaryNameExists -ErrorAction SilentlyContinue                                 
			}

            # Deploy Customer1 database
            $dbExists = $false
            do
            {
                if ($azurePrimarySqlDatabaseServer -ne $null)
			    {   
				    Deploy-DBSchema -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -ServerName $azureSqlDatabaseServerPrimaryName -DatabaseEdition "Basic" -UserName $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -ServerLocation $WTTEnvironmentPrimaryServerLocation -DatabaseName $AzureSqlDatabaseName            
				    Populate-DBSchema -ServerName $azureSqlDatabaseServerPrimaryName -Username $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -DatabaseName $AzureSqlDatabaseName
                    Start-Sleep -Seconds 30
                    $azureSqlDatabase = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers/databases" -ResourceNameContains $AzureSqlDatabaseName -ResourceGroupNameContains $WTTEnvironmentApplicationName

                    if ($azureSqlDatabase -eq $null)
                    {
                        $dbExists = $false
	                    WriteValue("Database Not Found")
                    }
                    else
                    {
                        $result = Invoke-Sqlcmd -Username "$AzureSqlDatabaseServerAdministratorUserName@$azureSqlDatabaseServerPrimaryName" -Password $AzureSqlDatabaseServerAdministratorPassword  -ServerInstance "$azureSqlDatabaseServerPrimaryName.database.windows.net" -Database $AzureSqlDatabaseName -Query "Select * from Customers;" -QueryTimeout 0 -SuppressProviderContextWarning
                        if($result -eq $null)
                        {
                            WriteError("Customer1 Database is not deployed")
                            Remove-AzureRmSqlDatabase -ServerName $azureSqlDatabaseServerPrimaryName -DatabaseName $AzureSqlDatabaseName -Force -ErrorAction SilentlyContinue
                            $dbExists = $false
                        }
                        else
                        {
                            $dbExists  = $true
                        }
                    }
                }
            }while($dbExists -eq $false)

            Start-Sleep -Seconds 60
			# Deploy Customer2 database
            $dbExists = $false
            Do
            {
			    if ($azurePrimarySqlDatabaseServer -ne $null)
			    {   
				    Deploy-DBSchema -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -ServerName $azureSqlDatabaseServerPrimaryName -DatabaseEdition "Standard" -UserName $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -ServerLocation $WTTEnvironmentPrimaryServerLocation -DatabaseName "Customer2"           
				    Populate-DBSchema -ServerName $azureSqlDatabaseServerPrimaryName -Username $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -DatabaseName "Customer2"                   
                    Start-Sleep -Seconds 30
                    $azureSqlDatabase = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers/databases" -ResourceNameContains "Customer2" -ResourceGroupNameContains $WTTEnvironmentApplicationName

                    if ($azureSqlDatabase -eq $null)
                    {
                        $dbExists = $false
	                    WriteValue("Database Not Found")
                    }
                    else
                    {
                        $result = Invoke-Sqlcmd -Username "$AzureSqlDatabaseServerAdministratorUserName@$azureSqlDatabaseServerPrimaryName" -Password $AzureSqlDatabaseServerAdministratorPassword -ServerInstance "$azureSqlDatabaseServerPrimaryName.database.windows.net" -Database "Customer2" -Query "Select * from Customers;" -QueryTimeout 0 -SuppressProviderContextWarning
                        if($result -eq $null)
                        {
                            WriteError("Customer2 Database is not deployed")
                            Remove-AzureRmSqlDatabase -ServerName $azureSqlDatabaseServerPrimaryName -DatabaseName "Customer2" -Force -ErrorAction SilentlyContinue
                            $dbExists = $false
                        }
                        else
                        {
                            $ScaleRequest = Set-AzureRmSqlDatabase -DatabaseName "Customer2" -ServerName $azureSqlDatabaseServerPrimaryName -ResourceGroupName $azureResourceGroupName -RequestedServiceObjectiveName "S2"
                            $dbExists  = $true
                        }
                    }
			    }
            }While($dbExists -eq $false)

            Start-Sleep -Seconds 30
			if ($WTTEnvironmentPrimaryServerLocation -notcontains "" -and $wTTEnvironmentSecondaryServerLocation -notcontains "")                 
			{
				if ($wTTEnvironmentApplicationName.Length -gt 60)
				{
					$azureSearchServiceName = $wTTEnvironmentApplicationName.Substring(0,60)
				}
				else
				{
					$azureSearchServiceName = $wTTEnvironmentApplicationName
				}
                
                $azureSearchService = New-WTTAzureSearchService -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -WTTEnvironmentResourceGroupName $azureResourceGroupName -AzureSearchServiceLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseName $AzureSqlDatabaseName
				Start-Sleep -s 30

			}

			# Create service plans
			LineBreak

				# Create primary web application plan
			WriteLabel("Creating Primary application service plan '$azureSqlDatabaseServerPrimaryName'")
			$primaryAppPlan = ""
			Do
			{
				$primaryAppPlan = New-AzureRmAppServicePlan -name $azureSqlDatabaseServerPrimaryName -location $WTTEnvironmentPrimaryServerLocation -tier standard -resourcegroupname $azureresourcegroupname
				if($primaryAppPlan.Name -eq $azureSqlDatabaseServerPrimaryName)
				{
					WriteValue("Successful")
				}
			} While ($primaryAppPlan.Name -ne $azureSqlDatabaseServerPrimaryName)

			# Create secondary web application plan
			WriteLabel("Creating Secondary application service plan '$azureSqlDatabaseServerSecondaryName'")
			$secondaryAppPlan = ""
			Do
			{
				$secondaryAppPlan = New-AzureRmAppServicePlan -name $azureSqlDatabaseServerSecondaryName -location $wTTEnvironmentSecondaryServerLocation -tier standard -resourcegroupname $azureresourcegroupname
				if($secondaryAppPlan.Name -eq $azureSqlDatabaseServerSecondaryName)
				{
					WriteValue("Successful")
				}
			} While($secondaryAppPlan.Name -ne $azureSqlDatabaseServerSecondaryName)
			LineBreak

			# Create Primary web application
			WriteLabel("Creating Primary application '$azureSqlDatabaseServerPrimaryName'")
			$primaryWebApp = ""
			Do
			{
				$primaryWebApp = New-AzureRMWebApp -Location $WTTEnvironmentPrimaryServerLocation -AppServicePlan $azureSqlDatabaseServerPrimaryName -ResourceGroupName $azureResourceGroupName -Name $azureSqlDatabaseServerPrimaryName
				if($primaryWebApp.Name -eq $azureSqlDatabaseServerPrimaryName)
				{
					WriteValue("Successful")
				}
			} While($primaryWebApp.Name -ne $azureSqlDatabaseServerPrimaryName)

			# Create Secondary web application
			WriteLabel("Creating Secondary application '$azureSqlDatabaseServerSecondaryName'")
			$secondaryWebApp = ""
			Do
            {
				$secondaryWebApp = New-AzureRMWebApp -Location $wTTEnvironmentSecondaryServerLocation -AppServicePlan $azureSqlDatabaseServerSecondaryName -ResourceGroupName $azureResourceGroupName -Name $azureSqlDatabaseServerSecondaryName
				if($secondaryWebApp.Name -eq $azureSqlDatabaseServerSecondaryName)
				{
					WriteValue("Successful")
				}
			} While($secondaryWebApp.Name -ne $azureSqlDatabaseServerSecondaryName)
			start-sleep -s 120

			# Deploy Web Applications
			LineBreak
			WriteLabel("Deploying Primary application '$azureWebSitePrimaryWebDeployPackageName'")
			Deploy-WTTWebApplication -WTTEnvironmentapplicationName $WTTEnvironmentApplicationName -ResourceGroupName $azureResourceGroupName -Websitename $azureSqlDatabaseServerPrimaryName -AzureWebSiteWebDeployPackagePath $AzureWebSiteWebDeployPackagePath -AzureWebSiteWebDeployPackageName $azureWebSitePrimaryWebDeployPackageName
			WriteLabel("Deploying Secondary application '$azureWebSiteSecondaryWebDeployPackageName'")
			Deploy-WTTWebApplication -WTTEnvironmentapplicationName $WTTEnvironmentApplicationName -ResourceGroupName $azureResourceGroupName -Websitename $azureSqlDatabaseServerSecondaryName -AzureWebSiteWebDeployPackagePath $AzureWebSiteWebDeployPackagePath -AzureWebSiteWebDeployPackageName $azureWebSiteSecondaryWebDeployPackageName

			# Create Traffic Manager Profile
			LineBreak
			New-WTTAzureTrafficManagerProfile -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName -AzureTrafficManagerResourceGroupName $azureResourceGroupName
			# Add Azure WebSite Endpoints to Traffic Manager Profile
			Add-WTTAzureTrafficManagerEndpoint -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName -AzurePrimaryWebSiteName $azureSqlDatabaseServerPrimaryName -AzureSecondaryWebSiteName $azureSqlDatabaseServerSecondaryName -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -AzureTrafficManagerEndpointStatus "Enabled" -AzureTrafficManagerResourceGroupName $azureResourceGroupName
			
			if($deployDW -eq 1)
			{
				# Deploy Azure Data Warehouse on the primary database server. This may run for about 15 minutes.
				if ($azurePrimarySqlDatabaseServer -ne $null)
				{
					Deploy-WTTAzureDWDatabase -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -ServerName $azureSqlDatabaseServerPrimaryName -ServerLocation $WTTEnvironmentPrimaryServerLocation -DatabaseEdition "DataWarehouse" -UserName $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -DWDatabaseName $AzureSqlDWDatabaseName
				}
			}
			elseif(!$deployDW)
			{
				# Deploy Azure Data Warehouse on the primary database server. This may run for about 15 minutes.
				if ($azurePrimarySqlDatabaseServer -ne $null)
				{
					Deploy-WTTAzureDWDatabase -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -ServerName $azureSqlDatabaseServerPrimaryName -ServerLocation $WTTEnvironmentPrimaryServerLocation -DatabaseEdition "DataWarehouse" -UserName $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -DWDatabaseName $AzureSqlDWDatabaseName
				}
			}
            Start-Sleep -Seconds 30
			if($deployADF -eq 1)
			{
				# Deploy ADF environment
				New-WTTADFEnvironment -ApplicationName $WTTEnvironmentApplicationName -ResourceGroupName $azureResourceGroupName -DatabaseServerName $azureSqlDatabaseServerPrimaryName -DatabaseName "Recommendations" -DatabaseEdition "Basic" -DatabaseUserName $AzureSqlDatabaseServerAdministratorUserName -DatabasePassword $AzureSqlDatabaseServerAdministratorPassword
			}
			elseif(!$deployADF)
			{
				# Deploy ADF environment
				New-WTTADFEnvironment -ApplicationName $WTTEnvironmentApplicationName -ResourceGroupName $azureResourceGroupName -DatabaseServerName $azureSqlDatabaseServerPrimaryName -DatabaseName "Recommendations" -DatabaseEdition "Basic" -DatabaseUserName $AzureSqlDatabaseServerAdministratorUserName -DatabasePassword $AzureSqlDatabaseServerAdministratorPassword
			}
			Start-Sleep -Seconds 30

			# Set the Application Settings
			$searchName = (Find-AzureRmResource -ResourceType Microsoft.Search/searchServices -ResourceGroupName $wTTEnvironmentApplicationName).name
			$searchServicePrimaryManagementKey = (Invoke-AzureRmResourceAction -ResourceGroupName $azureResourceGroupName -ResourceName $searchName -ResourceType Microsoft.Search/searchServices -Action listAdminkeys -Force).PrimaryKey
            $documentDBPrimaryKey = (Invoke-AzureRmResourceAction -ResourceGroupName $azureResourceGroupName -ResourceName $azureDocumentDbName -ResourceType Microsoft.DocumentDb/databaseAccounts -Action listkeys -ApiVersion 2015-04-08 -Force).primarymasterkey

			Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -Websitename $azureSqlDatabaseServerPrimaryName -SearchName $searchName -SearchServicePrimaryManagementKey $searchServicePrimaryManagementKey -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerSecondaryName $azureSqlDatabaseServerSecondaryName -azureDocumentDbName $azureDocumentDbName -documentDbPrimaryKey $documentDbPrimaryKey 
			Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -Websitename $azureSqlDatabaseServerSecondaryName -SearchName $searchName -SearchServicePrimaryManagementKey $searchServicePrimaryManagementKey -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerSecondaryName -AzureSqlDatabaseServerSecondaryName $azureSqlDatabaseServerPrimaryName -azureDocumentDbName $azureDocumentDbName -documentDbPrimaryKey $documentDbPrimaryKey

			# Enable Auditing on Azure SQL Database Server
			# Appears to be a name resolution issue if Auditing is enabled, as Azure Search will not redirect to the database server
            $auditStorage = Find-AzureRmResource -ResourceType Microsoft.Storage/storageaccounts -ResourceNameContains $azureStorageAccountName -ResourceGroupNameContains $azureResourceGroupName
            if ($auditStorage -ne $null)
            {
			    if ($azurePrimarySqlDatabaseServer -ne $null)
			    {
                    $sqlAudit = $false
				    LineBreak
				    WriteLabel("Setting Primary SQL Server Auditing Policy")
                    Do
                    {
                        If (New-Object System.Net.Sockets.TCPClient -ArgumentList "$azureSqlDatabaseServerPrimaryName.database.windows.net",1433) 
                        { 
                            $azureStorageAccountName = $auditStorage.Name
                            $setPrimaryAzureSqlDatabaseServerAuditingPolicy = Set-AzureRmSqlDatabaseServerAuditingPolicy -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlDatabaseServerPrimaryName -StorageAccountName $azureStorageAccountName -TableIdentifier "wtt" -EventType PlainSQL_Success, PlainSQL_Failure, ParameterizedSQL_Success, ParameterizedSQL_Failure, StoredProcedure_Success, StoredProcedure_Success -WarningVariable null -WarningAction SilentlyContinue                                                 
                            $sqlAudit = $true
                        } 
                        If ($? -eq $false) 
                        {
                            $sqlAudit = $false
                        }
                    }While($sqlAudit -eq $false)
				    WriteValue("Successful")
			    }

			    if ($azureSecondarySqlDatabaseServer -ne $null)
			    {
                    $sqlAudit = $false
				    WriteLabel("Setting Secondary SQL Server Auditing Policy")
                    Do
                    {
                        If (New-Object System.Net.Sockets.TCPClient -ArgumentList "$azureSqlDatabaseServerPrimaryName.database.windows.net",1433) 
                        { 
                            $azureStorageAccountName = $auditStorage.Name
                            $setSecondaryAzureSqlDatabaseServerAuditingPolicy = Set-AzureRmSqlDatabaseServerAuditingPolicy -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlDatabaseServerSecondaryName -StorageAccountName $azureStorageAccountName -TableIdentifier "wtt" -EventType PlainSQL_Success, PlainSQL_Failure, ParameterizedSQL_Success, ParameterizedSQL_Failure, StoredProcedure_Success, StoredProcedure_Success -WarningVariable null -WarningAction SilentlyContinue
                            $sqlAudit = $true
                        } 
                        If ($? -eq $false) 
                        {
                            $sqlAudit = $false
                        }
                    }While($sqlAudit -eq $false)
				    WriteValue("Successful")
			    }
            }
            else
            {
                WriteError("Unable to find Azure Storage Account")
            }

            WriteLabel("Traffic Manager URL")
            WriteValue("$wTTEnvironmentApplicationName.trafficmanager.net")
			LineBreak
		}
		Catch
		{
			Write-Error "Error: $Error"
		}
	}
}

function IIf($If, $Right, $Wrong) 
{
	If ($If) 
	{
		return $Right
	}
	Else
	{
		return $Wrong
	}
}

function LineBreak()
{
	Write-Host ""
}

function WriteLine($label)
{
	Write-Host $label
}

function WriteLabel($label)
{
	Write-Host $label": " -nonewline -foregroundcolor "yellow"
}

function WriteValue($value)
{
	Write-Host $value
}

function WriteError($error)
{
	Write-Host "Error:" $error -foregroundcolor "red"
}

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
	if ($parts.Count -lt 3) 
	{
		for ($n = $parts.Count; $n -lt 3; $n++) 
		{
			$parts += "0"
		}
	}
	[UInt32] ((Lsh $parts[0] 16))
	[UInt32] ((Lsh $parts[1] 16))
	[UInt32] ((Lsh $parts[2] 16))
}

# Compares two version numbers "a.b.c.d". If $version1 < $version2,
# returns -1. If $version1 = $version2, returns 0. If
# $version1 > $version2, returns 1.
function CheckInstalledPowerShell($module)
{
	$installedVersion = $module
	$installedVersionVersion = $installedVersion.Version
	$installedVersionVersion = $installedVersionVersion -replace '\s',''
	$minimumRequiredVersion = '1.0.1'
	$ver1 = GetVersionStringAsArray $installedVersionVersion
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
		elseif ($ver1[1] -ge $ver2[1]) 
		{
			$out = 1
		}
	} 
	elseif ($ver1[2] -gt $ver2[2])
	{
		$out = 1
	}    
	else 
	{
		$out = 1
	}

	return $out   
}