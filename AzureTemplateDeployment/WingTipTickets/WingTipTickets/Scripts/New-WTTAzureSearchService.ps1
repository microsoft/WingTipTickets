<#
.Synopsis
	WingtipTickets (WTT) Demo Environment.
.DESCRIPTION
	This script is used to create a new WingtipTickets (WTT) Azure Search Service.
.EXAMPLE
	New-WTTAzureSearchService -WTTEnvironmentApplicationName <string> -WTTEnvironmentResourceGroupName <string> -AzureSearchServiceLocation <location>
#>
function New-WTTAzureSearchService
{
	[CmdletBinding()]
	Param
	(
		# WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$wttEnvironmentApplicationName,

		# Azure Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureResourceGroupName,

		# Azure Search Service Location
		[Parameter(Mandatory=$true, HelpMessage="Please specify the primary location for your WTT Environment ('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East')?")]
		[ValidateSet('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East', 'EastUS', 'WestUS', 'SouthCentralUS', 'NorthCentralUS', 'CentralUS', 'EastAsia', 'WestEurope', 'EastUS2', 'JapanEast', 'JapanWest', 'BrazilSouth', 'NorthEurope', 'SoutheastAsia', 'AustraliaEast', 'AustraliaSoutheast', 'CanadaCentral', 'CanadaEast', 'UKSouth', 'UKWest', 'WestUS2')]
		[String]
		$AzureSearchServiceLocation,

		# Azure SQL Database Server Primary Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlServerName,

		# Azure SQL Database Server Administrator User Name
		[Parameter(Mandatory=$false)]
		[String]
		$adminUserName,

		# Azure SQL Database Server Adminstrator Password
		[Parameter(Mandatory=$false)]
		[String]
		$adminPassword,

		# Azure SQL Database Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseName
	)

	Process
	{
        $ErrorActionPreference = "SilentlyContinue"
        $InformationPreference = "SilentlyContinue"
        $WarningPreference = "SilentlyContinue"

		# Check Defaults
		if ($wttEnvironmentApplicationName.Length -gt 60)
		{
			$wttEnvironmentApplicationName = $wttEnvironmentApplicationName.Substring(0,60)
		}
		else
		{
			$wttEnvironmentApplicationName = $wttEnvironmentApplicationName.ToLower()
		}

		if($AzureSqlServerName -eq "")
		{
			$AzureSqlServerName = $wttEnvironmentApplicationName + "primary"
		}

		if($adminUserName -eq "")
		{
			$adminUserName = "developer"
		}

		if($adminPassword -eq "")
		{
			$adminPassword = "P@ssword1"
		}

		if($AzureSqlDatabaseName -eq "")
		{
			$AzureSqlDatabaseName = "Customer1"
		}

		try
		{
			# Register Azure Search as a provider
			Do
            {
                $status = (Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Search).RegistrationState
			    if ($status -ne "Registered")
			    {
			        $null = Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Search -Force
			    }
            }Until($status -eq "Registered")

            Write-Host("Checking for Azure Search Service $wttEnvironmentApplicationName")
            $searchExist = $true
            Do
            {
                $listSearchService = Find-AzureRmResource -ResourceGroupNameContains $azureResourceGroupName -ResourceType Microsoft.Search/searchServices -ExpandProperties
                if($listSearchService.Name -eq $wttEnvironmentApplicationName)
                {
                    Write-Host("Failed")
                    Write-Host("$wttEnvironmentApplicationName Search Service already exists.")
                    $searchServiceExists = (Find-AzureRmResource -ResourceType "Microsoft.Search" -ResourceNameContains $wttEnvironmentApplicationName -ResourceGroupNameContains $azureResourceGroupName -ExpandProperties).properties.state
                    if($searchServiceExists -eq "Ready")
                    {
                        $searchExist = $false
                    }
                    else
                    {
                        Remove-AzureRmResource -ResourceName $wttEnvironmentApplicationName -ResourceType "Microsoft.Search/searchServices" -ResourceGroupName $azureResourceGroupName -Force
                        $searchExist = $true
                    }
                }
                else
                {
                    Write-Host("Success")
                    $searchExist = $false
                }
            }while($searchExist-eq $true)
                       
            #Get list of Search Service locations and add to an array
            $listSearchServicesLocations = (Get-AzureRmResourceProvider -ListAvailable | Where-Object {$_.ProviderNamespace -eq 'Microsoft.Search'}).locations   
            [System.Collections.ArrayList]$listSearchServicesLocation = @()
            foreach ($location in $listSearchServicesLocations)         
			{
				$null = $listSearchServicesLocation.Add($location)
			}
            
            Write-Host("Deploying Azure Search Service $wttEnvironmentApplicationName")
            $searchServiceSku = @((Find-AzureRmResource -ResourceType Microsoft.Search/searchServices -ExpandProperties).sku.name)
            if($searchServiceSku -like "free")
            {
                foreach($searchLocation in $listSearchServicesLocation)
                {  
                    try
                    {
                        $newSearchService = New-AzureRmResourceGroupDeployment -ResourceGroupName $azureResourceGroupName -TemplateUri "https://gallery.azure.com/artifact/20151001/Microsoft.Search.1.0.9/DeploymentTemplates/searchServiceDefaultTemplate.json" -nameFromTemplate $wttEnvironmentApplicationName -sku basic -location $searchLocation -partitionCount 1 -replicaCount 1
                        $newSearchServiceExists = (Find-AzureRmResource -ResourceType "Microsoft.Search" -ResourceNameContains $wttEnvironmentApplicationName -ExpandProperties).properties.state
                        if($newSearchServiceExists -eq "Ready")
                        {
                            Write-Host("Success")
                        }                 
                    }
                    catch
                    {
                        $ErrorActionPreference = "Continue"
                    }
                }  
            }
            else
            {
                foreach($searchLocation in $listSearchServicesLocation)
                {  
                    try
                    {
                        $newSearchService = New-AzureRmResourceGroupDeployment -ResourceGroupName $azureResourceGroupName -TemplateUri "https://gallery.azure.com/artifact/20151001/Microsoft.Search.1.0.9/DeploymentTemplates/searchServiceDefaultTemplate.json" -nameFromTemplate $wttEnvironmentApplicationName -sku free -location $searchLocation -partitionCount 1 -replicaCount 1
                        $newSearchServiceExists = (Find-AzureRmResource -ResourceType "Microsoft.Search" -ResourceNameContains $wttEnvironmentApplicationName -ExpandProperties).properties.state
                        if($newSearchServiceExists -eq "Ready")
                        {
                            Write-Host("Success")
                        }       
                    }
                    catch
                    {
                        $ErrorActionPreference = "Continue"
                    }
                }
            }
            #Deploy Azure Search Service index
            $azureSubscriptionID = (Get-AzureRmContext).Subscription.SubscriptionId
			$createSearchServiceURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/resourceGroups/$azureResourceGroupName/providers/Microsoft.Search/searchServices/$wttEnvironmentApplicationName" + "?api-version=2015-02-28"    
            $azureSearchServiceIndexURL = "https://$wttEnvironmentApplicationName.search.windows.net/indexes?api-version=2015-02-28"
            $azureSearchServiceIndexerURL = "https://$wttEnvironmentApplicationName.search.windows.net/indexers?api-version=2015-02-28"
            $azureSearchServiceIndexerDatasourceURL = "https://$wttEnvironmentApplicationName.search.windows.net/datasources?api-version=2015-02-28"
            $searchServiceManagementKey = Invoke-AzureRmResourceAction -ResourceGroupName $azureResourceGroupName -ResourceName $wttEnvironmentApplicationName -ResourceType Microsoft.Search/searchServices -Action listAdminkeys -Force
            $primaryKey = $searchServiceManagementKey.PrimaryKey
			$headers = @{"api-key"=$primaryKey}                
            
            $checkSearchServiceIndex = Invoke-RestMethod -Uri $azureSearchServiceIndexURL -Method "Get" -Headers $headers
            if($checkSearchServiceIndex.value.name -eq "Concert")
            {
                $searchServiceIndexURL = "https://$wttEnvironmentApplicationName.search.windows.net/indexes/concerts?api-version=2015-02-28"
                $deleteSearchServiceIndex = Invoke-RestMethod -Uri $searchServiceIndexURL -Method "Delete" -Headers $headers 
            }

			$newSearchServiceIndexerDatasourceJsonBody = "{
					""name"": ""concerts"",  
					""fields"": [
						{""name"": ""ConcertId"", ""type"": ""Edm.String"", ""key"": ""true"", ""filterable"": ""true"", ""retrievable"": ""true""},
						{""name"": ""ConcertName"", ""type"": ""Edm.String"", ""retrievable"": ""true""},
						{""name"": ""ConcertDate"", ""type"": ""Edm.DateTimeOffset"", ""filterable"": ""true"", ""facetable"": ""true"", ""sortable"": ""true"", ""retrievable"": ""true""},
						{""name"": ""VenueId"", ""type"": ""Edm.Int32"", ""filterable"": ""true"", ""retrievable"": ""true""},
						{""name"": ""VenueName"", ""type"": ""Edm.String"", ""filterable"": ""true"", ""facetable"": ""true""},
						{""name"": ""VenueCity"", ""type"": ""Edm.String"", ""filterable"": ""true"", ""facetable"": ""true""},
						{""name"": ""VenueState"", ""type"": ""Edm.String"", ""filterable"": ""true"", ""facetable"": ""true""},
						{""name"": ""VenueCountry"", ""type"": ""Edm.String"", ""filterable"": ""true"", ""facetable"": ""true""},
						{""name"": ""PerformerId"", ""type"": ""Edm.Int32"", ""filterable"": ""true"", ""retrievable"": ""true""},
						{""name"": ""PeformerName"", ""type"": ""Edm.String"", ""filterable"": ""true"", ""facetable"": ""true""},
						{""name"": ""FullTitle"", ""type"": ""Edm.String"", ""retrievable"": ""true"", ""searchable"": ""true""}
					],
					""suggesters"": [
						{
							""name"": ""sg"",
							""searchMode"": ""analyzingInfixMatching"",
							""sourceFields"": [""FullTitle""]
						}
					] 
				}" 

			# Create Index                  
			$createSearchServiceIndex = Invoke-RestMethod -Uri $azureSearchServiceIndexURL -Method "POST" -Body $newSearchServiceIndexerDatasourceJsonBody -Headers $headers -ContentType "application/json"

			$newSearchServiceIndexerDatasourceJsonBody = "{ 
				""name"": ""concertssql"", 
				""type"": ""azuresql"",
				""credentials"": { ""connectionString"": ""Server=tcp:$AzureSqlServerName.database.windows.net,1433;Database=$AzureSqlDatabaseName;User ID=$adminUserName;Password=$adminPassword;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"" },
				""container"": { ""name"": ""ConcertSearch"" },
				""dataChangeDetectionPolicy"": {
					""@odata.type"": ""#Microsoft.Azure.Search.HighWaterMarkChangeDetectionPolicy"",
					""highWaterMarkColumnName"": ""RowVersion""
				} 
				}"

			# Create indexer datasource
			$createSearchServiceIndexerDatasource = Invoke-RestMethod -Uri $azureSearchServiceIndexerDatasourceURL -Method "POST" -Body $newSearchServiceIndexerDatasourceJsonBody -Headers $headers -ContentType "application/json"

			$newSearchServiceIndexerJsonBody = "{ 
					""name"": ""fromsql"",
					""dataSourceName"": ""concertssql"",
					""targetIndexName"": ""concerts"",
					""schedule"": { ""interval"": ""PT5M"", ""startTime"" : ""2015-01-01T00:00:00Z"" }
				}"

			# Create indexer
			$createSearchServiceIndexer = Invoke-RestMethod -Uri $azureSearchServiceIndexerURL -Method "POST" -Body $newSearchServiceIndexerJsonBody -Headers $headers -ContentType "application/json"
            
            Write-Host("Success")
			
		}
		Catch
		{
			Write-Host($Error)
		}
	}
}