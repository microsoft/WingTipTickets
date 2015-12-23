<#
.Synopsis
    WingtipTickets (WTT) Demo Environment.
 .DESCRIPTION
    This script is used to retrieve the list of Azure SQL Database Server datacenter capabilities.
 .EXAMPLE
    Get-WTTSqlServerRegionCapabilities -ServerVersion <version> -Location <location> -TenantName <tenantName>
#>
function Get-WTTSqlServerRegionCapabilities
{
    [CmdletBinding()]
    Param
    (   
        # SQL Database Server Version
        [Parameter(Mandatory=$true, HelpMessage="Please specify the Azure SQL Database Server Version ('2.0', '12.0')?")]
        [ValidateSet('2.0', '12.0')]
        [String]
        $ServerVersion,
                
        # Search Service Location
        [Parameter(Mandatory=$false, HelpMessage="Please specify the datacenter location for your Azure Search Service ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String]
        $Location,

        # Active Directory Tenant Name
        [Parameter(Mandatory=$false)]
        [String]
        $TenantName
    )
    Process
    { 
		#COMMENT THIS OUT AFTER
		#Add-AzureAccount        
		#Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue
		
        try
        {            
            # Load ADAL Assemblies
            $adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
            $adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
            $null = [System.Reflection.Assembly]::LoadFrom($adal)
            $null = [System.Reflection.Assembly]::LoadFrom($adalforms)

            # Get Service Admin Live Email Id since we don't have native access to the Azure Active Directory Tenant Name
            [string]$adTenantAdminEmailId = (Get-AzureSubscription -Current -ExtendedDetails).AccountAdminLiveEmailId

            if ($TenantName -eq "")
            {
                if ($adTenantAdminEmailId.Contains("@microsoft.com"))
                {                
                    $adTenantName = "microsoft"
                    $adTenant = $adTenantName
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
                $adTenantName = $TenantName
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
            $azureDatacenterLocationsListURL = "https://management.core.windows.net/$azureSubscriptionID/locations"                       
            
            # retrieve the List of Azure Datacenter Locations accessible to the current subscription via the REST API
            $azureDatacenterLocationsList = @()
            $azureDatacenterLocationsList = Invoke-RestMethod -Uri $azureDatacenterLocationsListURL -Method "GET" -Headers $headers               
            [System.Collections.ArrayList]$locationsList = @()


            foreach ($currentLocation in $azureDatacenterLocationsList.Locations.Location)         
            {
                $null = $locationsList.Add($currentLocation.Name)                
            }
            
            [System.Collections.ArrayList]$locationsWithV12CapabilityList = @()
			
            foreach ($currentLocation in $locationsList)         
            {
                $azureSqlDatabaseServerRegionCapabilitiesListURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/providers/Microsoft.Sql/locations/$currentLocation/capabilities?api-version=2014-04-01-preview"
                $azureDatacenterLocationCapability = Invoke-RestMethod -Uri $azureSqlDatabaseServerRegionCapabilitiesListURL -Method "GET" -Headers $headers                
                                                
                foreach ($supportedServerVersion in $azureDatacenterLocationCapability.supportedServerVersions)
                {
                    if ($supportedServerVersion.name -eq $ServerVersion)
                    {
                        $null = $locationsWithV12CapabilityList.Add($currentLocation)                        
                    }                    
                }    
            }
            $locationsWithV12CapabilityList
        }
        Catch
        {
	        Write-Error "Error: $Error "
        }  	    
    }
}