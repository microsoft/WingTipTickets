<#
.Synopsis
    WingtipTickets (WTT) Demo Environment.
 .DESCRIPTION
    This script is used to remove a WingtipTickets (WTT) Demo Environment.
 .EXAMPLE
    Remove-WTTEnvironment -WTTEnvironmentApplicationName <string>
#>
function Remove-WTTEnvironment
{
    [CmdletBinding()]
    Param
    (   
        #WTT Environment Application Name
        [Parameter(Mandatory=$true)]
        [String]
        $WTTEnvironmentApplicationName
    )
    Process
    { 
    	#Add-AzureAccount
        $localPath = (Get-Item -Path ".\" -Verbose).FullName

        $wTTEnvironmentApplicationName = $WTTEnvironmentApplicationName.ToLower()

        $azureStorageAccountName = $wTTEnvironmentApplicationName
        $azureSqlDatabaseServerPrimaryName = $wTTEnvironmentApplicationName + "primary"
        $azureSqlDatabaseServerSecondaryName = $wTTEnvironmentApplicationName + "secondary"        
        $azureResourceGroupName = $wTTEnvironmentApplicationName
        $azureCloudServicePrimaryName = $wTTEnvironmentApplicationName + "primary"
        $azureCloudServiceSecondaryName = $wTTEnvironmentApplicationName + "secondary"      

        
        Try 
        {
            
            ### Silence Verbose Output ###
            Write-Host "### Silencing Verbose Output. ###" -foregroundcolor "yellow"
            $global:VerbosePreference = "SilentlyContinue"

            ### Check installed PowerShell Version ###
            Write-Host "### Checking whether installed Azure PowerShell Version is at least 1.0.. ###" -foregroundcolor "yellow"
                        
            $installedAzurePowerShellVersion = CheckInstalledPowerShellVersion
            if ($installedAzurePowerShellVersion -ge 1)
            {
                Write-Host "### Installed Azure PowerShell Version is at least 1.0.2. ###" -foregroundcolor "yellow"

                ### Check if both ASM and ARM are provisioned ###
                Write-Host "### Checking whether Azure Service Model (ASM) and Azure Resource Model (ARM) are provisioned. ###" -foregroundcolor "yellow"
                if ($installedAzurePowerShellVersion -lt "1")
                {                                                                               
                    #Remove Azure Resource Group
                    Write-Host "### Removing Azure Resource Group '$wTTEnvironmentApplicationName'. ###" -foregroundcolor "yellow"
                    $azureResourceGroupRemoved = (Remove-AzureRMResourceGroup -Name $azureResourceGroupName -Force -PassThru -ErrorAction SilentlyContinue -ErrorVariable azureResourceGroupRemovedErrors)
                    
                    if ($azureResourceGroupRemoved)
                    {
                        Write-Host "### Success: Azure Resource Group '$wTTEnvironmentApplicationName' removed. ###" -foregroundcolor "green"
                    }
                    else
                    {
                        foreach ($error in $azureResourceGroupRemovedErrors)
                        {
                            [string]$exception = $error.Exception
                            if($exception.Contains("does not exist"))
                            {
                                Write-Host "### Azure Resource Group '$wTTEnvironmentApplicationName' doesn't exist. ###" -foregroundcolor "yellow"
                            }                    
                                else
                            {
                                Write-Host "### Error: Azure Resource Group '$wTTEnvironmentApplicationName' was not removed because: '$error'. ###" -foregroundcolor "red"                                                        
                            }
                        }
                    }
                    
                else
                {
                    ### Error if both ASM and ARM aren't provisioned ###
                    Write-Host "### Error: Azure Resource Model (ARM) needs to be provisioned. ###" -foregroundcolor "red"
                    Write-Host "### Please contact Microsoft Support to have them troubleshoot further. ###" -foregroundcolor "red"
                }
            }
            else
            {
                ### Error if installed Azure PowerShell Version is older than minimum required version ###
                Write-Host "### Error: Installed Azure PowerShell Version is older than 1.0.2.  Please install the latest version from: ###" -foregroundcolor "red"
                Write-Host "### http://azure.microsoft.com/en-us/downloads/, under Command-line tools, under Windows PowerShell, click Install ###" -foregroundcolor "red"
            }
            
        }
        }
        Catch
        {
	        Write-Error "Error: $Error "
        } 	    
   }
 }

 #Check Installed Azure PowerShell Version
# Bitwise left shift
function Lsh([UInt32] $n, [Byte] $bits) 
    {
        $n * [Math]::Pow(2, $bits)
    }

# Returns a version number "a.b.c.d" as a two-element numeric
# array. The first array element is the most significant 32 bits,
# and the second element is the least significant 32 bits.
function GetVersionStringAsArray([String] $version) 
{
    $parts = $version.Split(".")
    if ($parts.Count -lt 4) 
    {
        for ($n = $parts.Count; $n -lt 4; $n++) 
        {
            $parts += "0"
        }
    }
    [UInt32] ((Lsh $parts[0] 16) + $parts[1])
    [UInt32] ((Lsh $parts[2] 16) + $parts[3])
}

 # Compares two version numbers "a.b.c.d". If $version1 < $version2,
# returns -1. If $version1 = $version2, returns 0. If
# $version1 > $version2, returns 1.
function CheckInstalledPowerShellVersion() 
    {
        $installedVersion = ((Get-Module Azure*).Version.Major -as [string]) +'.'+ ((Get-Module Azure*).Version.Minor -as [string]) +'.'+ ((Get-Module Azure*).Version.Build -as [string])        
        $minimumRequiredVersion = '1.0.1'        
        $ver1 =  $installedVersion
        $ver2 =  $minimumRequiredVersion
        if ($ver1[0] -lt $ver2[0]) 
        {
            $out = -1
        }
        elseif ($ver1[0] -eq $ver2[0]) 
        {
            if ($ver1[1] -lt $ver2[1]) 
            {
                $out = -1
            }
            elseif ($ver1[1] -eq $ver2[1]) 
            {
                $out = 0
            }
            else 
            {
                $out = 1
            }
        }
        else 
            {
                $out = 1
            }
        return $out
}