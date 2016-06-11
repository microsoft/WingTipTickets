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
		$status = Get-AzureRmResourceProvider -ProviderNamespace Microsoft.DocumentDb
		if ($status -ne "Registered")
		{
			Register-AzureRmResourceProvider -ProviderNamespace Microsoft.DocumentDb -Force
		}

		# Create DocumentDb Account
		New-AzureRmResource -resourceName $WTTDocumentDbName -Location $WTTDocumentDbLocation -ResourceGroupName $azureResourceGroupName -ResourceType "Microsoft.DocumentDb/databaseAccounts" -ApiVersion 2015-04-08 -PropertyObject @{"name" = $WTTDocumentDbName; "databaseAccountOfferType" = "Standard"} -force
		$docDBDeployed = (Get-AzureRmResource -ResourceName $WTTDocumentDbName -ResourceGroupName $azureResourceGroupName -ExpandProperties).Properties.provisioningstate
        if($docDBDeployed -eq "Succeeded")
        {
            WriteValue("Successful")
        }
        Else
        {
            WriteError("Failed")
        }
	}
	Catch
	{
		WriteValue("Failed")
		WriteError($Error)
	}
} 