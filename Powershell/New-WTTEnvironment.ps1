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
		[String]$azureADFWebSiteWebDeployPackagePath
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
			$installedAzurePowerShellVersion = CheckInstalledPowerShellVersion

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
				WriteLine("Finding V12.0 SQL Database Server capable region")

				if($AzureActiveDirectoryTenantName -eq "")
				{
					$azureSqlDatabaseServerV12RegionAvailability = Get-WTTSqlDatabaseServerV12RegionAvailability -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName
				}
				else
				{
					$azureSqlDatabaseServerV12RegionAvailability = Get-WTTSqlDatabaseServerV12RegionAvailability -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -AzureActiveDirectoryTenantName $AzureActiveDirectoryTenantName
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

					# TODO: Returning the Location incorrectly. Single value with no spaces
					#$wttenvironmentprimaryserverlocation = $azurePrimarySqlDatabaseServer.location
					#$wttenvironmentsecondaryserverlocation = $azureSecondarySqlDatabaseServer.location
				}

				# Restart if Secondary SQL Server missing
				elseif($azurePrimarySqlDatabaseServer -ne $null -and $azureSecondarySqlDatabaseServer -eq $null) 
				{
					LineBreak
					WriteError("Removing '$azureResourceGroupName' Resource Group and all related resources.")

					$null = Remove-AzureRMResourceGroup -Name $azureResourceGroupName -Force -PassThru
					$azureResourceGroupNameExists = $null
					$azurePrimarySqlDatabaseServer = $null
					$azureSecondarySqlDatabaseServer = $null
				}

				# Restart if Primary SQL Server missing
				elseif($azurePrimarySqlDatabaseServer -eq $null -and $azureSecondarySqlDatabaseServer -ne $null) 
				{
					LineBreak
					WriteError("Removing '$azureResourceGroupName' Resource Group and all related resources.")

					$null = Remove-AzureRMResourceGroup -Name $azureResourceGroupName -Force -PassThru
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

			# Deploy database
			if ($azurePrimarySqlDatabaseServer -ne $null)
			{   
				Deploy-DBSchema -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -ServerName $azureSqlDatabaseServerPrimaryName -DatabaseEdition "Basic" -UserName $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -ServerLocation $WTTEnvironmentPrimaryServerLocation -DatabaseName $AzureSqlDatabaseName            
				Populate-DBSchema -ServerName $azureSqlDatabaseServerPrimaryName -Username $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -DatabaseName $AzureSqlDatabaseName                    
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

				if($AzureActiveDirectoryTenantName -eq "")
				{
					$azureSearchService = New-WTTAzureSearchService -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -WTTEnvironmentResourceGroupName $azureResourceGroupName -AzureSearchServiceLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseName $AzureSqlDatabaseName

					if($azureSearchService.Count -eq 0)
					{
						$azureSearchService = New-WTTAzureSearchService -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -WTTEnvironmentResourceGroupName $azureResourceGroupName -AzureSearchServiceLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseName $AzureSqlDatabaseName
						Start-Sleep -s 30
					}
				}
				else
				{
					$azureSearchService = New-WTTAzureSearchService -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -WTTEnvironmentResourceGroupName $azureResourceGroupName -AzureSearchServiceLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseName $AzureSqlDatabaseName -AzureActiveDirectoryTenantName $AzureActiveDirectoryTenantName

					if($azureSearchService.Count -eq 0)
					{
						$azureSearchService = New-WTTAzureSearchService -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -WTTEnvironmentResourceGroupName $azureResourceGroupName -AzureSearchServiceLocation $WTTEnvironmentPrimaryServerLocation -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerAdministratorUserName $AzureSqlDatabaseServerAdministratorUserName -AzureSqlDatabaseServerAdministratorPassword $AzureSqlDatabaseServerAdministratorPassword -AzureSqlDatabaseName $AzureSqlDatabaseName -AzureActiveDirectoryTenantName $AzureActiveDirectoryTenantName
						Start-Sleep -s 30
					}
				}

				# Create service plans
				LineBreak
				# Create primary web application plan
                WriteLabel("Creating Primary application service plan '$azureSqlDatabaseServerPrimaryName'")
				$primaryAppPlan = ""
                Do{
                $primaryAppPlan = New-AzureRmAppServicePlan -name $azureSqlDatabaseServerPrimaryName -location $WTTEnvironmentPrimaryServerLocation -tier standard -resourcegroupname $azureresourcegroupname
				if($primaryAppPlan.Name -eq $azureSqlDatabaseServerPrimaryName)
                    {
                        WriteValue("Successful")
                    }
                }While ($primaryAppPlan.Name -ne $azureSqlDatabaseServerPrimaryName)

                # Create secondary web application plan
				WriteLabel("Creating Secondary application service plan '$azureSqlDatabaseServerSecondaryName'")
				$secondaryAppPlan = ""
                Do{
                $secondaryAppPlan = New-AzureRmAppServicePlan -name $azureSqlDatabaseServerSecondaryName -location $wTTEnvironmentSecondaryServerLocation -tier standard -resourcegroupname $azureresourcegroupname
				if($secondaryAppPlan.Name -eq $azureSqlDatabaseServerSecondaryName)
                    {
                        WriteValue("Successful")
                    }
                }While($secondaryAppPlan.Name -ne $azureSqlDatabaseServerSecondaryName)

				# Create Web Applications
				LineBreak
                # Create Primary web application
				WriteLabel("Creating Primary application '$azureSqlDatabaseServerPrimaryName'")
                $primaryWebApp = ""
                Do{
				$primaryWebApp = New-AzureRMWebApp -Location $WTTEnvironmentPrimaryServerLocation -AppServicePlan $azureSqlDatabaseServerPrimaryName -ResourceGroupName $azureResourceGroupName -Name $azureSqlDatabaseServerPrimaryName
				if($primaryWebApp.Name -eq $azureSqlDatabaseServerPrimaryName)
                    {
                        WriteValue("Successful")
                    }
                }While($primaryWebApp.Name -ne $azureSqlDatabaseServerPrimaryName)

                # Create Secondary web application
				WriteLabel("Creating Secondary application '$azureSqlDatabaseServerSecondaryName'")
				$secondaryWebApp = ""
                Do{
                $secondaryWebApp = New-AzureRMWebApp -Location $wTTEnvironmentSecondaryServerLocation -AppServicePlan $azureSqlDatabaseServerSecondaryName -ResourceGroupName $azureResourceGroupName -Name $azureSqlDatabaseServerSecondaryName
				if($secondaryWebApp.Name -eq $azureSqlDatabaseServerSecondaryName)
                    {
                        WriteValue("Successful")
                    }
                }While($secondaryWebApp.Name -ne $azureSqlDatabaseServerSecondaryName)
				start-sleep -s 120

				# Deploy Web Applications
				LineBreak
				WriteLabel("Deploying Primary application '$azureWebSitePrimaryWebDeployPackageName'")
                Publish-AzureWebsiteProject -Name $azureSqlDatabaseServerPrimaryName -Package $azureWebSitePrimaryWebDeployPackagePath
				WriteValue("Successful")

				WriteLabel("Deploying Secondary application '$azureWebSiteSecondaryWebDeployPackageName'")
				Publish-AzureWebsiteProject -Name $azureSqlDatabaseServerSecondaryName -Package $azureWebSiteSecondaryWebDeployPackagePath
				WriteValue("Successful")

				# Create Traffic Manager Profile
				LineBreak
				New-WTTAzureTrafficManagerProfile -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName -AzureTrafficManagerResourceGroupName $azureResourceGroupName

				# Add Azure WebSite Endpoints to Traffic Manager Profile
				Add-WTTAzureTrafficManagerEndpoint -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName -AzurePrimaryWebSiteName $azureSqlDatabaseServerPrimaryName -AzureSecondaryWebSiteName $azureSqlDatabaseServerSecondaryName -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -AzureTrafficManagerEndpointStatus "Enabled" -AzureTrafficManagerResourceGroupName $azureResourceGroupName

			}

			# Deploy Azure Data Warehouse on the primary database server. This may run for about 15 minutes.
			if ($azurePrimarySqlDatabaseServer -ne $null)
			{
				Deploy-WTTAzureDWDatabase -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -ServerName $azureSqlDatabaseServerPrimaryName -ServerLocation $WTTEnvironmentPrimaryServerLocation -DatabaseEdition "DataWarehouse" -UserName $AzureSqlDatabaseServerAdministratorUserName -Password $AzureSqlDatabaseServerAdministratorPassword -DWDatabaseName $AzureSqlDWDatabaseName
			}

			# Deploy ADF environment
			New-WTTADFEnvironment -ApplicationName $WTTEnvironmentApplicationName -ResourceGroupName $azureResourceGroupName -Location $WTTEnvironmentPrimaryServerLocation -WebsiteHostingPlanName $azureSqlDatabaseServerPrimaryName -DatabaseServerName $azureSqlDatabaseServerPrimaryName -DatabaseName "Recommendations" -DatabaseEdition "Basic" -DatabaseUserName $AzureSqlDatabaseServerAdministratorUserName -DatabasePassword $AzureSqlDatabaseServerAdministratorPassword

			Start-Sleep -Seconds 30

			# Set the Application Settings
				$searchName = (Find-AzureRmResource -ResourceType Microsoft.Search/searchServices -ResourceGroupName $wTTEnvironmentApplicationName).name
				$searchServicePrimaryManagementKey = Import-Clixml .\searchkey.xml
				$documentDbPrimaryKey = Import-Clixml .\docdbkey.xml

				Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -Websitename $azureSqlDatabaseServerPrimaryName -SearchName $searchName -SearchServicePrimaryManagementKey $searchServicePrimaryManagementKey -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerPrimaryName -AzureSqlDatabaseServerSecondaryName $azureSqlDatabaseServerSecondaryName -azureDocumentDbName $azureDocumentDbName -documentDbPrimaryKey $documentDbPrimaryKey 
				Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -Websitename $azureSqlDatabaseServerSecondaryName -SearchName $searchName -SearchServicePrimaryManagementKey $searchServicePrimaryManagementKey -AzureSqlDatabaseServerPrimaryName $azureSqlDatabaseServerSecondaryName -AzureSqlDatabaseServerSecondaryName $azureSqlDatabaseServerPrimaryName -azureDocumentDbName $azureDocumentDbName -documentDbPrimaryKey $documentDbPrimaryKey
			

            # Enable Auditing on Azure SQL Database Server
			# Appears to be a name resolution issue if Auditing is enabled, as Azure Search will not redirect to the database server

            if ($azurePrimarySqlDatabaseServer -ne $null)
			{
				LineBreak
				WriteLabel("Setting Primary SQL Server Auditing Policy")
				$setPrimaryAzureSqlDatabaseServerAuditingPolicy = Set-AzureRmSqlDatabaseServerAuditingPolicy -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlDatabaseServerPrimaryName -StorageAccountName $azureStorageAccountName -TableIdentifier "wtt" -EventType PlainSQL_Success, PlainSQL_Failure, ParameterizedSQL_Success, ParameterizedSQL_Failure, StoredProcedure_Success, StoredProcedure_Success -WarningVariable null -WarningAction SilentlyContinue                                                 
				WriteValue("Successful")
			}

			if ($azureSecondarySqlDatabaseServer -ne $null)
			{
				WriteLabel("Setting Secondary SQL Server Auditing Policy")
				$setSecondaryAzureSqlDatabaseServerAuditingPolicy = Set-AzureRmSqlDatabaseServerAuditingPolicy -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlDatabaseServerSecondaryName -StorageAccountName $azureStorageAccountName -TableIdentifier "wtt" -EventType PlainSQL_Success, PlainSQL_Failure, ParameterizedSQL_Success, ParameterizedSQL_Failure, StoredProcedure_Success, StoredProcedure_Success -WarningVariable null -WarningAction SilentlyContinue
				WriteValue("Successful")
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