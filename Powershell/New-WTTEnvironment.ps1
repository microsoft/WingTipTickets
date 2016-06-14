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
		$adminUserName,

		# Azure SQL Database Server Adminstrator Password
		[Parameter(Mandatory=$false)]
		[String]
		$adminPassword,

		# Azure SQL Database Server Version
		[Parameter(Mandatory=$false, HelpMessage="Please specify the Azure SQL Database Server Version ('2.0', '12.0')?")]
		[ValidateSet('2.0', '12.0')]
		[String]
		$AzureSqlServerVersion,

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
		[String]$WebAppPackagePath, 

		# Primary Azure Web Site WebDeploy Package Name
		[Parameter(Mandatory = $false)] 
		[String]$webAppPrimaryPackageName,

		# Secondary Azure Web Site WebDeploy Package Name
		[Parameter(Mandatory = $false)] 
		[String]$webAppSecondaryPackageName,

        #This parameter is used by deploy-wttenvironment.ps1
		[Parameter(Mandatory = $false)]
		[string]
		$installedAzurePowerShellVersion,

        # Tenant Event Type Pop, Rock, Classical
        [Parameter(Mandatory = $false)]
        [ValidateSet('pop', 'rock', 'classical')]
        [string]
        $TenantEventType
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
		if($adminUserName -eq "")
		{
			$adminUserName = "developer"
		}

		if($adminPassword -eq "")
		{
			$adminPassword = "P@ssword1"
		}

		if($AzureSqlServerVersion -eq "")
		{
			$AzureSqlServerVersion = "12.0"
		}

		if($AzureSqlDatabaseName -eq "")
		{
			$AzureSqlDatabaseName = "Customer1"
		}

		if($AzureSqlDWDatabaseName -eq "")
		{
			$AzureSqlDWDatabaseName = "CustomerDW"
		}

		if($WebAppPackagePath -eq "")
		{
			$WebAppPackagePath = (Get-Item -Path ".\" -Verbose).FullName + "\Packages"
		}
		else
		{
			if($WebAppPackagePath.EndsWith("\"))
			{
				$WebAppPackagePath = $WebAppPackagePath.TrimEnd("\")
			}
			else
			{
				$WebAppPackagePath = $WebAppPackagePath
			}
		}

		if($webAppPrimaryPackageName -eq "")
		{
			$webAppPrimaryPackageName = "primarypackage.zip"
			$azureWebSitePrimaryWebDeployPackagePath = $WebAppPackagePath + "\" + $webAppPrimaryPackageName
		}
		else
		{
			$webAppPrimaryPackageName = $webAppPrimaryPackageName
			$azureWebSitePrimaryWebDeployPackagePath = $WebAppPackagePath + "\" + $webAppPrimaryPackageName
		}

		if($webAppSecondaryPackageName -eq "")
		{
			$webAppSecondaryPackageName = "secondarypackage.zip"
			$azureWebSiteSecondaryWebDeployPackagePath = $WebAppPackagePath + "\" + $webAppSecondaryPackageName
		}
		else
		{
			$webAppSecondaryPackageName = $webAppSecondaryPackageName
			$azureWebSiteSecondaryWebDeployPackagePath = $WebAppPackagePath + "\" + $webAppSecondaryPackageName
		}

		$localPath = (Get-Item -Path ".\" -Verbose).FullName

		$wttEnvironmentApplicationName = $WTTEnvironmentApplicationName.ToLower()

		$azureStorageAccountName = $wTTEnvironmentApplicationName
		$azureDocumentDbName = $wTTEnvironmentApplicationName
        $azurePowerBIWorkspaceCollection = $WTTEnvironmentApplicationName
		$azureSqlServerPrimaryName = $wTTEnvironmentApplicationName + "primary"
		$azureSqlServerSecondaryName = $wTTEnvironmentApplicationName + "secondary"        
		$azureResourceGroupName = $wTTEnvironmentApplicationName
		$azureSqlServerPrimaryNameExists = $null
		$azureSqlServerSecondaryNameExists = $null
		$secondaryServerLocation = ""
        $primaryServerLocation = $WTTEnvironmentPrimaryServerLocation

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
			if ($primaryServerLocation -eq "")
			{
				LineBreak
				WriteLine("Finding SQL Database Server capable region")

			    $azureSqlDatabaseServerV12RegionAvailability = Get-WTTSqlDatabaseServerV12RegionAvailability -azureResourceGroupName $azureResourceGroupName

				# Location Found
				if ($azureSqlDatabaseServerV12RegionAvailability.Count -eq 2)
				{
					$primaryServerLocation = $azureSqlDatabaseServerV12RegionAvailability[0]
					$secondaryServerLocation = $azureSqlDatabaseServerV12RegionAvailability[1]
					
					WriteLabel("Primary Datacenter Region")
					WriteValue($primaryServerLocation)
					
					WriteLabel("Secondary Datacenter Region")
					WriteValue($secondaryServerLocation)
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
				New-WTTAzureResourceGroup -AzureResourceGroupName $azureResourceGroupName -AzureResourceGroupLocation $primaryServerLocation
			}

			If($azureResourceGroupNameExists -eq $true)
			{
				# Check for Primary SQL Server
				WriteLabel("Checking for Primary SQL Server '$azureSqlServerPrimaryName'")
				$azurePrimarySqlDatabaseServer = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains $azureSqlServerPrimaryName -ResourceGroupNameContains $azureResourceGroupName
				WriteValue((IIf ($azurePrimarySqlDatabaseServer -ne $null) "Found" "Not Found"))

				# Check for Secondary SQL Server
				WriteLabel("Checking for Secondary SQL Server '$azureSqlServerSecondaryName'")
				$azureSecondarySqlDatabaseServer = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains $azureSqlServerSecondaryName -ResourceGroupNameContains $azureResourceGroupName
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
                    New-WTTAzureResourceGroup -AzureResourceGroupName $azureResourceGroupName -AzureResourceGroupLocation $primaryServerLocation
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
                    New-WTTAzureResourceGroup -AzureResourceGroupName $azureResourceGroupName -AzureResourceGroupLocation $primaryServerLocation
				}
			}

			# Create Storage Account                    
			New-WTTAzureStorageAccount -AzureResourceGroupName $azureResourceGroupName -AzureStorageAccountName $azureStorageAccountName -AzureStorageAccountType "Standard_GRS" -AzureStorageLocation $primaryServerLocation

			# Get Secondary Location
			if ($secondaryServerLocation -eq "")
			{
				WriteLabel("Checking for Secondary Location")
				$secondaryServerLocation = (Get-AzureRMStorageAccount -ResourceGroupName $azureResourceGroupName -StorageAccountName $azureStorageAccountName).SecondaryLocation                     
				WriteValue("Successful")
			}

			# Create DocumentDB location based off the closest available location
			LineBreak
			WriteLabel("Checking for DocumentDb Location")
			$WTTDocumentDbLocation = 
				Switch ($primaryServerLocation)
				{
					'West US' {'West US'}
					'North Europe' {'North Europe'}
					'West Europe' {'West Europe'}
					'East US' {'East US'}
					'North Central US' {'East US'}
					'East US 2' {'East US 2'}
					'South Central US' {'South Central US'}
					'Central US' {'Central US'}
					'North Central US' {'North Central US'}
					'Brazil South' {'East US'}
					'Southeast Asia' {'Southeast Asia'}
					'Australia Southeast' {'Southeast Asia'}
					'Australia East' {'Southeast Asia'}
					'East Asia' {'East Asia'}
					'Japan East' {'Japan East'}
					'Japan West' {'Japan West'}
					default {'West US'}
				}
			WriteValue("Successful")

			# Create DocumentDB
			$azureDocumentDBService = New-WTTAzureDocumentDb -azureResourceGroupName $azureResourceGroupName -WTTDocumentDbName $azureDocumentDbName -WTTDocumentDbLocation $WTTDocumentDbLocation
			if($azureDocumentDBService.Count -eq 0)
			{
				Start-Sleep -s 30
				$azureDocuemtnDBService = New-WTTAzureDocumentDb -azureResourceGroupName $azureResourceGroupName -WTTDocumentDbName $azureDocumentDbName -WTTDocumentDbLocation $WTTDocumentDbLocation
				$azureDocumentDBService
			}

			# Create Primary SQL Server
			$azurePrimarySqlDatabaseServer
			if ($azurePrimarySqlDatabaseServer -eq $null)
			{
				New-WTTAzureSqlDatabaseServer -AzureSqlServerName $azureSqlServerPrimaryName -AzureSqlServerLocation $primaryServerLocation -adminUserName $adminUserName -adminPassword $adminPassword -AzureSqlServerVersion $AzureSqlServerVersion -azureResourceGroupName $azureResourceGroupName                        
				$azurePrimarySqlDatabaseServer = Get-AzureRMSqlServer -ServerName $azureSqlServerPrimaryName -ResourceGroupName $azureResourceGroupName -ErrorVariable azureSqlDatabaseServerPrimaryNameExistsErrors -ErrorAction SilentlyContinue                                                
			}

			# Create Secondary SQL Server
			if ($azureSecondarySqlDatabaseServer -eq $null)
			{
				New-WTTAzureSqlDatabaseServer -AzureSqlServerName $azureSqlServerSecondaryName -AzureSqlServerLocation $secondaryServerLocation -adminUserName $adminUserName -adminPassword $adminPassword -AzureSqlServerVersion $AzureSqlServerVersion -azureResourceGroupName $azureResourceGroupName
				$azureSecondarySqlDatabaseServer = Get-AzureRMSqlServer -ServerName $azureSqlServerSecondaryName -ResourceGroupName $azureResourceGroupName -ErrorVariable azureSqlDatabaseServerSecondaryNameExists -ErrorAction SilentlyContinue                                 
			}

            # Deploy Customer1 database
            $dbExists = $false
            do
            {
                if ($azurePrimarySqlDatabaseServer -ne $null)
			    {   
				    Deploy-DBSchema -azureResourceGroupName $azureResourceGroupName -azureSqlServerName $azureSqlServerPrimaryName -DatabaseEdition "Basic" -adminUserName $adminUserName -adminPassword $adminPassword -azureSqlDatabaseName $AzureSqlDatabaseName
				    Populate-DBSchema -azureResourceGroupName $azureResourceGroupName -azureSqlServerName $azureSqlServerPrimaryName -adminUserName $adminUserName -adminPassword $adminPassword -AzureSqlDatabaseName $AzureSqlDatabaseName
                    Start-Sleep -Seconds 30
                    $azureSqlDatabase = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers/databases" -ResourceNameContains $AzureSqlDatabaseName -ResourceGroupNameContains $azureResourceGroupName

                    if (!$azureSqlDatabase)
                    {
                        $dbExists = $false
	                    WriteValue("Database Not Found")
                    }
                    else
                    {
                        Push-Location -StackName wtt
                        $result = Invoke-Sqlcmd -Username "$adminUserName@$azureSqlServerPrimaryName" -Password $adminPassword -ServerInstance "$azureSqlServerPrimaryName.database.windows.net" -Database $AzureSqlDatabaseName -Query "Select * from Customers;" -QueryTimeout 0 -SuppressProviderContextWarning
                        Pop-Location -StackName wtt
                        if($result -eq $null)
                        {
                            WriteError("Customer1 Database is not deployed")
                            $null = Remove-AzureRmSqlDatabase -ServerName $azureSqlServerPrimaryName -DatabaseName $AzureSqlDatabaseName -ResourceGroupName $azureResourceGroupName -Force -ErrorAction SilentlyContinue
                            $dbExists = $false
                        }
                        else
                        {
                            $dbExists  = $true
                        }
                    }
                }
            }while($dbExists -eq $false)

            Populate-Tickets -azureResourceGroupName $azureResourceGroupName -adminUserName $adminUserName -adminPassword $adminPassword -AzureSqlDatabaseName $AzureSqlDatabaseName -AzureSqlServerName $azureSqlServerPrimaryName

            Start-Sleep -Seconds 60
			# Deploy Customer2 database
            $dbExists = $false
            Do
            {
			    if ($azurePrimarySqlDatabaseServer -ne $null)
			    {   
				    Deploy-DBSchema -azureResourceGroupName $azureResourceGroupName -azureSqlServerName $azureSqlServerPrimaryName -DatabaseEdition "Basic" -adminUserName $adminUserName -adminPassword $adminPassword -AzureSqlDatabaseName "Customer2"           
				    Populate-DBSchema -azureResourceGroupName $azureResourceGroupName -AzureSqlServerName $azureSqlServerPrimaryName -adminUserName $adminUserName -adminPassword $adminPassword -AzureSqlDatabaseName "Customer2"
                    Start-Sleep -Seconds 30
                    $azureSqlDatabase = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers/databases" -ResourceNameContains "Customer2" -ResourceGroupNameContains $azureResourceGroupName

                    if (!$azureSqlDatabase)
                    {
                        $dbExists = $false
	                    WriteValue("Database Not Found")
                    }
                    else
                    {
                        Push-Location -StackName wtt
                        $result = Invoke-Sqlcmd -Username "$adminUserName@$azureSqlServerPrimaryName" -Password $adminPassword -ServerInstance "$azureSqlServerPrimaryName.database.windows.net" -Database "Customer2" -Query "Select * from Customers;" -QueryTimeout 0 -SuppressProviderContextWarning
                        Pop-Location -StackName wtt
                        if([string]$result -eq $null)
                        {
                            WriteError("Customer2 Database is not deployed")
                            $null = Remove-AzureRmSqlDatabase -ServerName $azureSqlServerPrimaryName -DatabaseName "Customer2" -ResourceGroupName $azureResourceGroupName -Force -ErrorAction SilentlyContinue
                            $dbExists = $false
                        }
                        else
                        {
                            $dbExists  = $true
                        }
                    }
			    }
            }While($dbExists -eq $false)

            # Deploy Customer3 database
            $dbExists = $false
            Do
            {
			    if ($azurePrimarySqlDatabaseServer -ne $null)
			    {   
				    Deploy-DBSchema -azureResourceGroupName $azureResourceGroupName -azureSqlServerName $azureSqlServerPrimaryName -DatabaseEdition "Standard" -adminUserName $adminUserName -adminPassword $adminPassword -AzureSqlDatabaseName "Customer3"
				    Populate-DBSchema -azureResourceGroupName $azureResourceGroupName -AzureSqlServerName $azureSqlServerPrimaryName -adminUserName $adminUserName -adminPassword $adminPassword -AzureSqlDatabaseName "Customer3"
                    Start-Sleep -Seconds 30
                    $azureSqlDatabase = Find-AzureRmResource -ResourceType "Microsoft.Sql/servers/databases" -ResourceNameContains "Customer3" -ResourceGroupNameContains $azureResourceGroupName

                    if (!$azureSqlDatabase)
                    {
                        $dbExists = $false
	                    WriteValue("Database Not Found")
                    }
                    else
                    {
                        Push-Location -StackName wtt
                        $result = Invoke-Sqlcmd -Username "$adminUserName@$azureSqlServerPrimaryName" -Password $adminPassword -ServerInstance "$azureSqlServerPrimaryName.database.windows.net" -Database "Customer3" -Query "Select * from Customers;" -QueryTimeout 0 -SuppressProviderContextWarning
                        Pop-Location -StackName wtt
                        if([string]$result -eq $null)
                        {
                            WriteError("Customer3 Database is not deployed")
                            $null = Remove-AzureRmSqlDatabase -ServerName $azureSqlServerPrimaryName -DatabaseName "Customer3" -ResourceGroupName $azureResourceGroupName -Force -ErrorAction SilentlyContinue
                            $dbExists = $false
                        }
                        else
                        {
                            $ScaleRequest = Set-AzureRmSqlDatabase -DatabaseName "Customer3" -ServerName $azureSqlServerPrimaryName -ResourceGroupName $azureResourceGroupName -RequestedServiceObjectiveName "S2"
                            $dbExists  = $true
                        }
                    }
			    }
            }While($dbExists -eq $false)

            Start-Sleep -Seconds 30
			if ($primaryServerLocation -notcontains "" -and $secondaryServerLocation -notcontains "")                 
			{
				if ($wttenvironmentapplicationname.length -gt 60)
				{
					$azuresearchservicename = $wttenvironmentapplicationname.substring(0,60)
				}
				else
				{
					$azuresearchservicename = $wttenvironmentapplicationname
				}
                
                $azuresearchservice = new-wttazuresearchservice -wttenvironmentapplicationname $wttenvironmentapplicationname -azureResourceGroupName $azureResourceGroupName -azuresearchservicelocation $primaryServerLocation -AzureSqlServerName $azureSqlServerPrimaryName -adminUserName $adminUserName -adminPassword $adminPassword -AzureSqlDatabaseName $AzureSqlDatabaseName
				start-sleep -s 30
			}

			# Create service plans
			LineBreak

				# Create primary web application plan
			WriteLabel("Creating Primary application service plan '$azureSqlServerPrimaryName'")
			$primaryAppPlan = ""
			Do
			{
				$primaryAppPlan = New-AzureRmAppServicePlan -name $azureSqlServerPrimaryName -location $primaryServerLocation -tier standard -resourcegroupname $azureresourcegroupname
				if($primaryAppPlan.Name -eq $azureSqlServerPrimaryName)
				{
					WriteValue("Successful")
				}
			} While ($primaryAppPlan.Name -ne $azureSqlServerPrimaryName)

			# Create secondary web application plan
			WriteLabel("Creating Secondary application service plan '$azureSqlServerSecondaryName'")
			$secondaryAppPlan = ""
			Do
			{
				$secondaryAppPlan = New-AzureRmAppServicePlan -name $azureSqlServerSecondaryName -location $secondaryServerLocation -tier standard -resourcegroupname $azureresourcegroupname
				if($secondaryAppPlan.Name -eq $azureSqlServerSecondaryName)
				{
					WriteValue("Successful")
				}
			} While($secondaryAppPlan.Name -ne $azureSqlServerSecondaryName)
			LineBreak

			# Create Primary web application
			WriteLabel("Creating Primary application '$azureSqlServerPrimaryName'")
			$primaryWebApp = ""
			Do
			{
				$primaryWebApp = New-AzureRMWebApp -Location $primaryServerLocation -AppServicePlan $azureSqlServerPrimaryName -ResourceGroupName $azureResourceGroupName -Name $azureSqlServerPrimaryName
				if($primaryWebApp.Name -eq $azureSqlServerPrimaryName)
				{
					WriteValue("Successful")
				}
			} While($primaryWebApp.Name -ne $azureSqlServerPrimaryName)

			# Create Secondary web application
			WriteLabel("Creating Secondary application '$azureSqlServerSecondaryName'")
			$secondaryWebApp = ""
			Do
            {
				$secondaryWebApp = New-AzureRMWebApp -Location $secondaryServerLocation -AppServicePlan $azureSqlServerSecondaryName -ResourceGroupName $azureResourceGroupName -Name $azureSqlServerSecondaryName
				if($secondaryWebApp.Name -eq $azureSqlServerSecondaryName)
				{
					WriteValue("Successful")
				}
			} While($secondaryWebApp.Name -ne $azureSqlServerSecondaryName)
			start-sleep -s 120

			# Deploy Web Applications
			LineBreak
			WriteLabel("Deploying Primary application '$azureSqlServerPrimaryName'")
            LineBreak
			Deploy-WTTWebApplication -azureStorageAccountName $azureStorageAccountName -azureResourceGroupName $azureResourceGroupName -Websitename $azureSqlServerPrimaryName -WebAppPackagePath $WebAppPackagePath -webAppPackageName $webAppPrimaryPackageName
			WriteLabel("Deploying Secondary application '$azureSqlServerSecondaryName'")
            LineBreak
			Deploy-WTTWebApplication -azureStorageAccountName $azureStorageAccountName -azureResourceGroupName $azureResourceGroupName -Websitename $azureSqlServerSecondaryName -WebAppPackagePath $WebAppPackagePath -webAppPackageName $webAppSecondaryPackageName

			# Create Traffic Manager Profile
			LineBreak
			New-WTTAzureTrafficManagerProfile -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName -AzureResourceGroupName $azureResourceGroupName
			# Add Azure WebSite Endpoints to Traffic Manager Profile
			Add-WTTAzureTrafficManagerEndpoint -AzureTrafficManagerProfileName $wTTEnvironmentApplicationName -azurePrimaryWebAppName $azureSqlServerPrimaryName -azureSecondaryWebAppName $azureSqlServerSecondaryName -AzureTrafficManagerEndpointStatus "Enabled" -AzureResourceGroupName $azureResourceGroupName

			# Deploy Azure Data Warehouse on the primary database server. This may run for about 15 minutes.
			if ($azurePrimarySqlDatabaseServer -ne $null)
			{
				Deploy-WTTAzureDWDatabase -azureResourceGroupName $azureResourceGroupName -azureSqlServerName $azureSqlServerPrimaryName -DatabaseEdition "DataWarehouse" -adminUserName $adminUserName -adminPassword $adminPassword -azureDWDatabaseName $AzureSqlDWDatabaseName
			}

            Start-Sleep -Seconds 60

			# Deploy ADF environment
			New-WTTADFEnvironment -ApplicationName $WTTEnvironmentApplicationName -azureResourceGroupName $azureResourceGroupName -azureSqlServerName $azureSqlServerPrimaryName -azureSQLDatabaseName "Recommendations" -DatabaseEdition "Basic" -adminUserName $adminUserName -adminPassword $adminPassword

			Start-Sleep -Seconds 30
            
            $azurePowerBILocation =
                Switch ($primaryServerLocation)
                {
                    'West US' {'West US'}
                    'North Europe' {'North Europe'}
                    'West Europe' {'West Europe'}
                    'East US' {'East US 2'}
                    'North Central US' {'North Central US'}
                    'East US 2' {'East US 2'}
                    'South Central US' {'South Central US'}
                    'Central US' {'South Central US'}
                    'Brazil South' {'Brazil South'}
                    'Southeast Asia' {'Southeast Asia'}
                    'Australia Southeast' {'Australia Southeast'}
                    'Australia East' {'Australia Southeast'}
                    'East Asia' {'Southeast Asia'}
                    'Japan East' {'Southeast Asia'}
                    'Japan West' {'Southeast Asia'}
                    'Canada Central' {'North Central US'}
                    'Canada East' {'North Central US'}
                    'West India' {'Southeast Asia'}
                    'South India' {'Southeast Asia'}
                    'Central India' {'Southeast Asia'}
                    default {'West US'}
                }

            # New Azure Power BI Service
            New-WTTPowerBI -azureResourceGroupName $azureResourceGroupName -AzurePowerBIName $azurePowerBIWorkspaceCollection -azurePowerBILocation $azurePowerBILocation -AzureSqlServerName $azureSqlServerPrimaryName -adminUserName $adminUserName -adminPassword $adminPassword -AzureSqlDatabaseName $AzureSqlDatabaseName -azureDWDatabaseName $AzureSqlDWDatabaseName
            Start-Sleep -Seconds 30

            WriteLabel("Pausing DataWarehouse database")
	    	$null = Suspend-AzureRMSqlDatabase –ResourceGroupName $azureResourceGroupName –ServerName $azureSqlServerPrimaryName –DatabaseName $AzureSqlDWDatabaseName
		    writeValue("Successful")
            Start-Sleep -s 240

			# Set the Application Settings
			$searchName = (Find-AzureRmResource -ResourceType Microsoft.Search/searchServices -ResourceGroupName $azureResourceGroupName -ResourceNameContains $azuresearchservicename).name
			$searchServicePrimaryManagementKey = (Invoke-AzureRmResourceAction -ResourceGroupName $azureResourceGroupName -ResourceName $searchName -ResourceType Microsoft.Search/searchServices -Action listAdminkeys -Force).PrimaryKey
            $documentDBPrimaryKey = (Invoke-AzureRmResourceAction -ResourceGroupName $azureResourceGroupName -ResourceName $azureDocumentDbName -ResourceType Microsoft.DocumentDb/databaseAccounts -Action listkeys -ApiVersion 2015-04-08 -Force).primarymasterkey
            $pbiSettings = Get-Content ".\powerbi.txt"
            $powerbiWorkspaceCollection = $azurePowerBIWorkspaceCollection
            $powerbiSigningKey = $pbiSettings[0]
            $powerbiWorkspaceId = $pbiSettings[1]
            $seatMapReportID = $pbiSettings[2]

			Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -azureResourceGroupName $azureResourceGroupName -Websitename $azureSqlServerPrimaryName -SearchName $searchName -SearchServicePrimaryManagementKey $searchServicePrimaryManagementKey -AzureSqlServerPrimaryName $azureSqlServerPrimaryName -AzureSqlServerSecondaryName $azureSqlServerSecondaryName -azureDocumentDbName $azureDocumentDbName -documentDbPrimaryKey $documentDbPrimaryKey -powerbiSigningKey $powerbiSigningKey -powerbiWorkspaceCollection $powerbiWorkspaceCollection -powerbiWorkspaceId $powerbiWorkspaceId -seatMapReportID $seatMapReportID -TenantEventType $TenantEventType
			Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName $wTTEnvironmentApplicationName -azureResourceGroupName $azureResourceGroupName -Websitename $azureSqlServerSecondaryName -SearchName $searchName -SearchServicePrimaryManagementKey $searchServicePrimaryManagementKey -AzureSqlServerPrimaryName $azureSqlServerSecondaryName -AzureSqlServerSecondaryName $azureSqlServerPrimaryName -azureDocumentDbName $azureDocumentDbName -documentDbPrimaryKey $documentDbPrimaryKey -powerbiSigningKey $powerbiSigningKey -powerbiWorkspaceCollection $powerbiWorkspaceCollection -powerbiWorkspaceId $powerbiWorkspaceId -seatMapReportID $seatMapReportID -TenantEventType $TenantEventType
            
            Start-Sleep -Seconds 20
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
                        If (New-Object System.Net.Sockets.TCPClient -ArgumentList "$azureSqlServerPrimaryName.database.windows.net",1433) 
                        { 
                            $azureStorageAccountName = $auditStorage.Name
                            $setPrimaryAzureSqlDatabaseServerAuditingPolicy = Set-AzureRmSqlDatabaseServerAuditingPolicy -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlServerPrimaryName -StorageAccountName $azureStorageAccountName -TableIdentifier "wtt" -EventType PlainSQL_Success, PlainSQL_Failure, ParameterizedSQL_Success, ParameterizedSQL_Failure, StoredProcedure_Success, StoredProcedure_Success -WarningVariable null -WarningAction SilentlyContinue                                                 
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
                        If (New-Object System.Net.Sockets.TCPClient -ArgumentList "$azureSqlServerSecondaryName.database.windows.net",1433) 
                        { 
                            $azureStorageAccountName = $auditStorage.Name
                            $setSecondaryAzureSqlDatabaseServerAuditingPolicy = Set-AzureRmSqlDatabaseServerAuditingPolicy -ResourceGroupName $azureResourceGroupName -ServerName $azureSqlServerSecondaryName -StorageAccountName $azureStorageAccountName -TableIdentifier "wtt" -EventType PlainSQL_Success, PlainSQL_Failure, ParameterizedSQL_Success, ParameterizedSQL_Failure, StoredProcedure_Success, StoredProcedure_Success -WarningVariable null -WarningAction SilentlyContinue
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
	$minimumRequiredVersion = '1.4.0'
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