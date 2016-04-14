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
    $powerBIReportFiles = ".\Resources\PowerBI"

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

        # Load ADAL Assemblies
        $adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
        $adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
        $null = [System.Reflection.Assembly]::LoadFrom($adal)
        $null = [System.Reflection.Assembly]::LoadFrom($adalforms)
        add-type -path "C:\Users\meyer\Desktop\PBIAssembly\Microsoft.PowerBI.Core.dll"
        add-type -path "C:\Users\meyer\Desktop\PBIAssembly\System.IdentityModel.Tokens.Jwt.dll"
        $powerBIAssemblies = New-Object Microsoft.PowerBI.Security.PowerBIToken

        #Get Azure Tenant ID
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
        $azureSubscriptionID = (Get-AzureRmContext).Subscription.SubscriptionId

        Try
        {
            # Acquire token
            $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Auto")
            $authHeader = $authResult.CreateAuthorizationHeader()
            $headers = @{"Authorization" = $authHeader}
            
            $workspaceCollectionExist = $false
            WriteLabel("Deploying Power BI Workspace Collection")
            Do
            {
                #create Power BI Workspace Collection
                $powerBIWorkspaceCollectionURL =  "https://management.azure.com/subscriptions/$azureSubscriptionID/resourceGroups/$azureResourceGroupName/providers/Microsoft.PowerBI/workspaceCollections/$azurePowerBIWorkspaceCollection"+"?api-version=2016-01-29"
                $powerBIWorkspaceCollection = "{
                                                            ""location"": ""southcentralus"",
                                                            ""tags"": {},
                                                            ""sku"": {
                                                                ""name"": ""S1"",
                                                                ""tier"": ""Standard""
                                                            }
                                                }"
                $powerBIWorkspaceCollectionCreate =  Invoke-RestMethod -Uri $powerBIWorkspaceCollectionURL -Method Put -Body $powerBIWorkspaceCollection -ContentType "application/json; charset=utf-8" -Headers $headers -Verbose
                If($powerBIWorkspaceCollectionCreate.properties.provisioningState -eq "Succeeded")
                {
                    WriteValue("Successful")
                    $workspaceCollectionExist = $true
                }
                Else
                {
                    WriteError("Unable to find Power BI Workspace Collection")
                    $workspaceCollectionExist = $false
                }
            }Until($workspaceCollectionExist -eq $true)
            $powerBIWorkspaceCollectionCreate.name | Out-File powerbi.txt -Append
            
            #Get Power BI Workspace Collection Key
            $powerBIWorkspaceCOllectionKeyURL =  "https://management.azure.com/subscriptions/$azureSubscriptionID/resourceGroups/$azureResourceGroupName/providers/Microsoft.PowerBI/workspaceCollections/$azurePowerBIWorkspaceCollection/listKeys?api-version=2016-01-29"
            $powerBIWorkspaceCOllectionKey = Invoke-RestMethod -Uri $powerBIWorkspaceCOllectionKeyURL -Method POST -Headers $headers -Verbose
            $pbikey = $powerBIWorkspaceCOllectionKey.key1 
            $pbikey | Out-File powerbi.txt -Append
        }
        Catch
        {
            Write-Error "Error: $Error"
        }
        Try
        {
            #Create Power BI Provisioning Token
            $appToken = [Microsoft.PowerBI.Security.PowerBIToken]::CreateProvisionToken($azurePowerBIWorkspaceCollection)
            $token = $appToken.Generate($pbikey)
            
            $workspaceExist = $false
            WriteLabel("Deploying Power BI Workspace")
            Do
            {
                #Create Power BI Workspace
                $powerBIWorkspaceURL = "https://api.powerbi.com/beta/collections/$azurePowerBIWorkspaceCollection/workspaces"
                $header = @{authorization = "AppToken $token"}
                $powerBIWorkspaceCreate =  Invoke-RestMethod -Uri $powerBIWorkspaceURL -Method POST -ContentType "application/json" -Headers $header -Verbose
                
                If(!$powerBIWorkspaceCreate.WorkspaceId)
                {
                    WriteValue("Successful")
                    $workspaceExist = $true
                }
                Else
                {
                    WriteError("Unable to find Power BI Workspace")
                    $workspaceExist = $false
                }

            }until($workspaceExist -eq $true)

            $powerBIWorkspaceGet = Invoke-RestMethod -Uri $powerBIWorkspaceURL -Method GET -ContentType "application/json" -Headers $header -Verbose
            $powerBIWorkspaceID = $powerBIWorkspaceGet.Value.WorkspaceId
            $powerBIWorkspaceID | Out-File powerbi.txt -Append
        
            #Import Power BI Reports
            $reports = Get-ChildItem "$powerBIReportFiles\*.pbix"
            ForEach($report in $reports)
            {   
                $powerBIWorkspace =
                Switch($report.Name)
                {
                    'WTTReports1.pbix' {"TicketSalesDashboard"}                  
                    'WTTReports2.pbix' {'TicketSalesQuantity'}
                    'seatingchart.pbix' {'SeatingChart'}
                }

                #Create Power BI Dev Token
                $appToken = [Microsoft.PowerBI.Security.PowerBIToken]::CreateDevToken($azurePowerBIWorkspaceCollection, $powerBIWorkspaceID)
                $token = $appToken.Generate($pbikey)
                $header = @{authorization = "AppToken $token"}
                               
                $reportExist = $false
                WriteLabel("Uploading Power BI Report $report")
                Do
                {
                    
                    $fileBin = [IO.File]::ReadAllBytes($report)                                                                                                               
                    $enc = [System.Text.Encoding]::GetEncoding("iso-8859-1")                                                        
                    $fileEnc = $enc.GetString($fileBin)                                                                          
                    $boundary = [System.Guid]::NewGuid().ToString()
                    $LF = "`r`n" 
                    $bodyLines = (
                        "--$boundary",
                        "Content-Disposition: form-data $LF",
                        $fileEnc,
	                    "--$boundary--$LF"
                        ) -join $LF

                    $powerBIUploadReportsURL = "https://api.powerbi.com/beta/collections/$azurePowerBIWorkspaceCollection/workspaces/$powerBIWorkspaceID/imports?datasetDisplayName=$powerBIWorkspace"
                    $powerBIUploadReportsCreate = Invoke-RestMethod -Uri $powerBIUploadReportsURL -Method POST -ContentType "multipart/form-data; boundary=`"$boundary`"" -Headers $header -Body $bodyLines -Verbose
                  
                    If(!$powerBIUploadReportsCreate.id)
                    {
                        WriteValue("Successful")
                        $reportExist = $true
                    }
                    Else
                    {
                        WriteError("Unable to find Power BI Report")
                        $reportExist = $false
                    }

                }until($reportExist -eq $true)
                
                $datasetExists = $false
                Do
                {
                    #Get Datasets
                    $powerBIDataSetGetURL = "https://api.powerbi.com/beta/collections/$azurePowerBIWorkspaceCollection/workspaces/$powerBIWorkspaceID/datasets"
                    $powerBIDataSetGet = Invoke-RestMethod -Uri $powerBIDataSetGetURL -Method GET -ContentType "application/json" -Headers $header -Verbose
                    $powerBIDataSetID = $powerBIDataSetGet.value.id
        
                    #Get Data Sources Gateway
                    $powerBIGatewayDataSourcesGetURL = "https://api.powerbi.com/beta/collections/$azurePowerBIWorkspaceCollection/workspaces/$powerBIWorkspaceID/datasets/$powerBIDataSetID/Default.GetBoundGatewayDatasources"
                    $powerBIGatewayDataSourcesGet = Invoke-RestMethod -Uri $powerBIGatewayDataSourcesGetURL -Method GET -ContentType "application/json" -Headers $header -Verbose
                    $powerBIDataSourcesGatewateID = $powerBIGatewayDataSourcesGet.value.gatewayid
        
                    #Post All connections
                    $powerBISetAllConnectionsURL = "https://api.powerbi.com/beta/collections/$azurePowerBIWorkspaceCollection/workspaces/$powerBIWorkspaceID/datasets/$powerBIDataSetID/Default.SetAllConnections "
                    $powerBISetAllConnectionsConnString = "{
                                                            ""connectionString"": ""Data source=tcp:$AzureSqlDatabaseServerPrimaryName.database.windows.net,1433;initial catalog=$AzureSqlDWDatabaseName;Persist Security info=True;Encrypt=True;TrustServerCertificate=False;""
                                                           }"
                    $powerBISetAllConnectionsPost = Invoke-RestMethod -Uri $powerBISetAllConnectionsURL -Method POST -ContentType "application/json" -Body $powerBISetAllConnectionsConnString -Headers $header -Verbose
                
                    #Check for Data source update
                    $powerBIGatewayDataSourcesGetURL
                    $powerBIGatewayDataSourcesGet
                    $powerBIDataSetID = $powerBIGatewayDataSourcesGet.value.id
                
                    if($powerBIGatewayDataSourcesGet.value.connectionDetails -match $AzureSqlDatabaseServerPrimaryName)
                    {
                            #WriteValue("Successful")
                            Write-Host "success"
                            $datasetExists = $true
                    }
                    Else
                    {
                            #WriteError("Unable to set Power BI Report Connection")
                            Write-Host "fail"
                            $datasetExists = $false
                    }
                }until($datasetExists -eq $true)


                #Patch Data Sources
                $powerBIDataSourcesPatchURL = "https://api.powerbi.com/beta/collections/$azurePowerBIWorkspaceCollection/workspaces/$powerBIWorkspaceID/gateways/$powerBIDataSourcesGatewateID/datasources/$powerBIDataSetID"
                $powerBIDataSourcesPatchBody=@{credentialType="Basic";basicCredentials=@{username=$AzureSqlDatabaseServerAdministratorUserName;password=$AzureSqlDatabaseServerAdministratorPassword}} | ConvertTo-Json
                $powerBIDataSourcesPatch = Invoke-RestMethod -Uri $powerBIDataSourcesPatchURL -Method PATCH -ContentType "application/json" -Body $powerBIDataSourcesPatchBody -Headers $header -Verbose
            }
        }
        Catch
        {
            Write-Error "Error: $Error"
        }
    }
    Catch
    {
        Write-Error "Error: $Error"
    }
}