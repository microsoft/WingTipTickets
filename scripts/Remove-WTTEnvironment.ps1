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
        $azureStorageAccountName = $WTTEnvironmentApplicationName
        $azureSqlDatabaseServerPrimaryName = $WTTEnvironmentApplicationName + "primary"
        $azureSqlDatabaseServerSecondaryName = $WTTEnvironmentApplicationName + "secondary"        
        $azureResourceGroupName = $WTTEnvironmentApplicationName
        $azureCloudServicePrimaryName = $WTTEnvironmentApplicationName + "primary"
        $azureCloudServiceSecondaryName = $WTTEnvironmentApplicationName + "secondary"      

        
        Try 
        {
            
            ### Silence Verbose Output ###
            Write-Host "### Silencing Verbose Output. ###" -foregroundcolor "yellow"
            $global:VerbosePreference = "SilentlyContinue"

            ### Check installed PowerShell Version ###
            Write-Host "### Checking whether installed Azure PowerShell Version is at least 0.9.5. ###" -foregroundcolor "yellow"
                        
            $installedAzurePowerShellVersion = CheckInstalledPowerShellVersion
            if ($installedAzurePowerShellVersion -ge 0)
            {
                Write-Host "### Installed Azure PowerShell Version is at least 0.9.5. ###" -foregroundcolor "yellow"

                ### Check if both ASM and ARM are provisioned ###
                Write-Host "### Checking whether Azure Service Model (ASM) and Azure Resource Model (ARM) are provisioned. ###" -foregroundcolor "yellow"
                $supportedModes = (Get-AzureSubscription -Current).SupportedModes.Split(",")
                if ($supportedModes.Count -eq 2)
                {
                    Write-Host "### Both Azure Service Model (ASM) and Azure Resource Model (ARM) are provisioned. ###" -foregroundcolor "yellow"                    
                    
                    Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
                                                                        
                    #Remove Azure Resource Group
                    Write-Host "### Removing Azure Resource Group '$WTTEnvironmentApplicationName'. ###" -foregroundcolor "yellow"
                    $azureResourceGroupRemoved = (Remove-AzureResourceGroup -Name $azureResourceGroupName -Force -PassThru -ErrorAction SilentlyContinue -ErrorVariable azureResourceGroupRemovedErrors)
                    
                    if ($azureResourceGroupRemoved)
                    {
                        Write-Host "### Success: Azure Resource Group '$WTTEnvironmentApplicationName' removed. ###" -foregroundcolor "green"
                    }
                    else
                    {
                        foreach ($error in $azureResourceGroupRemovedErrors)
                        {
                            [string]$exception = $error.Exception
                            if($exception.Contains("does not exist"))
                            {
                                Write-Host "### Azure Resource Group '$WTTEnvironmentApplicationName' doesn't exist. ###" -foregroundcolor "yellow"
                            }                    
                                else
                            {
                                Write-Host "### Error: Azure Resource Group '$WTTEnvironmentApplicationName' was not removed because: '$error'. ###" -foregroundcolor "red"                                                        
                            }
                        }
                    }
                                
                    Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue
                    
                    #Remove Traffic Manager Profile
                    Write-Host "### Removing Azure Traffic Manager Profile '$WTTEnvironmentApplicationName'. ###" -foregroundcolor "yellow"
                    $azureTrafficManagerProfileRemoved = (Remove-AzureTrafficManagerProfile -Name $WTTEnvironmentApplicationName -Force -PassThru -ErrorAction SilentlyContinue -ErrorVariable azureTrafficManagerProfileRemovedErrors)
                                        
                    if ($azureTrafficManagerProfileRemoved)
                    {
                        Write-Host "### Success: Azure Traffic Manager Profile '$WTTEnvironmentApplicationName' removed. ###" -foregroundcolor "green"
                    }
                    else
                    {
                        foreach ($error in $azureTrafficManagerProfileRemovedErrors)
                        {
                            [string]$exception = $error.Exception
                            if($exception.Contains("does not exist"))
                            {
                                Write-Host "### Azure Traffic Manager Profile '$WTTEnvironmentApplicationName' doesn't exist. ###" -foregroundcolor "yellow"
                            }                    
                                else
                            {
                                Write-Host "### Error: Azure Cloud Service '$azureCloudServiceSecondaryName' was not removed because: '$error'. ###" -foregroundcolor "red"
                            }
                        }                      
                    }                                          
                }

                else
                {
                    ### Error if both ASM and ARM aren't provisioned ###
                    Write-Host "### Error: Both Azure Service Model (ASM) and Azure Resource Model (ARM) need to be provisioned. ###" -foregroundcolor "red"
                    Write-Host "### You can run: (Get-AzureSubscription -Default).SupportedModes to verify which is/isn't provisioned. ###" -foregroundcolor "red"
                    Write-Host "### Please contact Microsoft Support to have them troubleshoot further. ###" -foregroundcolor "red"
                }
            }
            else
            {
                ### Error if installed Azure PowerShell Version is older than minimum required version ###
                Write-Host "### Error: Installed Azure PowerShell Version is older than 0.9.5.  Please install the latest version from: ###" -foregroundcolor "red"
                Write-Host "### http://azure.microsoft.com/en-us/downloads/, under Command-line tools, under Windows PowerShell, click Install ###" -foregroundcolor "red"
            }
            
        }
        Catch
        {
	        Write-Error "Error: $Error "
        }  	    
   }
 }
