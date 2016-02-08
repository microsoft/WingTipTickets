<#
.Synopsis
    Azure Storage operation.
 .DESCRIPTION
    This script is used to create an object in Azure Storage.
 .EXAMPLE
    New-WTTAzureStorageAccountASM -AzureStorageAccountName <string> -AzureStorageLocation <location>
#>
function New-WTTAzureStorageAccountASM
{
    [CmdletBinding()]
    Param
    (    
        #Azure Storage Account Name
        [Parameter(Mandatory=$true)]
        [String] $AzureStorageAccountName,

        #Azure Storage Location
        [Parameter(Mandatory=$true, HelpMessage="Please specify location for AzureSQL server ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String] $AzureStorageLocation
    )
    Process
    { 
    	#Add-AzureAccount

        Try 
        {
            ### Check Azure Storage Account ###
            Write-Host "### Checking whether Azure Storage Account '$AzureStorageAccountName' already exists. ###" -foregroundcolor "yellow"
            $azureStorageAccountExists = Test-AzureName -storage $AzureStorageAccountName
            if(!$azureStorageAccountExists)
            {
                # ******  Create Azure Storage Account If Doesn't Already Exist ******
                Write-Host "### Creating new Azure Storage Account '$AzureStorageAccountName' ###" -foregroundcolor "yellow"
                $newAzureStorageAccount = New-AzureStorageAccount -StorageAccountName $AzureStorageAccountName -Description $AzureStorageAccountName -Location $AzureStorageLocation
                if($newAzureStorageAccount.OperationStatus -eq "Succeeded")
                {
                    Write-Host "### Success: New Azure Storage Account '$AzureStorageAccountName' created. ###" -foregroundcolor "green"
                }
                elseif($newAzureStorageAccount.OperationStatus -eq "Failed")
                {
                    Write-Host "### Failure: New Azure Storage Account '$AzureStorageAccountName' not created. ###" -foregroundcolor "red"
                }
            }
            elseif($azureStorageAccountExists)
            {
                Write-Host "### Azure Storage Account '$AzureStorageAccountName' already exists. ###" -foregroundcolor "yellow"
            }            
        }
        Catch
        {
	        Write-Error "Error: $Error "
        }  	    
   }
 }