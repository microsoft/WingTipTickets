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
        #WTT Environment Application Name
        [Parameter(Mandatory=$true)]
        [String]
        $WTTEnvironmentApplicationName,

        #Azure Resource Group Name
        [Parameter(Mandatory=$true)]
        [String]
        $WTTEnvironmentResourceGroupName,

        #Azure Search Service Location
        [Parameter(Mandatory=$true, HelpMessage="Please specify the datacenter location for your Azure Search Service ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String]
        $AzureSearchServiceLocation,

        #Azure SQL Database Server Primary Name
        [Parameter(Mandatory=$false)]
        [String]
        $AzureSqlDatabaseServerPrimaryName,
        
        #Azure SQL Database Server Administrator User Name
        [Parameter(Mandatory=$false)]
        [String]
        $AzureSqlDatabaseServerAdministratorUserName,

        #Azure SQL Database Server Adminstrator Password
        [Parameter(Mandatory=$false)]
        [String]
        $AzureSqlDatabaseServerAdministratorPassword,

        #Azure SQL Database Name
        [Parameter(Mandatory=$false)]
        [String]
        $AzureSqlDatabaseName,

        #Azure Active Directory Tenant Name
        [Parameter(Mandatory=$false)]
        [String]
        $AzureActiveDirectoryTenantName
    )
    Process
    { 
    	#Add-AzureAccount
        if ($WTTEnvironmentApplicationName.Length -gt 15)
        {
            $wTTEnvironmentApplicationName = $WTTEnvironmentApplicationName.Substring(0,15)
        }
        else
        {
            $wTTEnvironmentApplicationName = $WTTEnvironmentApplicationName
        }

        if($AzureSqlDatabaseServerPrimaryName -eq "")
        {
            $AzureSqlDatabaseServerPrimaryName = $WTTEnvironmentApplicationName + "primary"
        }

        if($AzureSqlDatabaseServerAdministratorUserName -eq "")
        {
            $AzureSqlDatabaseServerAdministratorUserName = "developer"
        }

        if($AzureSqlDatabaseServerAdministratorPassword -eq "")
        {
            $AzureSqlDatabaseServerAdministratorPassword = "P@ssword1"
        }

        if($AzureSqlDatabaseName -eq "")
        {
            $AzureSqlDatabaseName = "Customer1"
        }

        try
        {            
            # Load ADAL Assemblies
            $adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
            $adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
            $null = [System.Reflection.Assembly]::LoadFrom($adal)
            $null = [System.Reflection.Assembly]::LoadFrom($adalforms)

            # Get Service Admin Live Email Id since we don't have native access to the Azure Active Directory Tenant Name from within Azure PowerShell
            [string]$adTenantAdminEmailId = (Get-AzureSubscription -Current -ExtendedDetails).AccountAdminLiveEmailId
            
            if ($AzureActiveDirectoryTenantName -eq "")
            {
                if ($adTenantAdminEmailId.Contains("@microsoft.com"))
                {                
                    $adTenantName = "microsoft"
                    $adTenant = "$adTenantName.onmicrosoft.com"
                }
                else
                {
                    [string]$adTenantNameNoAtSign = ($adTenantAdminEmailId).Replace("@","")
                    $adTenantNameIndexofLastPeriod = $adTenantNameNoAtSign.LastIndexOf(".")
                    $adTenantNameTemp = $adTenantNameNoAtSign.Substring(0,$adTenantNameIndexofLastPeriod)
                    $adTenantName = ($adTenantNameTemp).Replace(".","")
                    $adTenant = "$adTenantName.onmicrosoft.com"
                }
            }
            else
            {
                $adTenantName = $AzureActiveDirectoryTenantName
                $adTenant = $adTenantName
            }            

            # Set Azure AD Tenant name
            #$adTenant = "$adTenantName.onmicrosoft.com" 
            # Set well-known client ID for AzurePowerShell
            $clientId = "1950a258-227b-4e31-a9cf-717495945fc2" 
            # Set redirect URI for Azure PowerShell
            $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
            # Set Resource URI to Azure Service Management API
            $resourceAppIdURI = "https://management.core.windows.net/"
            # Set Authority to Azure AD Tenant
            $authority = "https://login.windows.net/$adTenant"
            # Create Authentication Context tied to Azure AD Tenant
            $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
            # Acquire token
            $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Auto")
            
            # API header
            $headerDate = '2014-10-01'
            $authHeader = $authResult.CreateAuthorizationHeader()
            # Set HTTP request headers to include Authorization header
            $headers = @{"x-ms-version"="$headerDate";"Authorization" = $authHeader}

            # generate the API URI
            $azureSubscription = (Get-AzureSubscription -Current -ExtendedDetails)
            $azureSubscriptionID = $azureSubscription.SubscriptionID            
            $listSearchServicesURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/resourceGroups/$WTTEnvironmentResourceGroupName/providers/Microsoft.Search/searchServices?api-version=2015-02-28"
            $azureDatacenterLocationsListURL = "https://management.azure.com/providers/Microsoft.Search?api-version=2015-01-01"
            $azureSearchServiceIndexerDatasourceURL = "https://$wTTEnvironmentApplicationName.search.windows.net/datasources?api-version=2015-02-28"
            $azureSearchServiceIndexerURL = "https://$wTTEnvironmentApplicationName.search.windows.net/indexers?api-version=2015-02-28"
            $azureSearchServiceIndexURL = "https://$wTTEnvironmentApplicationName.search.windows.net/indexes?api-version=2015-02-28"
            $azureResourceProvidersURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/providers?api-version=2015-01-01" 
            [string]$azureSearchResourceProviderNamespace = "Microsoft.Search"            
            $azureSearchResourceProviderURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/providers/$azureSearchResourceProviderNamespace" + "?api-version=2015-01-01"           
            
            # retrieve the Azure Search Resource Provider Status via the REST API                   
            $azureSearchResourceProviderStatus = Invoke-RestMethod -Uri $azureSearchResourceProviderURL -Method "GET" -Headers $headers
            
            if ($azureSearchResourceProviderStatus.registrationState -eq "NotRegistered" -or "Unregistered")            
            {
                # if not already registered, register the Azure Search Resource Provider via the REST API
                $azureResourceProviderNamespace = $azureSearchResourceProviderNamespace
                $azureResourceProviderRegistrationURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/providers/$azureResourceProviderNamespace/register?api-version=2015-01-01"
                $null = Invoke-RestMethod -Uri $azureResourceProviderRegistrationURL -Method "POST" -Headers $headers
                
                # wait for the Azure Search resource provider to register
                $retry = "true"
                while ($retry -eq "true")
                {                
                    $azureSearchResourceProviderStatus = Invoke-RestMethod -Uri $azureSearchResourceProviderURL -Method "GET" -Headers $headers
                    if ($azureSearchResourceProviderStatus.registrationState -eq "Registering")
                    {                 
                        Start-Sleep -s 5
                    }
                    elseif ($azureSearchResourceProviderStatus.registrationState -eq "Registered")
                    {                     
                        $retry = "false"
                    }                    
                }                
            }                
            
            # retrieve the List of Azure Search Services via the REST API
            $listSearchServices = @()
            $listSearchServices = Invoke-RestMethod -Uri $listSearchServicesURL -Method "GET" -Headers $headers            
            
            # retrieve the List of Azure Datacenter Locations accessible to the current subscription via the REST API
            $azureDatacenterLocationsList = @()
            $azureDatacenterLocationsList = Invoke-RestMethod -Uri $azureDatacenterLocationsListURL -Method "GET" -Headers $headers               
            [System.Collections.ArrayList]$locationsList = @()

                  
            [int]$i = 0
            for ([int]$i = 0; $i -le $azureDatacenterLocationsList.resourceTypes.Count; $i++)         
            {
                if($azureDatacenterLocationsList.resourceTypes[$i].resourceType -eq "searchServices")
                {
                    $searchServicesResourceTypeIndex = $i                    
                }
            }            
                        
            foreach ($location in $azureDatacenterLocationsList.resourceTypes[$searchServicesResourceTypeIndex].locations)         
            {
                $null = $locationsList.Add($location)                
            }

            #if the $AzureSearchServiceLocation doesn't support Azure Search, then use a location that does
            if ($locationsList -notcontains $AzureSearchServiceLocation)
                {
                    $AzureSearchServiceLocation = $locationsList[0]
                }
                                    
            
            # if the Search Service exists, retrieve the Primary Key via the REST API    
            if (($listSearchServices.value | Where({$_.name -eq $wTTEnvironmentApplicationName}).Count -gt 0))
            {   
                $searchServiceManagementKeyURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/resourceGroups/$WTTEnvironmentResourceGroupName/providers/Microsoft.Search/searchServices/$wTTEnvironmentApplicationName/listAdminKeys?api-version=2015-02-28"
                $searchServiceManagementKey = Invoke-RestMethod -Uri $searchServiceManagementKeyURL -Method "POST" -Headers $headers                                
            }
            # if the Search Service doesn't exist, create it via the REST API
            else
            {                                  
                $newSearchServiceJsonBody = "{ 
                                        ""location"": ""$AzureSearchServiceLocation"", 
                                        ""properties"": { 
                                                        ""sku"": { 
                                                                ""name"": ""free"" 
                                                                }
                                                        } 
                                            }"
                #Write-Host "create service"                    
                $createSearchServiceURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/resourceGroups/$WTTEnvironmentResourceGroupName/providers/Microsoft.Search/searchServices/$wTTEnvironmentApplicationName" + "?api-version=2015-02-28"
                $createSearchService = Invoke-RestMethod -Uri $createSearchServiceURL -Method "PUT" -Body $newSearchServiceJsonBody -Headers $headers -ContentType "application/json"

                #Write-Host "get management keys"
                # once created, retrieve the Primary Key via the REST API    
                $searchServiceManagementKeyURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/resourceGroups/$WTTEnvironmentResourceGroupName/providers/Microsoft.Search/searchServices/$wTTEnvironmentApplicationName/listAdminKeys?api-version=2015-02-28"
                $searchServiceManagementKey = Invoke-RestMethod -Uri $searchServiceManagementKeyURL -Method "POST" -Headers $headers                
                
                $primaryKey = $searchServiceManagementKey.PrimaryKey
                $headers = @{"x-ms-version"="$headerDate";"Authorization" = $authHeader;"api-key"=$primaryKey}                
                
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
                #Write-Host "create index"                    
                $createSearchServiceIndex = Invoke-RestMethod -Uri $azureSearchServiceIndexURL -Method "POST" -Body $newSearchServiceIndexerDatasourceJsonBody -Headers $headers -ContentType "application/json"
                                        
                                       #""credentials"": { ""connectionString"": ""Server=tcp:$AzureSqlDatabaseServerPrimaryName.database.windows.net,1433;Database=$AzureSqlDatabaseName;User ID=$AzureSqlDatabaseServerAdministratorUserName@$AzureSqlDatabaseServerPrimaryName;Password=$AzureSqlDatabaseServerAdministratorPassword;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"" },        
                $newSearchServiceIndexerDatasourceJsonBody = "{ 
                                        ""name"": ""concertssql"", 
                                        ""type"": ""azuresql"",
                                        ""credentials"": { ""connectionString"": ""Server=tcp:$AzureSqlDatabaseServerPrimaryName.database.windows.net,1433;Database=$AzureSqlDatabaseName;User ID=$AzureSqlDatabaseServerAdministratorUserName;Password=$AzureSqlDatabaseServerAdministratorPassword;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"" },
                                        ""container"": { ""name"": ""ConcertSearch"" },
                                        ""dataChangeDetectionPolicy"": {
                                                                        ""@odata.type"": ""#Microsoft.Azure.Search.HighWaterMarkChangeDetectionPolicy"",
                                                                        ""highWaterMarkColumnName"": ""RowVersion""
                                                                        } 
                                            }"
                
                #Write-Host "create indexer datasource"                    
                $createSearchServiceIndexerDatasource = Invoke-RestMethod -Uri $azureSearchServiceIndexerDatasourceURL -Method "POST" -Body $newSearchServiceIndexerDatasourceJsonBody -Headers $headers -ContentType "application/json"
                
                $newSearchServiceIndexerJsonBody = "{ 
                                                    ""name"": ""fromsql"",
                                                    ""dataSourceName"": ""concertssql"",
                                                    ""targetIndexName"": ""concerts"",
                                                    ""schedule"": { ""interval"": ""PT5M"", ""startTime"" : ""2015-01-01T00:00:00Z"" }
                                                    }"
                                
                #Write-Host "create indexer"                                     
                $createSearchServiceIndexer = Invoke-RestMethod -Uri $azureSearchServiceIndexerURL -Method "POST" -Body $newSearchServiceIndexerJsonBody -Headers $headers -ContentType "application/json"
                #Write-Host ($createSearchServiceIndexer)
                
                #Write-Host "get indexer status"
                #$azureSearchServiceIndexersURL = "https://$wTTEnvironmentApplicationName.search.windows.net/indexers/fromsql/status?api-version=2015-02-28"
                #$getSearchServiceIndexers = Invoke-RestMethod -Uri $azureSearchServiceIndexersURL -Method "GET" -Headers $headers
                #$getSearchServiceIndexers    

            }
            <#
            Write-Host "get datasources"            
            $azureSearchServiceDatasourcesURL = "https://$wTTEnvironmentApplicationName.search.windows.net/datasources?api-version=2015-02-28"
            $azureSearchServiceDatasources = Invoke-RestMethod -Uri $azureSearchServiceDatasourcesURL -Method "GET" -Headers $headers
            $azureSearchServiceDatasources
            #>

            
            $searchServiceManagementKey.PrimaryKey            
        }
        Catch
        {
	        Write-Error "Error: $Error "
        }  	    
    }
}
