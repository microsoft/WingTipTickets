<#
.Synopsis
    Azure Storage operation.
 .DESCRIPTION
    This script is used to create an object in Azure Storage.
 .EXAMPLE
    New-WTTStorageAccount -Name <string> -Location <location>
#>
function New-WTTStorageAccount
{
    [CmdletBinding()]
    Param
    (    
        # Azure Storage Account Name
        [Parameter(Mandatory=$true)]
        [String] $Name,

        # Azure Storage Location
        [Parameter(Mandatory=$true, HelpMessage="Please specify location for AzureSQL server ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String] $Location
    )
    Process
    { 
        Try 
        {
			#COMMENT THIS OUT AFTER
			#Add-AzureAccount   
			#Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue
			
            ### Check Azure Storage Account ###
            Write-Host "### Checking whether Azure Storage Account '$Name' already exists. ###" -foregroundcolor "yellow"
            $azureStorageAccountExists = (Test-AzureName -Storage -Name $Name)
			
            if(!$azureStorageAccountExists)
            {
                # ******  Create Azure Storage Account If Doesn't Already Exist ******
                Write-Host "### Creating new Azure Storage Account '$Name' ###" -foregroundcolor "yellow"
                $newAzureStorageAccount = New-AzureStorageAccount -StorageAccountName $Name -Description $Name -Location $Location
				
                if($newAzureStorageAccount.OperationStatus -eq "Succeeded")
                {
                    Write-Host "### Success: New Azure Storage Account '$Name' created. ###" -foregroundcolor "green"
                }
                elseif($newAzureStorageAccount.OperationStatus -eq "Failed")
                {
                    Write-Host "### Failure: New Azure Storage Account '$Name' not created. ###" -foregroundcolor "red"
                }
            }
            elseif($azureStorageAccountExists)
            {
                Write-Host "### Azure Storage Account '$Name' already exists. ###" -foregroundcolor "yellow"
            }            
        }
        Catch
        {
	        Write-Error "Error: $Error "
        }  	    
   }
 }