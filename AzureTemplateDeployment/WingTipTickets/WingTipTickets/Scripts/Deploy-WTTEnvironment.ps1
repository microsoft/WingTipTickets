#
# Deploy_WTTEnvironment.ps1
#
function Deploy-WTTEnvironment
{
	[CmdletBinding()]
	Param
	(
		# WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$WTTEnvironmentApplicationName,

		# Primary Server Location
		[Parameter(Mandatory=$false, HelpMessage="Please specify the primary location for your WTT Environment ('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East', 'West Central US')?")]
		[ValidateSet('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East', 'West Central US', 'EastUS', 'WestUS', 'SouthCentralUS', 'NorthCentralUS', 'CentralUS', 'EastAsia', 'WestEurope', 'EastUS2', 'JapanEast', 'JapanWest', 'BrazilSouth', 'NorthEurope', 'SoutheastAsia', 'AustraliaEast', 'AustraliaSoutheast', 'CanadaCentral', 'CanadaEast', 'UKSouth', 'UKWest', 'WestUS2', 'WestCentralUS')]
		[String]
		$WTTEnvironmentLocation,

        # Tenant Event Type Pop, Rock, Classical
        [Parameter(Mandatory = $false)]
        [ValidateSet('pop', 'rock', 'classical')]
        [string]
        $TenantEventType
		  
	)
	## Variables
	$azureResourceGroupName = $WTTEnvironmentApplicationName
	$azurePowerBIWorkspaceCollection = $WTTEnvironmentApplicationName
	$azureStorageAccountName = $WTTEnvironmentApplicationName
	$azuresearchservicename = $wttenvironmentapplicationname
	$azureDocumentDbName = $wTTEnvironmentApplicationName
	$azureSqlServerPrimaryName = $wTTEnvironmentApplicationName + 'primary'
	$azureSqlServerSecondaryName = $wTTEnvironmentApplicationName + 'secondary'
	$AzureSqlDWDatabaseName = "CustomerDW"
	$AzureSqlDatabaseName = "Customer1"
	$azureSqlReportDatabaseName = "wingtipreporting"
	$adminUserName = "developer"
	$adminPassword = "P@ssword1"
	$path = (Get-Item -Path ".\" -Verbose).FullName + "\Templates"
	$DeployWTTTemplateFile = "$path\azuredeploy.json"
	$DeployWebAppTemplateFile = "$path\azuredeploy1.json"
	
	Get-ChildItem -Path $localPath -Filter *.ps1 | Unblock-File
	Get-ChildItem -Path $localPath -Filter *.ps1 | ForEach { . $_.FullName }

	## Register needed Azure Resource Providers
	$resourceProviders = @("microsoft.sql", "microsoft.web");
	if($resourceProviders.length) {
		Write-Host "Registering resource providers"
		foreach($resourceProvider in $resourceProviders) {
			Register-AzureRmResourceProvider -ProviderNamespace $resourceProvider;
		}
	}

	#Create or check for existing resource group
	$resourceGroup = Get-AzureRmResourceGroup -Name $WTTEnvironmentApplicationName -ErrorAction SilentlyContinue
	if(!$resourceGroup)
	{
		Write-Host "Resource group '$WTTEnvironmentApplicationName' does not exist. To create a new resource group, please enter a location.";
		if(!$WTTEnvironmentLocation) {
			$WTTEnvironmentLocation = Read-Host "resourceGroupLocation";
		}
		Write-Host "Creating resource group '$WTTEnvironmentApplicationName' in location '$WTTEnvironmentLocation'";
		New-AzureRmResourceGroup -Name $WTTEnvironmentApplicationName -Location $WTTEnvironmentLocation
	}
	else{
		Write-Host "Using existing resource group '$WTTEnvironmentApplicationName'";
	}

	$azureDocumentDBService = New-WTTAzureDocumentDb -azureResourceGroupName $azureResourceGroupName -WTTDocumentDbName $azureDocumentDbName -WTTDocumentDbLocation $WTTEnvironmentLocation

	# create tenant database by template
	if(Test-Path $DeployWTTTemplateFile)
    {
		New-AzureRmResourceGroupDeployment -TemplateFile $DeployWTTTemplateFile -ResourceGroupName $azureResourceGroupName -wttEnvironmentApplicationName $WTTEnvironmentApplicationName
	}
	else
	{
		Write-Host "Unable to locate $DeployWTTTemplateFile"
	}

	Start-Sleep -Seconds 600

	$azurePowerBILocation =
            Switch ($WTTEnvironmentLocation)
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
                'West US 2' {'West US'}
                'UK South' {'North Europe'}
				'UK West' {'West Europe'}
                default {'West US'}
            }

    # New Azure Power BI Service
    $pbiOutPut = New-WTTPowerBI -azureResourceGroupName $azureResourceGroupName -AzurePowerBIName $azurePowerBIWorkspaceCollection -azurePowerBILocation $azurePowerBILocation -AzureSqlServerName $azureSqlServerPrimaryName -adminUserName $adminUserName -adminPassword $adminPassword -AzureSqlDatabaseName $AzureSqlDatabaseName -azureSqlReportDatabaseName $azureSqlReportDatabaseName
    Start-Sleep -Seconds 30

	$azuresearchservice = new-wttazuresearchservice -wttenvironmentapplicationname $wttenvironmentapplicationname -azureResourceGroupName $azureResourceGroupName -azuresearchservicelocation $WTTEnvironmentLocation -AzureSqlServerName $azureSqlServerPrimaryName -adminUserName $adminUserName -adminPassword $adminPassword -AzureSqlDatabaseName $AzureSqlDatabaseName
	start-sleep -s 30

	Deploy-WTTAzureDWDatabase -azureResourceGroupName $azureResourceGroupName -azureSqlServerName $azureSqlServerPrimaryName -DatabaseEdition "DataWarehouse" -adminUserName $adminUserName -adminPassword $adminPassword -azureDWDatabaseName $AzureSqlDWDatabaseName
	start-sleep 30
	$suspend = Suspend-AzureRMSqlDatabase –ResourceGroupName $azureResourceGroupName –ServerName $azureSqlServerPrimaryName –DatabaseName $AzureSqlDWDatabaseName
	$secondaryLocation = (Get-AzureRMStorageAccount -ResourceGroupName $azureResourceGroupName -StorageAccountName $azureStorageAccountName).SecondaryLocation
	$searchServicePrimaryManagementKey = (Invoke-AzureRmResourceAction -ResourceGroupName $azureResourceGroupName -ResourceName $azuresearchservicename -ResourceType Microsoft.Search/searchServices -Action listAdminkeys -Force).PrimaryKey
	$seatMapReportId = $pbiOutPut.seatMapReportId
	$eventHubConnectionString = (Invoke-AzureRmResourceAction -ResourceGroupName $azureResourceGroupName -ResourceName $WTTEnvironmentApplicationName -ResourceType Microsoft.EventHub/Namespaces/AuthorizationRules/RootManageSharedAccessKey -Action listKeys -Force -ApiVersion 2015-08-01)
	$eventHubString = $eventHubConnectionString.split(';')

	# create tenant database by template
	if(Test-Path $DeployWebAppTemplateFile)
	{
		New-AzureRmResourceGroupDeployment -TemplateFile $DeployWebAppTemplateFile -ResourceGroupName $azureResourceGroupName -wttEnvironmentApplicationName $WTTEnvironmentApplicationName -powerbiWorkspaceId $pbiOutPut.powerbiWorkspaceId -seatMapReportID $seatMapReportId -secondaryLocation $secondaryLocation -SearchServiceKey $searchServicePrimaryManagementKey  -eventHubConnectionString $eventHubString[0]
	}
	else
	{
		Write-Host "Unable to locate $DeployWebAppTemplateFile"
	}
}