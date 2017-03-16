function Deploy-WTTWebApplication
{
	[CmdletBinding()]
	Param
	(
		# Storage Account Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureStorageAccountName,

		# Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureResourceGroupName,

		# WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$Websitename,

		# Path to Azure Web Site WebDeploy Package
		[Parameter(Mandatory = $false)] 
		[String]$WebAppPackagePath,


		# Path to Azure Web Site WebDeploy Package
		[Parameter(Mandatory = $false)] 
		[String]$webAppPackageName,

		# Azure SQL Database Server Location
		[Parameter(Mandatory=$false, HelpMessage="Please specify the primary location for your WTT Environment ('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East', 'West Central US')?")]
		[ValidateSet('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East', 'West Central US', 'EastUS', 'WestUS', 'SouthCentralUS', 'NorthCentralUS', 'CentralUS', 'EastAsia', 'WestEurope', 'EastUS2', 'JapanEast', 'JapanWest', 'BrazilSouth', 'NorthEurope', 'SoutheastAsia', 'AustraliaEast', 'AustraliaSoutheast', 'CanadaCentral', 'CanadaEast', 'UKSouth', 'UKWest', 'WestUS2', 'WestCentralUS')]
		[String]
		$webAppLocation,
		
        # WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$WTTEnvironmentApplicationName,

		# Primary Azure SQL Database Server Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlServerPrimaryName,

		# Secondary Azure SQL Database Server Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlServerSecondaryName,

		# Azure SQL Database Server Administrator User Name
		[Parameter(Mandatory=$false)]
		[String]
	    $AdminUserName,

		# Azure SQL Database Server Adminstrator Password
		[Parameter(Mandatory=$false)]
		[String]
        $AdminPassword,

		# Azure SQL Database 1 Name
		[Parameter(Mandatory=$false)]
		[String]
        $AzureSqlDatabase1Name,

		# Azure SQL Database 2 Name
		[Parameter(Mandatory=$false)]
		[String]
        $AzureSqlDatabase2Name,

		# Azure Search Service Name
		[Parameter(Mandatory = $true)] 
		[String]
        $SearchName,

		# Azure Search Service Primary Management Key
		[Parameter(Mandatory = $true)] 
		[String]
        $SearchServicePrimaryManagementKey,

		# Azure DocumentDb Name
		[Parameter(Mandatory = $false)]
		[String]$azureDocumentDbName,

		# Azure DocumentDb Key
		[Parameter(Mandatory = $false)] 
		[String]$documentDbPrimaryKey,
        
        # Azure Power BI Signing Key
        [Parameter(Mandatory = $false)] 
        $powerbiSigningKey,

        # Azure Power BI Workspace Collection Name
        [Parameter(Mandatory = $false)] 
        $powerbiWorkspaceCollection,

        # Azure Power BI Workspace ID
        [Parameter(Mandatory = $false)] 
        $powerbiWorkspaceId,

        # Azure Power BI Seat Map ID
        [Parameter(Mandatory = $false)] 
        $seatMapReportID,

        # Tenant Event Type Pop, Rock, Classical
        [Parameter(Mandatory = $false)]
        [string]
        $TenantEventType,
        
        # Azure DocumentDb Database
		[Parameter(Mandatory = $false)] 
		[String]$documentDbDatabase,

		# Azure DocumentDb Database Collection
		[Parameter(Mandatory = $false)] 
		[String]$documentDbCollection,
        
		# Azure Event Hub Name
		[Parameter(Mandatory = $false)] 
		[String]$wttEventHubName,

        # Azure Service Bus Name
		[Parameter(Mandatory = $false)] 
		[String]$wttServiceBusName,
		
		# Seat Map Report with graphs Name 
        [Parameter(Mandatory = $false)]
        [string]
        $ReportName
	)
	Try
	{
        # Check Defaults
		if($AdminUserName -eq "")
		{
			$AdminUserName = "developer"
		}

		if($AdminPassword -eq "")
		{
			$AdminPassword = "P@ssword1"
		}

		if($AzureSqlDatabase1Name -eq "")
		{
			$AzureSqlDatabase1Name = "Customer1"
		}

		if($AzureSqlDatabase2Name -eq "")
		{
			$AzureSqlDatabase2Name = "Customer2"
		}
        if(!$TenantEventType)
        {
            $TenantEventType = "pop"
        }
        if(!$ReportName)
        {
            $ReportName = "VenueSales"
        }
		$docDBName = "https://$azureDocumentDbName.documents.azure.com:443/"

		$containerName = "deployment-files"

		$storageAccountKey = (Get-AzureRmStorageAccountKey -StorageAccountName $azureStorageAccountName -ResourceGroupName $azureResourceGroupName).Value[0]

		# Get the storage account context
		$context = New-AzureStorageContext –StorageAccountName $azureStorageAccountName -StorageAccountKey $storageAccountKey -ea silentlycontinue
		If ($context -eq $null) { throw "Invalid storage account name and/or storage key provided" }

		# Find the Container
		$container = Get-AzureStorageContainer -context $context | Where-Object { $_.Name -eq $containerName }

		If ($container -eq $null)
		{
			# Create the Container
			New-AzureStorageContainer -Name $containerName -Permission "Blob" -context $context >> setup-log.txt
		}

		# Upload Deployment Package
		WriteLabel("Uploading Deployment Package")
		$null = Set-AzureStorageBlobContent -File "$WebAppPackagePath\$webAppPackageName" -Container $containerName -Context $context -Blob $webAppPackageName -Force
		WriteValue("Successful")

		# Build Paths
		$templateFilePath = (Get-Item -Path ".\" -Verbose).FullName + "\Resources\Website\Deployment.json"
		$packageUri = "https://$azureStorageAccountName.blob.core.windows.net/deployment-files/$webAppPackageName"

		WriteLabel("Deploying Web Application '$Websitename'")
        $webSiteExist = Find-AzureRmResource -ResourceNameContains $Websitename -ResourceType Microsoft.Web/sites -ResourceGroupNameContains $azureResourceGroupName
		if(!$webSiteExist)
		{
			# Deploy application
			$webDeployment = New-AzureRmResourceGroupDeployment -ResourceGroupName $azureResourceGroupName -Name $Websitename -TemplateFile $templateFilePath -siteName $Websitename -Mode Incremental -hostingPlanName $Websitename -packageUri $packageUri -sitelocation $webAppLocation -sku "Standard" -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -AzureSqlServerPrimaryName $AzureSqlServerPrimaryName -AzureSqlServerSecondaryName $AzureSqlServerSecondaryName -AdminUserName $AdminUserName -AdminPassword $AdminPassword -AzureSqlDatabase1Name $AzureSqlDatabase1Name -AzureSqlDatabase2Name $AzureSqlDatabase2Name -SearchName $SearchName -SearchServicePrimaryManagementKey $SearchServicePrimaryManagementKey -azureDocumentDbName $azureDocumentDbName -documentDbPrimaryKey $documentDbPrimaryKey -powerbiSigningKey $powerbiSigningKey -powerbiWorkspaceCollection $powerbiWorkspaceCollection -powerbiWorkspaceId $powerbiWorkspaceId -seatMapReportID $seatMapReportID -TenantEventType $TenantEventType -documentDbDatabase $documentDbDatabase -documentDbCollection $documentDbCollection -wttEventHubName $wttEventHubName -wttServiceBusName $wttServiceBusName -ReportName $ReportName
			if($webDeployment.ProvisioningState -eq "Failed")
			{
				WriteValue("Unsuccessful")
    		}
			Else
			{
			    WriteValue("Successful")
			}
		}
		else
		{
			WriteValue("Unsuccessful")
		}
	}
	Catch
	{
		WriteValue("Failed")
		throw $Error
	}
}