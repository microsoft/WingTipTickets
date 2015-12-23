<#
.Synopsis
    Azure SQL Database Server operation.
 .DESCRIPTION
    This script is used to create an Azure SQL Database Server.
 .EXAMPLE
    New-WTTAzureSqlDatabaseServer -AzureSqlDatabaseServerName <string> -AzureSqlDatabaseServerLocation <location> -AzureSqlDatabaseServerAdministratorUserName <string> -AzureSqlDatabaseServerAdministratorPassword <string> -AzureSqlDatabaseServerVersion <version> -AzureSqlDatabaseServerResourceGroupName <string>
#>
function New-WTTAzureSqlDatabaseServer
{
    [CmdletBinding()]
    Param
    (    
        #Azure SQL Database Server Name
        [Parameter(Mandatory=$true)]
        [String]
        $AzureSqlDatabaseServerName,

        #Azure SQL Database Server Location
        [Parameter(Mandatory=$true, HelpMessage="Please specify location for Azure SQL Database Server ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String]
        $AzureSqlDatabaseServerLocation,

        #Azure SQL Database Server Administrator User Name
        [Parameter(Mandatory=$true)]
        [String]
        $AzureSqlDatabaseServerAdministratorUserName,

        #Azure SQL Database Server Adminstrator Password
        [Parameter(Mandatory=$true)]
        [String]
        $AzureSqlDatabaseServerAdministratorPassword,
        
        #Azure SQL Database Server Version
        [Parameter(Mandatory=$true, HelpMessage="Please specify the Azure SQL Database Server Version ('2.0', '12.0')?")]
        [ValidateSet('2.0', '12.0')]
        [String]
        $AzureSqlDatabaseServerVersion,
        
        #Azure SQL Database Server Resource Group Name
        [Parameter(Mandatory=$true)]
        [String]
        $AzureSqlDatabaseServerResourceGroupName
    )
    Process
    { 
    	#Add-AzureAccount
    
 
       ### Check if Azure Resource Group Exists ###
        Try 
        {
            #Write-Host "### Checking whether Azure Resource Group '$AzureSqlDatabaseServerResourceGroupName' already exists. ###" -foregroundcolor "yellow"
            #$azureSqlDatabaseServerResourceGroupNameExists = Get-AzureResourceGroup -Name $AzureSqlDatabaseServerResourceGroupName -ErrorVariable azureSqlDatabaseServerResourceGroupNameExistsErrors -ErrorAction SilentlyContinue
            $azureSqlDatabaseServerResourceGroupNameExists = Get-AzureRMResourceGroup -Name $AzureSqlDatabaseServerResourceGroupName -ErrorVariable azureSqlDatabaseServerResourceGroupNameExistsErrors -ErrorAction SilentlyContinue
			If($azureSqlDatabaseServerResourceGroupNameExists.Count -gt 0) 
            {
                #Write-Host "### Azure Resource Group '$AzureSqlDatabaseServerResourceGroupName' exists. ###" -foregroundcolor "yellow"

                ### Check if Azure SQL Database Server Exists ###
                Write-Host "### Checking whether Azure SQL Database Server '$AzureSqlDatabaseServerName' already exists. ###" -foregroundcolor "yellow"
                #$azureSqlDatabaseServerExists = Get-AzureSqlServer -ServerName $AzureSqlDatabaseServerName -ResourceGroupName $AzureSqlDatabaseServerResourceGroupName -ErrorVariable azureSqlDatabaseServerExistsErrors -ErrorAction SilentlyContinue
				$azureSqlDatabaseServerExists = Get-AzureRMSqlServer -ServerName $AzureSqlDatabaseServerName -ResourceGroupName $AzureSqlDatabaseServerResourceGroupName -ErrorVariable azureSqlDatabaseServerExistsErrors -ErrorAction SilentlyContinue
                If($azureSqlDatabaseServerExists.ServerName -eq $AzureSqlDatabaseServerName) 
                {
                    Write-Host "### Azure SQL Database Server '$AzureSqlDatabaseServerName' already exists. ###" -foregroundcolor "yellow"
                }
                # ******  Create Azure SQL Database Server ******
                else
                {
                    Write-Host "### Azure SQL Database Server '$AzureSqlDatabaseServerName' does not exist. ###" -foregroundcolor "yellow"
                    Write-Host "### Creating Azure SQL Database Server '$AzureSqlDatabaseServerName'. ###" -foregroundcolor "yellow"

                    $sqlAdministratorCredentials = new-object System.Management.Automation.PSCredential($AzureSqlDatabaseServerAdministratorUserName, ($AzureSqlDatabaseServerAdministratorPassword | ConvertTo-SecureString -asPlainText -Force))
                    #$newAzureSqlDatabaseServer = New-AzureSqlServer -ResourceGroupName $AzureSqlDatabaseServerResourceGroupName -ServerName $AzureSqlDatabaseServerName -Location $AzureSqlDatabaseServerLocation -ServerVersion $AzureSqlDatabaseServerVersion –SqlAdministratorCredentials $sqlAdministratorCredentials -ErrorVariable newAzureSqlDatabaseServerErrors -ErrorAction SilentlyContinue
					$newAzureSqlDatabaseServer = New-AzureRMSqlServer -ResourceGroupName $AzureSqlDatabaseServerResourceGroupName -ServerName $AzureSqlDatabaseServerName -Location $AzureSqlDatabaseServerLocation -ServerVersion $AzureSqlDatabaseServerVersion –SqlAdministratorCredentials $sqlAdministratorCredentials -ErrorVariable newAzureSqlDatabaseServerErrors -ErrorAction SilentlyContinue
					
                    #$azureSqlDatabaseServerExists = Get-AzureSqlServer -ServerName $AzureSqlDatabaseServerName -ResourceGroupName $AzureSqlDatabaseServerResourceGroupName
                
                    If($newAzureSqlDatabaseServer.ServerName -eq $AzureSqlDatabaseServerName) 
                    {
                        Write-Host "### Success: New Azure SQL Server '$AzureSqlDatabaseServerName' created. ###" -foregroundcolor "green"

                        Write-Host "### Adding firewall rule to allow access from ALL IP addresses ###" -foregroundcolor "yellow"
                        #$newAzureSqlFirewallRule1 = New-AzureSqlServerFirewallRule -FirewallRuleName AllOpen -StartIPAddress 0.0.0.0 -EndIPAddress 255.255.255.255 -ServerName $AzureSqlDatabaseServerName -ResourceGroup $AzureSqlDatabaseServerResourceGroupName -WarningVariable newAzureSqlFirewallRule1Errors -WarningAction SilentlyContinue
						$newAzureSqlFirewallRule1 = New-AzureRMSqlServerFirewallRule -FirewallRuleName AllOpen -StartIPAddress 0.0.0.0 -EndIPAddress 255.255.255.255 -ServerName $AzureSqlDatabaseServerName -ResourceGroup $AzureSqlDatabaseServerResourceGroupName -WarningVariable newAzureSqlFirewallRule1Errors -WarningAction SilentlyContinue
                        #Write-Host "Success: Firewall rule updated..." -foregroundcolor "green"

                        Write-Host "### Adding firewall rule to allow ALL Azure Services access ###" -foregroundcolor "yellow"                    
                        #$newAzureSqlFirewallRule2 = New-AzureSqlServerFirewallRule -AllowAllAzureIPs -ServerName $AzureSqlDatabaseServerName -ResourceGroup $AzureSqlDatabaseServerResourceGroupName -WarningVariable newAzureSqlFirewallRule2Errors -WarningAction SilentlyContinue
						$newAzureSqlFirewallRule2 = New-AzureRMSqlServerFirewallRule -AllowAllAzureIPs -ServerName $AzureSqlDatabaseServerName -ResourceGroup $AzureSqlDatabaseServerResourceGroupName -WarningVariable newAzureSqlFirewallRule2Errors -WarningAction SilentlyContinue
                        #Write-Host "Success: Firewall rule updated..." -foregroundcolor "green"
                    }

	            }
            }
            elseif($azureSqlDatabaseServerResourceGroupNameExists.Count -eq 0)
            {
                Write-Host "### Azure Resource Group '$AzureSqlDatabaseServerResourceGroupName' does not exist.  Please run New-WTTAzureResourceGroup.ps1 first. ###" -foregroundcolor "yellow"
	        }
        }
        Catch
        {
            Write-Error "Error: $Error "            
        }
    }
 }
