<#
.Synopsis
	WingtipTickets (WTT) Demo Environment.
.DESCRIPTION
	This script is used to edit the Application Settings values of the web.config file in the Azure WebSites WebDeploy Zip Package.
.EXAMPLE
	Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName <string> -AzureWebSiteWebDeployPackageName <string> -SearchServicePrimaryManagementKey <string>
#>
function Set-WTTEnvironmentWebConfig
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
		$Websitename,

		# Primary Azure SQL Database Server Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseServerPrimaryName,

		# Secondary Azure SQL Database Server Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseServerSecondaryName,

		# Azure SQL Database Server Administrator User Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseServerAdministratorUserName,

		# Azure SQL Database Server Adminstrator Password
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseServerAdministratorPassword,

		# Azure SQL Database Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureSqlDatabaseName,
	
		# Azure Search Service Name
		[Parameter(Mandatory = $true)] 
		[String]$SearchName,

		# Azure Search Service Primary Management Key
		[Parameter(Mandatory = $true)] 
		[String]$SearchServicePrimaryManagementKey,

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
        $seatMapReportID
	)

	Process
	{
		try
		{
			WriteLabel("Setting Config Settings")

			# Check Defaults
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

			$docDBName = "https://$azureDocumentDbName.documents.azure.com:443/"

			# Build web application settings
			$settings = New-Object Hashtable
			$settings = 
			@{
					# Tenant Settings
					"TenantName" = "$WTTEnvironmentApplicationName"; 
					"TenantEventType" = "pop"; # This is not set from main script, used the default
					"TenantPrimaryDatabaseServer" = "$AzureSqlDatabaseServerPrimaryName"; 
					"TenantSecondaryDatabaseServer" = "$AzureSqlDatabaseServerSecondaryName";
					"TenantDatabase" = "$AzureSqlDatabaseName"; 

					# Recommendation Setings
					"RecommendationDatabaseServer" = "$AzureSqlDatabaseServerPrimaryName";
					"RecommendationDatabase" = "Recommendations";

					# Shared Settings
					"DatabaseUser" = "$AzureSqlDatabaseServerAdministratorUserName"; 
					"DatabasePassword" = "$AzureSqlDatabaseServerAdministratorPassword"; 
					"AuditingEnabled" = "false" # This is not set from main script, used the default
					"RunningInDev" = "false";

					# Keys
					"SearchServiceKey" = "$SearchServicePrimaryManagementKey"; 
					"SearchServiceName" = "$SearchName"; 
					"DocumentDbUri" = "$docDBName"; 
					"DocumentDbKey" = "$documentDbPrimaryKey";

                    # Power BI Settings
                    "powerbiSigningKey" = "$powerbiSigningKey";
                    "powerbiWorkspaceCollection" = "$powerbiWorkspaceCollection";
                    "powerbiWorkspaceId" = "$powerbiWorkspaceId";
                    "SeatMapReportId" = "$seatMapReportID"
			}

			# Add the settings to the website
			$null = Set-AzureRMWebApp -AppSettings $settings -Name $websiteName -ResourceGroupName $WTTEnvironmentApplicationName

			$null = Restart-AzureRMWebApp -Name $websiteName -ResourceGroupName $WTTEnvironmentApplicationName
			
			WriteValue("Successful")
		}
		catch
		{
			WriteError($Error)
		}
	}
}

