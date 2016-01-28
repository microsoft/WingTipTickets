<#
.Synopsis
	WingtipTickets (WTT) Demo Environment.
.DESCRIPTION
	This script is used to update the Wingtip Tickets primary website with the ADF website URL
.EXAMPLE
	Set-WTTEnvironmentWebConfigDay2 -WTTEnvironmentApplicationName
#>
function Set-WTTEnvironmentWebConfigDay2
{
	[CmdletBinding()]
	Param
	(
		# Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$ApplicationName,

		# Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$DatabaseName,

		# Resource Group Name
		[Parameter(Mandatory=$false)]
		[String]
		$ResourceGroupName
	)
	
	Process
	{
		Try
		{
			# Get the ADF website
			WriteLabel("Setting Day2 Config Settings")
			$AdfWebSite = Get-AzureRMWebApp -Name $ApplicationName$DatabaseName -ResourceGroupName $ResourceGroupName

			# Get the Primary and Secondary WingTipTickets websites
			$WttWebSitePrimary = Get-AzureRMWebApp -ResourceGroupName $ResourceGroupName | Where-Object {$_.Name -like "*primary"}
			$WttWebSiteSecondary = Get-AzureRMWebApp -ResourceGroupName $ResourceGroupName | Where-Object {$_.Name -like "*secondary"}

			# Set the RecommendationSiteURL for the ADF website setting in the WTT website 
			$settings = @{
				"RecommendationSiteUrl" = $AdfWebSite.HostNames;
			}

			$null = Set-AzureRMWebApp -AppSettings $settings -Name $WttWebSitePrimary.Name
			$null = Set-AzureRMWebApp -AppSettings $settings -Name $WttWebSiteSecondary.Name
			
			WriteValue("Successful")
		}
		Catch
		{
			WriteError($Error)
		}
	}
}