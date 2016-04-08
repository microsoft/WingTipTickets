<#
.Synopsis
	WingtipTickets (WTT) Demo Environment.
.DESCRIPTION
	This script is used to create a new WingtipTickets (WTT) Demo Environment.
.EXAMPLE

WingTipTickets PowerShell Version 2.6 - Power BI
#>
function New-WTTPowerBI
{
	[CmdletBinding()]
	Param
	(
		# WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$WTTEnvironmentApplicationName,

		# WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$AzurePowerBIName,

		# Azure SQL Database Server Primary Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseServerPrimaryName,

		# Azure SQL Database Server Administrator User Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseServerAdministratorUserName,

		# Azure SQL Database Server Adminstrator Password
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseServerAdministratorPassword,

		# Azure Tenant SQL Database Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseName,

		# Azure DataWarehouse SQL Database Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDWDatabaseName
	)

    $azureResourceGroupName = $wTTEnvironmentApplicationName
    $azurePowerBIWorkspaceCollection = $AzurePowerBIName

    Try
    {
        $status = Get-AzureRmResourceProvider -ProviderNamespace Microsoft.PowerBI
        if ($status.RegistrationState -ne "Registered")
        {
            $null = Register-AzureRmResourceProvider -ProviderNamespace Microsoft.PowerBI -Force
        }

        WriteLabel("Checking for Azure Power BI Service $AzurePowerBIName")
        $powerBIExist = $true
        Do
        {
            $powerBIService = Find-AzureRmResource -ResourceGroupNameContains $azureResourceGroupName -ResourceType Microsoft.PowerBI -ResourceNameContains $AzurePowerBIName -ExpandProperties
            if($powerBIExist.Name -eq $AzurePowerBIName)
            {
                WriteValue("Failed")
                WriteError("$AzurePowerBIName Power BI service already exists.")
                $powerBIServiceExists = (Find-AzureRmResource -ResourceType "Microsoft.PowerBI/workspaceCollections" -ResourceNameContains $AzurePowerBIName -ResourceGroupNameContains $azureResourceGroupName -ExpandProperties).properties.Status
                if($powerBIServiceExists -eq "Active")
                {
                    $powerBIExist = $false
                }
                else
                {
                    Remove-AzureRmResource -ResourceName $AzurePowerBIName -ResourceType "Microsoft.PowerBI/workspaceCollections" -ResourceGroupName $azureResourceGroupName
                    $powerBIExist = $false
                }
            }
            else
            {
                WriteValue("Success")
                $powerBIExist = $false
            }
        }until($powerBIExist-eq $false)

        $azurePowerBIWorkspaceCollection = "wttpbit10"
        $azureResourceGroupName = "georgidev"
        # Load ADAL Assemblies
        $adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        $adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
        $null = [System.Reflection.Assembly]::LoadFrom($adal)
        $null = [System.Reflection.Assembly]::LoadFrom($adalforms)

        $tenantId = (Get-AzureRmContext).Tenant.TenantId

        $clientId = "1950a258-227b-4e31-a9cf-717495945fc2" 
        # Set redirect URI for Azure PowerShell
        $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
        # Set Resource URI to Azure Service Management API
        $resourceAppIdURI = "https://management.core.windows.net/"
        # Set Authority to Azure AD Tenant
        $authority = "https://login.windows.net/$tenantId"
        # Create Authentication Context tied to Azure AD Tenant
        $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
        # Acquire token
        $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Auto")
        $authHeader = $authResult.CreateAuthorizationHeader()
        $headers = @{"Authorization" = $authHeader}

        $azureSubscriptionID = (Get-AzureRmContext).Subscription.SubscriptionId

        $powerBIWorkspaceCollectionURL =  "https://management.azure.com/subscriptions/$azureSubscriptionID/resourceGroups/$azureResourceGroupName/providers/Microsoft.PowerBI/workspaceCollections/$azurePowerBIWorkspaceCollection"+"?api-version=2016-01-29"
        $powerBIWorkspaceCollection = "{
                                                    ""location"": ""southcentralus"",
                                                    ""tags"": {},
                                                    ""sku"": {
                                                        ""name"": ""S1"",
                                                        ""tier"": ""Standard""
                                                    }
                                        }"
    
        $powerBIWorkspaceCollectionCreate =  Invoke-RestMethod -Uri $powerBIWorkspaceCollectionURL -Method Put -Body $powerBIWorkspaceCollection -ContentType "application/json; charset=utf-8" -Headers $headers
        
        $powerBIWorkspaceCollectionURL= "https://management.azure.com/subscriptions/$azureSubscriptionID/resourceGroups/$azureResourceGroupName/providers/Microsoft.PowerBI/workspaceCollections/$azurePowerBIWorkspaceCollection"+"?api-version=2016-01-29"
        $powerBIWorkspaceCOllectionName = Invoke-RestMethod -Uri $powerBIWorkspaceCollectionURL -Method Get -Headers $headers

        $powerBIWorkspaceCOllectionKeyURL =  "https://management.azure.com/subscriptions/$azureSubscriptionID/resourceGroups/$azureResourceGroupName/providers/Microsoft.PowerBI/workspaceCollections/$azurePowerBIWorkspaceCollection/listKeys?api-version=2016-01-29"
        $powerBIWorkspaceCOllectionKey = Invoke-RestMethod -Uri $powerBIWorkspaceCOllectionKeyURL -Method Post -Headers $headers
        $pbikey = $powerBIWorkspaceCOllectionKey.key1

        #$powerBIWorkspaceURL = "https://management.azure.com/subscriptions/$azureSubscriptionID/resourceGroups/$azureResourceGroupName/providers/Microsoft.PowerBI/workspaceCollections/$azurePowerBIWorkspaceCollection/Workspaces"+"?api-version=2016-01-29"
        $powerBIWorkspaceURL = "https://api.powerbi.com/collections/$azurePowerBIWorkspaceCollection/workspaces"
        $powerBIWorkspace = "{
                                ""workspaceid"": ""$azurePowerBIWorkspaceCollection""
                            }"
        $headers = @{"Authorization" = $authHeader;"AppToken" = $pbikey}
        $powerBIWorkspaceCreate =  Invoke-RestMethod -Uri $powerBIWorkspaceURL -Method Post -Body $powerBIWorkspace -ContentType "application/json" -Headers $headers
    }
    Catch
    {
        
    }

}