<#
.Synopsis
    WingtipTickets (WTT) Demo Environment.
 .DESCRIPTION
    This script is used to retrieve the Matching Geo Secondary Azure SQL Database Server Region.
 .EXAMPLE
    Get-WTTSqlServerV12RegionAvailability -ApplicationName <applicationName> -TenantName <tenantName>
#>
function Get-WTTSqlServerV12RegionAvailability
{    
    [CmdletBinding()]
    Param 
    (
		# Application Name
        [Parameter(Mandatory=$true)]
        [string]$ApplicationName,
        
        # Active Directory Tenant Name
        [Parameter(Mandatory=$false)]
        [String]
        $TenantName        
    )    
	
	#COMMENT THIS OUT AFTER
	#Add-AzureAccount        
	#Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue
	
    $global:VerbosePreference = "SilentlyContinue"
    $ServerVersion = "12.0"
    
    if($TenantName -eq "")
    {
        $AvailabilityArray = Get-WTTSqlServerRegionCapabilities -ServerVersion $ServerVersion
    }
    else
    {
        $AvailabilityArray = Get-WTTSqlServerRegionCapabilities -ServerVersion $ServerVersion -TenantName $TenantName
    }
    
    foreach ($Location in $AvailabilityArray)
    {               
        $ApplicationNameWithIndex =  $ApplicationName + $AvailabilityArray.IndexOf($Location)        
        $StorageAccountName = $ApplicationName + $AvailabilityArray.IndexOf($Location) + "primary"
        $ResourceGroupName = $ApplicationName + $AvailabilityArray.IndexOf($Location)        
    
        $ServerLocation = $Location
				
		break  
    }  

	$ServerLocation
}