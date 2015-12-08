<#
.Synopsis
    WingtipTickets (WTT) Demo Environment.
 .DESCRIPTION
    This script is used to retrieve the Matching Geo Secondary Azure SQL Database Server Region.
 .EXAMPLE
    GetGeoSecondaryRegion -WTTEnvironmentApplicationName <string>
#>
function Get-WTTSqlDatabaseServerV12RegionAvailability()
{    
    [CmdletBinding()]
    Param 
    (
        [Parameter(Mandatory=$true)]
        [string]$WTTEnvironmentApplicationName,
        
        #Azure Active Directory Tenant Name
        [Parameter(Mandatory=$false)]
        [String]
        $AzureActiveDirectoryTenantName        
    )    
    $global:VerbosePreference = "SilentlyContinue"

    $azureStorageAccountAdministratorUserName = "developer"
    $azureStorageAccountAdministratorPassword = "P@ssword1"
    $AzureSqlDatabaseServerVersion = "12.0"
    $wTTEnvironmentPrimaryServerLocation = $null
    $wTTEnvironmentSecondaryServerLocation = $null    
    $wTTEnvironmentApplicationName = $WTTEnvironmentApplicationName
    
    if($AzureActiveDirectoryTenantName -eq "")
    {
        $azureSqlDatabaseServerV12RegionAvailabilityArray = Get-WTTAzureSqlDatabaseServerRegionCapabilities -AzureSqlDatabaseServerVersion $AzureSqlDatabaseServerVersion
    }
    else
    {
        $azureSqlDatabaseServerV12RegionAvailabilityArray = Get-WTTAzureSqlDatabaseServerRegionCapabilities -AzureSqlDatabaseServerVersion $AzureSqlDatabaseServerVersion -AzureActiveDirectoryTenantName $AzureActiveDirectoryTenantName
    }
    
    foreach ($azureDatacenterLocation in $azureSqlDatabaseServerV12RegionAvailabilityArray)
    {               
        
        $wTTEnvironmentApplicationNameWithIndex =  $wTTEnvironmentApplicationName + $azureSqlDatabaseServerV12RegionAvailabilityArray.IndexOf($azureDatacenterLocation)        
        $azureStorageAccountPrimaryName = $wTTEnvironmentApplicationName + $azureSqlDatabaseServerV12RegionAvailabilityArray.IndexOf($azureDatacenterLocation) + "primary"
        $azureStorageAccountResourceGroupName = $wTTEnvironmentApplicationName + $azureSqlDatabaseServerV12RegionAvailabilityArray.IndexOf($azureDatacenterLocation)        
    
        $wTTEnvironmentPrimaryServerLocation = $azureDatacenterLocation                
        
        if ((AzureStorageAccountExists -AzureStorageAccountName $azureStorageAccountPrimaryName -AzureStorageAccountResourceGroupName $azureStorageAccountResourceGroupName))
        {
            break
        }
        # ******  Create Azure Storage Account ******
        else
        {
            Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue

            Write-Host "### Creating Test Azure Resource Group '$wTTEnvironmentApplicationNameWithIndex' in Primary region '$wTTEnvironmentPrimaryServerLocation'. ###" -foregroundcolor "yellow"
            $newAzureResourceGroup = New-AzureResourceGroup -Name $azureStorageAccountResourceGroupName -Location $wTTEnvironmentPrimaryServerLocation

            Write-Host "### Creating Test Azure Storage Account '$wTTEnvironmentApplicationNameWithIndex' in Primary region '$wTTEnvironmentPrimaryServerLocation' to obtain Matching Geo Secondary region. ###" -foregroundcolor "yellow"
            $newAzureStorageAccount = New-AzureStorageAccount -ResourceGroupName $azureStorageAccountResourceGroupName -Name $wTTEnvironmentApplicationNameWithIndex -Location $wTTEnvironmentPrimaryServerLocation -Type "Standard_GRS"
            If($newAzureStorageAccount.Count -gt 0) 
            {
                Write-Host "### Success: New Test Azure Storage Account '$wTTEnvironmentApplicationNameWithIndex' created. ###" -foregroundcolor "yellow"

                Write-Host "### Retrieving Matching Geo Secondary region from Test Azure Storage Account '$wTTEnvironmentApplicationNameWithIndex'. ###" -foregroundcolor "yellow"
                $wTTEnvironmentSecondaryServerLocation = (Get-AzureStorageAccount -ResourceGroupName $wTTEnvironmentApplicationNameWithIndex -StorageAccountName $wTTEnvironmentApplicationNameWithIndex).SecondaryLocation                    
                                
                Write-Host "### Verifying Matching Geo Secondary region '$wTTEnvironmentSecondaryServerLocation' has Azure SQL Database Server version 12.0 Capacity for your subscription. ###" -foregroundcolor "yellow"                
                                
                If($azureSqlDatabaseServerV12RegionAvailabilityArray.Contains($wTTEnvironmentSecondaryServerLocation)) 
                {
                    Write-Host "### Success: Matching Geo Secondary Region '$wTTEnvironmentSecondaryServerLocation' has Azure SQL Database Server version 12.0 Capacity for your subscription. ###" -foregroundcolor "yellow"                                        
                    
                    Write-Host "### Removing '$azureStorageAccountResourceGroupName' Test Resource Group and all related resources. ###" -foregroundcolor "yellow"    
                    $null = Remove-AzureResourceGroup -Name $azureStorageAccountResourceGroupName -Force -PassThru                             
                    
                    return $wTTEnvironmentPrimaryServerLocation, $wTTEnvironmentSecondaryServerLocation
                    break
                }                
                Write-Host "### Removing '$azureStorageAccountResourceGroupName' Test Resource Group and all related resources. ###" -foregroundcolor "yellow"    
                $null = Remove-AzureResourceGroup -Name $azureStorageAccountResourceGroupName -Force -PassThru                             
	        }
            else
            {
                Write-Host "### Removing '$azureStorageAccountResourceGroupName' Test Resource Group and all related resources. ###" -foregroundcolor "yellow"    
                $null = Remove-AzureResourceGroup -Name $azureStorageAccountResourceGroupName -Force -PassThru
            }
            
        }        
    }  
}

function AzureStorageAccountExists()
{
    [CmdletBinding()]
    Param 
    (
        [Parameter(Mandatory=$true)]
        [String]$AzureStorageAccountName,
        [Parameter(Mandatory=$true)]
        [String]$AzureStorageAccountResourceGroupName
        
    )
    Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue

    $azureStorageAccountName = $AzureStorageAccountName    
    ### Check if Azure Storage Account Exists ###
    Write-Host "### Checking whether Test Azure Storage Account '$azureStorageAccountName' already exists. ###" -foregroundcolor "yellow"
    $azureStorageAccountExists = Get-AzureStorageAccount -Name $AzureStorageAccountName -ResourceGroupName $AzureStorageAccountResourceGroupName -ErrorVariable azureStorageAccountExistsErrors -ErrorAction SilentlyContinue
                    
    If($azureStorageAccountExists.Count -gt 0) 
    {
        Write-Host "### Test Azure Storage Account '$azureStorageAccountName' already exists.  Please use a unique Storage Account name. ###" -foregroundcolor "red"
        $out = 1
    }
    else
    {
        
        Write-Host "### Test Azure Storage Account '$azureStorageAccountName' doesn't exist. ###" -foregroundcolor "yellow"
        $out = 0            
    }                    
    return $out
}