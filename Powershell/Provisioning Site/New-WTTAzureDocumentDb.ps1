<#
.Synopsis
    WingtipTickets (WTT) Demo Environment.
 .DESCRIPTION
    This script is used to create a new WingtipTickets (WTT) Azure DocumentDb Service.
 .EXAMPLE
    New-WTTAzureDocumentDb -WTTResourceGroupName <string> -WTTDocumentDbName <string> -WTTDocumentDbLocation <string>
#>


function New-WTTAzureDocumentDb
{
    [CmdletBinding()]
    Param
    (   
		# Resource Group Name
        [Parameter(Mandatory=$false)]
        $WTTResourceGroupName,
		
		# DocumentDb Name
        [Parameter(Mandatory=$false)]
        $WTTDocumentDbName,

        # DocumentDb Location
        [Parameter(Mandatory=$false, HelpMessage="Please specify the datacenter location for your Azure DocumentDb Service ('East Asia', 'Southeast Asia', 'East US', 'West US', 'North Europe', 'West Europe')?")]
        [ValidateSet('East Asia', 'Southeast Asia', 'East US', 'West US', 'North Europe', 'West Europe')]
        $WTTDocumentDbLocation,

        #Azure Active Directory Tenant Name
        [Parameter(Mandatory=$false)]
        [String]
        $AzureActiveDirectoryTenantName
    )


          try
          {
			#Switch Azure Powershell Mode
			Switch-AzureMode AzureResourceManager
            
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
            $headerDate = '2015-11-01'
            $authHeader = $authResult.CreateAuthorizationHeader()
            # Set HTTP request headers to include Authorization header
            $headers = @{"x-ms-version"="$headerDate";"Authorization" = $authHeader}
            
            # generate the API URI
            $azureSubscription = (Get-AzureSubscription -Current -ExtendedDetails)
            $azureSubscriptionID = $azureSubscription.SubscriptionID            
            #$listDocumentDBServicesURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/resourceGroups/$WTTEnvironmentResourceGroupName/providers/Microsoft.DocumentDb/databaseAccounts?api-version=2015-04-08"
            $azureDatacenterLocationsListURL = "https://management.azure.com/providers/Microsoft.DocumentDb?api-version=2015-11-01"
          
            $azureResourceProvidersURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/providers?api-version=2015-11-01" 
            [string]$azureDocumentDBResourceProviderNamespace = "Microsoft.DocumentDb"            
            $azureDocumentDBResourceProviderURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/providers/$azureDocumentDBResourceProviderNamespace" + "?api-version=2015-11-01"
            $registerProviderUrl = [System.String]::Format("https://management.azure.com/subscriptions/$azureSubscriptionID/providers/Microsoft.DocumentDb/register?api-version=2015-04-08")           
            
            # retrieve the Azure Search Resource Provider Status via the REST API                   
            $azureDocumentDBResourceProviderStatus = Invoke-RestMethod -Uri $azureDocumentDBResourceProviderURL -Method GET -Headers $headers
            
            if ($azureDocumentDBResourceProviderStatus.registrationState -eq "NotRegistered" -or "Unregistered")            
            {
                # if not already registered, register the Azure Search Resource Provider via the REST API
                $azureResourceProviderNamespace = $azureDocumentDBResourceProviderNamespace
                $azureResourceProviderRegistrationURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/providers/$azureResourceProviderNamespace/register?api-version=2015-04-08"
                $null = Invoke-RestMethod -Uri $azureResourceProviderRegistrationURL -Method "POST" -Headers $headers
                
                # wait for the Azure Search resource provider to register
                $retry = "true"
                while ($retry -eq "true")
                {                
                    $azureDocumentDBResourceProviderStatus = Invoke-RestMethod -Uri $azureDocumentDBResourceProviderURL -Method GET -Headers @{"Authorization"=$authHeader}
                    if ($azureDocumentDBResourceProviderStatus.registrationState -eq "Registering")
                    {                 
                        Start-Sleep -s 5
                    }
                    elseif ($azureDocumentDBResourceProviderStatus.registrationState -eq "Registered")
                    {                     
                        $retry = "false"
                    }                    
                }                
            }                
            
			#Invoke-RestMethod -Method "POST" -ContentType "application/json" -Uri $registerProviderUrl -Headers $headers
            Invoke-RestMethod -Method POST -Uri $registerProviderUrl -Headers $headers -ContentType "application/json"

			# Create DocumentDb Account and Resource Group
			New-AzureResource -resourceName $WTTDocumentDbName -Location $WTTDocumentDbLocation -ResourceGroupName $WTTResourceGroupName -ResourceType "Microsoft.DocumentDb/databaseAccounts" -ApiVersion 2015-04-08 -PropertyObject @{"name" = $WTTDocumentDbName; "databaseAccountOfferType" = "Standard"} -force

			# Poll DocDB Account creation status (repeat till "succeeded")
			$createStatus = ""
			Do
			{
				$statusUrl = [System.String]::Format("https://management.azure.com/subscriptions/$azureSubscriptionID/resourcegroups/$WTTResourceGroupName/providers/Microsoft.DocumentDB/databaseAccounts/$WTTDocumentDbName/?api-version=2015-04-08")
				$statusResponse = Invoke-RestMethod -Method GET -ContentType "application/json" -Uri $statusUrl -Headers $headers
				
                $createStatus = $statusResponse.properties.provisioningState
				write-host "Create status: " $createStatus 
				Start-Sleep -s 30
			}
			Until ($createStatus -eq "succeeded")

			# Get the primary key and endpoint URL
			$createStatus.properties.documentEndpoint
			
			$keysUrl = [System.String]::Format("https://management.azure.com/subscriptions/$azureSubscriptionID/resourcegroups/$WTTResourceGroupName/providers/Microsoft.DocumentDB/databaseAccounts/$WTTDocumentDbName/listKeys?api-version=2015-04-08")
			$keys = Invoke-RestMethod -Method POST -ContentType "application/json" -Uri $keysUrl -Headers $headers
				
			
			$documentDbPrimaryKey = $keys.primaryMasterKey
            $documentDbPrimaryKey | Export-Clixml .\docdbkey.xml -Force

        }
        Catch
        {
	        Write-Error "Error: $Error "
        }  	     
} 