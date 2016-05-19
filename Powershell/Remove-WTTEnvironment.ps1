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
        $azureResourceGroupName = $wTTEnvironmentApplicationName 
                
        Try 
        {
            
            ### Silence Verbose Output ###
           $global:VerbosePreference = "SilentlyContinue"

            ### Check installed PowerShell Version ###
           	WriteLabel("Checking for Azure PowerShell Version 1.0.1 or later")
			if($installedAzurePowerShellVersion -lt 1)
			{
	            $module = Get-Module AzureRM.profile
	            $installedAzurePowerShellVersion = CheckInstalledPowerShell $module
	            if ($installedAzurePowerShellVersion -gt 0)
	            {
		            WriteValue("Done")
	            }
	            else
	            {
		            WriteValue("Failed")
		            WriteError("Make sure that you are signed in and that PowerShell is not older than version 1.0.1.")
		            WriteError("Please install from: http://azure.microsoft.com/en-us/downloads/, under Command-line tools, under Windows PowerShell, click Install")
		            break
	            }
			}                               
            #Remove Azure Resource Group
            WriteLabel("Removing Azure Resource Group '$wTTEnvironmentApplicationName'.")
            $azureResourceGroupRemoved = Remove-AzureRMResourceGroup -Name $azureResourceGroupName -Force -ErrorAction SilentlyContinue -ErrorVariable azureResourceGroupRemovedErrors
               
            if ($azureResourceGroupRemoved)
            {
                WriteValue("Done")
            }
            else
            {
                foreach ($error in $azureResourceGroupRemovedErrors)
                {
                    [string]$exception = $error.Exception
                    if($exception.Contains("does not exist"))
                    {
                        WriteError("Azure Resource Group '$wTTEnvironmentApplicationName' doesn't exist.")
                    }                    
                    else
                    {
                        WriteError("Error: Azure Resource Group '$wTTEnvironmentApplicationName' was not removed because: '$error'.")
                    }
                }
             }          
            
        }
        Catch
        {
	        WriteError("Error: $Error ")
        } 	    
   }
 }


function IIf($If, $Right, $Wrong) 
{
	If ($If) 
	{
		return $Right
	}
	Else
	{
		return $Wrong
	}
}

function LineBreak()
{
	Write-Host ""
}

function WriteLine($label)
{
	Write-Host $label
}

function WriteLabel($label)
{
	Write-Host $label": " -nonewline -foregroundcolor "yellow"
}

function WriteValue($value)
{
	Write-Host $value
}

function WriteError($error)
{
	Write-Host "Error:" $error -foregroundcolor "red"
}

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
	if ($parts.Count -lt 3) 
	{
		for ($n = $parts.Count; $n -lt 3; $n++) 
		{
			$parts += "0"
		}
	}
	[UInt32] ((Lsh $parts[0] 16))
	[UInt32] ((Lsh $parts[1] 16))
	[UInt32] ((Lsh $parts[2] 16))
}

# Compares two version numbers "a.b.c.d". If $version1 < $version2,
# returns -1. If $version1 = $version2, returns 0. If
# $version1 > $version2, returns 1.
function CheckInstalledPowerShell($module)
{
	$installedVersion = $module
	$installedVersionVersion = $installedVersion.Version
	$installedVersionVersion = $installedVersionVersion -replace '\s',''
	$minimumRequiredVersion = '1.0.1'
	$ver1 = GetVersionStringAsArray $installedVersionVersion
	$ver2 = GetVersionStringAsArray $minimumRequiredVersion
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
		elseif ($ver1[1] -ge $ver2[1]) 
		{
			$out = 1
		}
	} 
	elseif ($ver1[2] -gt $ver2[2])
	{
		$out = 1
	}    
	else 
	{
		$out = 1
	}

	return $out   
}