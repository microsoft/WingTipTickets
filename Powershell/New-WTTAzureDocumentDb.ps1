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
		[Parameter(Mandatory=$true)]
		[String]
		$azureResourceGroupName,

		# DocumentDb Name
		[Parameter(Mandatory=$false)]
		$wttDocumentDbName,

		# DocumentDb Location
		[Parameter(Mandatory=$false, HelpMessage="Please specify the datacenter location for your Azure DocumentDb Service ('East Asia', 'Southeast Asia', 'East US', 'West US', 'North Europe', 'West Europe', 'Central US', 'South Central US', 'North Europe', 'West Europe', 'Japan East', 'Japan West', 'Australia East', 'Australia Southeast', 'Central India', 'South India', 'West India')?")]
		[ValidateSet('East Asia', 'Southeast Asia', 'East US', 'West US', 'North Europe', 'West Europe', 'Central US', 'South Central US', 'North Europe', 'West Europe', 'Japan East', 'Japan West', 'Australia East', 'Australia Southeast', 'Central India', 'South India', 'West India')]
		$wttDocumentDbLocation
	)

	try
	{
		WriteLabel("Creating DocumentDB")

		#Register DocumentDB provider service
		Do{
            $status = (Get-AzureRmResourceProvider -ProviderNamespace Microsoft.DocumentDb).RegistrationState
		    if ($status -ne "Registered")
		    {
			    Register-AzureRmResourceProvider -ProviderNamespace Microsoft.DocumentDb
		    }
        }until($status -eq "Registered")

		# Create DocumentDb Account
		New-AzureRmResource -resourceName $WTTDocumentDbName -Location $WTTDocumentDbLocation -ResourceGroupName $azureResourceGroupName -ResourceType "Microsoft.DocumentDb/databaseAccounts" -ApiVersion 2015-04-08 -PropertyObject @{"name" = $WTTDocumentDbName; "databaseAccountOfferType" = "Standard"} -force
		$docDBDeployed = (Get-AzureRmResource -ResourceName $WTTDocumentDbName -ResourceGroupName $azureResourceGroupName -ExpandProperties -ResourceType "Microsoft.DocumentDb/databaseAccounts").Properties.provisioningstate
        if($docDBDeployed -eq "Succeeded")
        {
            WriteValue("Successful")
        }
        Else
        {
            WriteError("Failed")
        }

        # Load ADAL Assemblies
        $adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        $adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
        $null = [System.Reflection.Assembly]::LoadFrom($adal)
        $null = [System.Reflection.Assembly]::LoadFrom($adalforms)
        # Setup authentication to Azure
        <#$tenantId = (Get-AzureRmContext).Tenant.TenantId
        $clientId = "1950a258-227b-4e31-a9cf-717495945fc2"
        # Set redirect URI for Azure PowerShell
        $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
        # Set Resource URI to Azure Service Management API
        $resourceAppIdURI = "https://management.core.windows.net/"
        # Set Authority to Azure AD Tenant
        $authority = "https://login.windows.net/$tenantId"
        # Create Authentication Context tied to Azure AD Tenant
        $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority#>
                # Setup authentication to Azure
        #Get Azure Tenant ID
        $tenantId = (Get-AzureRmContext).Tenant.TenantId
        $clientId = "1950a258-227b-4e31-a9cf-717495945fc2"
        # Set redirect URI for Azure PowerShell
        $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
        # Set Resource URI to Azure Service Management API
        $resourceAppIdURI = "https://management.core.windows.net/"
        # Set Authority to Azure AD Tenant;
        $authority = "https://login.windows.net/$tenantId"
        # Create Authentication Context tied to Azure AD Tenant
        $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority  
        $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Auto")
        $authHeader = $authResult.CreateAuthorizationHeader()
        $headers = @{"Authorization" = $authHeader}
        [string]$iotDatabase = "iotdata"
        [string]$iotRawDatabase = "iotrawdata"

        $newIOTDatabase = "https://$wttDocumentDbName.documents.azure.com/dbs"
        $body = "{""id"": ""$iotDatabase""}"
        $newIOTDatabasePost = Invoke-RestMethod -Uri $newIOTDatabase -Body $body -Method Post -Headers $headers -ContentType "application/json"

        $newIOTDatabaseCollection = "https://$wttDocumentDbName.documents.azure.com/dbs/$iotDatabase/colls"
        $body = "{
                    ""id"": ""$iotDatabase"",
                            ""indexingPolicy"": {
                                ""automatic"": true,
                                ""indexingMode"": ""Consistent"",
                                ""includedPaths"": [
                                {
                                    ""path"": ""/*"",
                                    ""indexes"": [
                                     {
                                        ""dataType"": ""String"",
                                        ""precision"": -1,
                                        ""kind"": ""Range""
                                     }
                                   ]
                                }
                              ]
                            }
                 }"
        $newIOTDatabaseCollectionPost = Invoke-RestMethod -Uri $newIOTDatabaseCollection -Method Post -Body $body -Headers @{"Authorization"=$authHeader} -ContentType "application/json" -x-ms-offer-throughput "400"

	}
	Catch
	{
		WriteValue("Failed")
		WriteError($Error)
	}
} 