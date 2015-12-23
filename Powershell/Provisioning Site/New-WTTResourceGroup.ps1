<#
.Synopsis
    Azure Resource Group operation.
 .DESCRIPTION
    This script is used to create a new Azure Resource Group.
 .EXAMPLE
    New-WTTResourceGroup -Location <location> -ResourceGroupName <string>
#>
function New-WTTResourceGroup
{
    [CmdletBinding()]
    Param
    (           
        # Azure Resource Group Name
        [Parameter(Mandatory=$true)]
        [String]
        $ResourceGroupName,
        
        # Azure Resource Group Location
        [Parameter(Mandatory=$true, HelpMessage="Please specify a location for your Azure Resource Group ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String]
        $Location
    )
    Process
    { 
        Try 
        {
			#COMMENT THIS OUT AFTER
			#Add-AzureAccount   
			#Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
		
			# Check if Azure Resource Group Exists
            Write-Host "### Checking whether Azure Resource Group '$ResourceGroupName' already exists. ###" -foregroundcolor "yellow"
            $ResourceGroupNameExists = Get-AzureResourceGroup -Name $ResourceGroupName -ErrorVariable ResourceGroupNameExistsErrors -ErrorAction SilentlyContinue
            If($ResourceGroupNameExists.Count -gt 0) 
            {
                Write-Host "### Azure Resource Group '$ResourceGroupName' exists. ###" -foregroundcolor "yellow"
            }
            else
            {
                Write-Host "### Azure Resource Group '$ResourceGroupName' does not exist. ###" -foregroundcolor "yellow"
                Write-Host "### Creating New Azure Resource Group '$ResourceGroupName'. ###" -foregroundcolor "yellow"

                $newAzureResourceGroup = New-AzureResourceGroup -Name $ResourceGroupName -Location $Location -ErrorVariable newAzureResourceGroupErrors -ErrorAction SilentlyContinue

                $ResourceGroupNameExists = Get-AzureResourceGroup -Name $ResourceGroupName -ErrorVariable ResourceGroupNameExistsErrors -ErrorAction SilentlyContinue
                
                If($ResourceGroupNameExists.Count -gt 0) 
                {
                    Write-Host "### Success: New Azure Resource Group '$ResourceGroupName' created. ###" -foregroundcolor "green"
                }
	        }
        }
        Catch
        {
            Write-Error "Error: $Error "            
        }
    }
 }
