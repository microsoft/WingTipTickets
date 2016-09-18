<#
.Synopsis
	WingtipTickets (WTT) Demo Environment.
.DESCRIPTION
	This script is used to edit the Application Settings values of the web.config file in the Azure WebSites WebDeploy Zip Package.
.EXAMPLE
	Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName <string> -AzureWebSiteWebDeployPackageName <string> -SearchServicePrimaryManagementKey <string>
#>
function Set-WTTIOTEmulatorWebConfig
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

		# Azure DocumentDb Name
		[Parameter(Mandatory = $false)]
		[String]$azureDocumentDbName,

		# Azure DocumentDb Key
		[Parameter(Mandatory = $false)] 
		[String]$documentDbPrimaryKey,
        
        
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
		[String]$wttServiceBusName
	)

	Process
	{
		try
		{
			WriteLabel("Setting Config Settings")

			$docDBName = "https://$azureDocumentDbName.documents.azure.com:443/"
            $sbConnectionString  = (Get-AzureSBNamespace -Name $wttServiceBusName).connectionstring

			# Build web application settings
			$settings = New-Object Hashtable
			$settings = 
			@{
					"DocumentDbUri" = "$docDBName"; 
					"DocumentDbKey" = "$documentDbPrimaryKey";
                    "DocumentDbDatabase" = "$documentDbDatabase";
                    "DocumentDbCollection" = "$documentDbCollection";
                    "EventHub" = "$wttEventHubName";
                    "Microsoft.ServiceBus.ConnectionString" = "$sbConnectionString"
			}

			# Add the settings to the website
			$null = Set-AzureRMWebApp -AppSettings $settings -Name $websiteName -ResourceGroupName $azureResourceGroupName

			$null = Restart-AzureRMWebApp -Name $websiteName -ResourceGroupName $azureResourceGroupName
			
			WriteValue("Successful")
		}
		catch
		{
			WriteError($Error)
		}
	}
}

