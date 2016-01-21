<#
.Synopsis
    Azure Storage Account operation.
 .DESCRIPTION
    This script is used to create an Azure Storage Account.
 .EXAMPLE
    New-WTTAzureStorageAccount -AzureStorageAccountResourceGroupName <string> -AzureStorageAccountName <string> -AzureStorageAccountType <type> -AzureStorageLocation <location>
#>
function New-WTTAzureStorageAccount
{
    [CmdletBinding()]
    Param
    (    
        #Azure Resource Group Name
        [Parameter(Mandatory=$true)]
        [String] $AzureStorageAccountResourceGroupName,

        #Azure Storage Account Name
        [Parameter(Mandatory=$true)]
        [String] $AzureStorageAccountName,
        
        #Azure Storage Account Type
        [Parameter(Mandatory=$true)]
        [String] $AzureStorageAccountType,

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
            ### Check if Azure Storage Account Exists ###
            Write-Host "### Checking whether Azure Storage Account '$AzureStorageAccountName' already exists. ###" -foregroundcolor "yellow"
            #$azureStorageAccountExists = Get-AzureStorageAccount -Name $AzureStorageAccountName -ResourceGroupName $AzureStorageAccountResourceGroupName -ErrorVariable azureStorageAccountExistsErrors -ErrorAction SilentlyContinue
			$azureStorageAccount = Find-AzureRmResource -ResourceType "Microsoft.Storage/storageaccounts" -ResourceNameContains $AzureStorageAccountName -ResourceGroupNameContains $AzureStorageAccountResourceGroupName

            if($azureStorageAccount -eq $null)
            {                
                Write-Host "### Azure Storage Account '$AzureStorageAccountName' does not exist. ###" -foregroundcolor "yellow"
                Write-Host "### Creating new Azure Storage Account '$AzureStorageAccountName' ###" -foregroundcolor "yellow"
                #$newAzureStorageAccount = New-AzureStorageAccount -ResourceGroupName $AzureStorageAccountResourceGroupName -Name $AzureStorageAccountName -Type $AzureStorageAccountType -Location $AzureStorageLocation
				$newAzureStorageAccount = New-AzureRMStorageAccount -ResourceGroupName $AzureStorageAccountResourceGroupName -Name $AzureStorageAccountName -Type $AzureStorageAccountType -Location $AzureStorageLocation
                if($newAzureStorageAccount.Count -gt 0)
                {
                    Write-Host "### Success: New Azure Storage Account '$AzureStorageAccountName' created. ###" -foregroundcolor "green"
                }
                elseif($newAzureStorageAccount.OperationStatus -eq "Failed")
                {
                    Write-Host "### Failure: New Azure Storage Account '$AzureStorageAccountName' not created. ###" -foregroundcolor "red"
                }
            }
            elseif($azureStorageAccount)
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