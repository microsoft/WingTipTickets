<#
.Synopsis
    Azure Resource Group operation.
 .DESCRIPTION
    This script is used to create a new Azure Resource Group.
 .EXAMPLE
    New-WTTAzureResourceGroup -AzureResourceGroupLocation <location> -AzureResourceGroupName <string>
#>
function New-WTTAzureResourceGroup
{
    [CmdletBinding()]
    Param
    (           
        #Azure Resource Group Name
        [Parameter(Mandatory=$true)]
        [String]
        $AzureResourceGroupName,
        
        #Azure Resource Group Location
        [Parameter(Mandatory=$true, HelpMessage="Please specify a location for your Azure Resource Group ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String]
        $AzureResourceGroupLocation
    )
    Process
    { 
    	#Add-AzureAccount
    
 
       ### Check if Azure Resource Group Exists ###
        Try 
        {
            Write-Host "### Checking whether Azure Resource Group '$AzureResourceGroupName' already exists. ###" -foregroundcolor "yellow"
            $azureResourceGroupNameExists = Get-AzureResourceGroup -Name $AzureResourceGroupName -ErrorVariable azureResourceGroupNameExistsErrors -ErrorAction SilentlyContinue
            If($azureResourceGroupNameExists.Count -gt 0) 
            {
                Write-Host "### Azure Resource Group '$AzureResourceGroupName' exists. ###" -foregroundcolor "yellow"
            }
            
            # ******  Create Azure Resource Group ******
            else
            {
                Write-Host "### Azure Resource Group '$AzureResourceGroupName' does not exist. ###" -foregroundcolor "yellow"
                Write-Host "### Creating New Azure Resource Group '$AzureResourceGroupName'. ###" -foregroundcolor "yellow"

                $newAzureResourceGroup = New-AzureResourceGroup -Name $AzureResourceGroupName -Location $AzureResourceGroupLocation -ErrorVariable newAzureResourceGroupErrors -ErrorAction SilentlyContinue

                $AzureResourceGroupNameExists = Get-AzureResourceGroup -Name $AzureResourceGroupName -ErrorVariable AzureResourceGroupNameExistsErrors -ErrorAction SilentlyContinue
                
                If($AzureResourceGroupNameExists.Count -gt 0) 
                {
                    Write-Host "### Success: New Azure Resource Group '$AzureResourceGroupName' created. ###" -foregroundcolor "green"
                }
	        }
        }
        Catch
        {
            Write-Error "Error: $Error "            
        }

   }
 }
