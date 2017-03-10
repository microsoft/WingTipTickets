<#
.Synopsis
	WingtipTickets (WTT) Demo Environment.
.DESCRIPTION
	This script is used to start the IOT emulator Web Job in the Primary Web Application.
.EXAMPLE
	 Start-WTTIOTWebJob -azureResourceGroupName <string> -Websitename <string> -primaryWebAppLocation <string>
#>
function Start-WTTIOTWebJob
{
	[CmdletBinding()]
	Param
	(		
        # Azure Resource Group Name
        [Parameter(Mandatory=$true)]
		[String]
        $azureResourceGroupName,

		# WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$Websitename,
    
    	# WTT Primary Web Application Location
		[Parameter(Mandatory=$true)]
		[String]    
        $primaryWebAppLocation
	)

	Process
	{
		try
		{

            #load System.Web Assembly
            $systemWebAssembly = [reflection.assembly]::loadwithpartialname("system.web")

		    #Register Web provider service
		    Do{
                $status = (Get-AzureRmResourceProvider -ProviderNamespace Microsoft.Web).RegistrationState
		        if ($status -ne "Registered")
		        {
			        Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Web
		        }
            }until($status -eq "Registered")

            # Load ADAL Assemblies
            $adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
            $adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
            $null = [System.Reflection.Assembly]::LoadFrom($adal)
            $null = [System.Reflection.Assembly]::LoadFrom($adalforms)

            # Setup authentication to Azure
            #Get Azure Tenant ID
            $tenantId = (Get-AzureRmContext).Tenant.TenantId
            $azureSubscriptionID = (Get-AzureRmContext).Subscription.SubscriptionId
            $clientId = "1950a258-227b-4e31-a9cf-717495945fc2"
            # Set redirect URI for Azure PowerShell
            $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
            # Set Resource URI to Azure Service Management API
            $resourceAppIdURI = "https://management.core.windows.net/"
            # Set Authority to Azure AD Tenant
            $authority = "https://login.windows.net/$tenantId"
            # Create Authentication Context tied to Azure AD Tenant
            $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority            

            $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Auto")
            $authHeader = $authResult.CreateAuthorizationHeader()
            $headers = @{"Authorization" = $authHeader}   
            
            WriteLabel("Starting primary web application web job")
            $getWebJobStatus =  "https://management.azure.com/subscriptions/$azureSubscriptionID/resourceGroups/$azureResourceGroupName/providers/Microsoft.Web/sites/$Websitename/webJobs"+"?api-version=2016-08-01"
            $web = Invoke-RestMethod -Uri $getWebJobStatus -Method Get -Headers $headers
            if($web.value.properties.status -eq 'Stopped')
            {
                #start web job
                $startwebJob =  "https://web1.appsvcux.ext.azure.com/websites/api/Websites/StartWebJob"

                $body = "{
                            ""SubscriptionId"": ""$azureSubscriptionID"",
                            ""SiteId"":{
                                ""Name"": ""$Websitename"",
                                ""ResourceGroup"": ""$azureResourceGroupName""
                                },
                            ""Region"": ""$primaryWebAppLocation"",
                            ""JobName"": ""IOTSoundReaderEmulator""
                        }"

                $web = Invoke-RestMethod -Uri $startwebJob -Body $body -Method POST -Headers $headers -ContentType "application/json"
                WriteValue("Successful")
            }
            else
            {
                WriteValue("Successful")
            }
        }
        catch
        {
            WriteError($Error)
        }
    }
}
