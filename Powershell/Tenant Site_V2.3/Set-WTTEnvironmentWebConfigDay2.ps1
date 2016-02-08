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
    Switch-AzureMode AzureServiceManagement
	#Get the ADF website
	$ADFWebSite = Get-AzureWebSite | Where-Object {$_.Name -like "*product*"}

	#Get the WTT primary Website
    $wttWebSite = Get-AzureWebSite | Where-Object {$_.Name -like "*primary"}
	$wttWebSiteSecondary = Get-AzureWebSite | Where-Object {$_.Name -like "*secondary"}
    
	$ADFWebSite = [string]$ADFWebSite.HostNames
    $wttWebSite = [string]$wttWebSite.Name
	$wttWebSiteSecondary = [string]$wttWebSiteSecondary.Name
	
	#Set the RecommendationSiteURL for the ADF website setting in the WTT website 
	$settings = New-Object Hashtable
	$settings[“RecommendationSiteUrl"] = $ADFWebSite
	
	Set-AzureWebsite -AppSettings $settings -Name $wttWebSite
	Set-AzureWebsite -AppSettings $settings -Name $wttWebSiteSecondary
}