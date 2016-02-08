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
		$WTTDocumentDbLocation


	)

	try
	{
		WriteLabel("Creating DocumentDB")
        
        #Register DocumentDB provider service
		$status = Get-AzureRmResourceProvider -ProviderNamespace Microsoft.DocumentDb
		if ($status -ne "Registered")
		{
			Register-AzureRmResourceProvider -ProviderNamespace Microsoft.DocumentDb -Force
		}

		# Create DocumentDb Account
		New-AzureRmResource -resourceName $WTTDocumentDbName -Location $WTTDocumentDbLocation -ResourceGroupName $WTTResourceGroupName -ResourceType "Microsoft.DocumentDb/databaseAccounts" -ApiVersion 2015-04-08 -PropertyObject @{"name" = $WTTDocumentDbName; "databaseAccountOfferType" = "Standard"} -force

		# Get the primary key		
        $documentDBPrimaryKey = (Invoke-AzureRmResourceAction -ResourceGroupName $WTTResourceGroupName -ResourceName $WTTDocumentDbName -ResourceType Microsoft.DocumentDb/databaseAccounts -Action listkeys -ApiVersion 2015-04-08 -Force).primarymasterkey
		$documentDbPrimaryKey | Export-Clixml .\docdbkey.xml -Force
		WriteValue("Successful")
	}
	Catch
	{
		WriteValue("Failed")
		WriteError($Error)
	}
} 