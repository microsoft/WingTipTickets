<#
.Synopsis
    Azure SQL Database Server operation.
 .DESCRIPTION
    This script is used to create an Azure SQL Database Server.
 .EXAMPLE
    New-WTTDatabaseServer -ServerName <serverName> -Location <location> -UserName <userName> -Password <password> -ServerVersion <serverVersion> -ResourceGroupName <resourceGroupName>
#>
function New-WTTDatabaseServer
{
    [CmdletBinding()]
    Param
    (    
        # SQL Database Server Name
        [Parameter(Mandatory=$true)]
        [String]
        $ServerName,

        # SQL Database Server Location
        [Parameter(Mandatory=$true, HelpMessage="Please specify location for Azure SQL Database Server ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String]
        $Location,

        # SQL Database Server Administrator User Name
        [Parameter(Mandatory=$true)]
        [String]
        $UserName,

        # SQL Database Server Adminstrator Password
        [Parameter(Mandatory=$true)]
        [String]
        $Password,
        
        # SQL Database Server Version
        [Parameter(Mandatory=$true, HelpMessage="Please specify the Azure SQL Database Server Version ('2.0', '12.0')?")]
        [ValidateSet('2.0', '12.0')]
        [String]
        $ServerVersion,
        
        # SQL Database Server Resource Group Name
        [Parameter(Mandatory=$true)]
        [String]
        $ResourceGroupName
    )
    Process
    { 
    	#COMMENT THIS OUT AFTER
		#Add-AzureAccount   
		Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
 
		# Check if Azure Resource Group Exists
        Try 
        {
            #Write-Host "### Checking whether Azure Resource Group '$ResourceGroupName' already exists. ###" -foregroundcolor "yellow"
            $ResourceGroupNameExists = Get-AzureResourceGroup -Name $ResourceGroupName -ErrorVariable ResourceGroupNameExistsErrors -ErrorAction SilentlyContinue
            If($ResourceGroupNameExists.Count -gt 0) 
            {
                #Write-Host "### Azure Resource Group '$ResourceGroupName' exists. ###" -foregroundcolor "yellow"

                ### Check if Azure SQL Database Server Exists ###
                Write-Host "### Checking whether Azure SQL Database Server '$ServerName' already exists. ###" -foregroundcolor "yellow"
                $DatabaseServerExists = Get-AzureSqlServer -ServerName $ServerName -ResourceGroupName $ResourceGroupName -ErrorVariable DatabaseServerExistsErrors -ErrorAction SilentlyContinue
				
                If($DatabaseServerExists.ServerName -eq $ServerName) 
                {
                    Write-Host "### Azure SQL Database Server '$ServerName' already exists. ###" -foregroundcolor "yellow"
                }
                else
                {
					# ******  Create Azure SQL Database Server ******
                    Write-Host "### Azure SQL Database Server '$ServerName' does not exist. ###" -foregroundcolor "yellow"
                    Write-Host "### Creating Azure SQL Database Server '$ServerName'. ###" -foregroundcolor "yellow"

                    $sqlAdministratorCredentials = new-object System.Management.Automation.PSCredential($UserName, ($Password | ConvertTo-SecureString -asPlainText -Force))
                    $newAzureSqlDatabaseServer = New-AzureSqlServer -ResourceGroupName $ResourceGroupName -ServerName $ServerName -Location $Location -ServerVersion $ServerVersion –SqlAdministratorCredentials $sqlAdministratorCredentials -ErrorVariable newAzureSqlDatabaseServerErrors -ErrorAction SilentlyContinue

                    If($newAzureSqlDatabaseServer.ServerName -eq $ServerName) 
                    {
                        Write-Host "### Success: New Azure SQL Server '$ServerName' created. ###" -foregroundcolor "green"

                        Write-Host "### Adding firewall rule to allow access from ALL IP addresses ###" -foregroundcolor "yellow"
                        $newAzureSqlFirewallRule1 = New-AzureSqlServerFirewallRule -FirewallRuleName AllOpen -StartIPAddress 0.0.0.0 -EndIPAddress 255.255.255.255 -ServerName $ServerName -ResourceGroup $ResourceGroupName -ErrorVariable newAzureSqlFirewallRule1Errors -ErrorAction SilentlyContinue
                        #Write-Host "Success: Firewall rule updated..." -foregroundcolor "green"

                        Write-Host "### Adding firewall rule to allow ALL Azure Services access ###" -foregroundcolor "yellow"                    
                        $newAzureSqlFirewallRule2 = New-AzureSqlServerFirewallRule -AllowAllAzureIPs -ServerName $ServerName -ResourceGroup $ResourceGroupName -ErrorVariable newAzureSqlFirewallRule2Errors -ErrorAction SilentlyContinue
                        #Write-Host "Success: Firewall rule updated..." -foregroundcolor "green"
                    }
					else 
					{
						Write-Host "### Error: Could not create database server set ###" -foregroundcolor "red"
						
					}

	            }
            }
            elseif($DatabaseServerExists.Count -eq 0)
            {
                Write-Host "### Azure Resource Group '$ResourceGroupName' does not exist.  Please run New-AzureResourceGroup.ps1 first. ###" -foregroundcolor "yellow"
	        }
        }
        Catch
        {
            Write-Error "Error: $Error "            
        }
    }
 }
