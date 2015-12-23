<#
.Synopsis
    WingtipTickets (WTT) Demo Environment.
 .DESCRIPTION
    This script is used to create a new WingtipTickets (WTT) Provisioning Environment.
 .EXAMPLE
    New-WTTEnvironment 
#>
function New-WTTEnvironment
{
    [CmdletBinding()]
    Param
    (   
        # Application Name
        [Parameter(Mandatory=$true)]
        [String]
        $ApplicationName,

        # Location
        [Parameter(Mandatory=$false, HelpMessage="Please specify the location for your Provisioning Environment ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String]
        $Location,

        # SQL Administrator User-name
        [Parameter(Mandatory=$false)]
        [String]
        $UserName,

        # SQL Administrator Password
        [Parameter(Mandatory=$false)]
        [String]
        $Password,
        
        # Active Directory Tenant Name
        [Parameter(Mandatory=$false)]
        [String]
        $TenantName              
    )
    Process
    { 
		# Just clean the error buffer to erase old error messages
		$Error.Clear()

        #Set unspecified parameters
        if($UserName -eq "")
        {
            $UserName = "developer"
        }

        if($Password -eq "")
        {
            $Password = "P@ssword1"
        }

        #Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
		#Add-AzureAccount
		
		#Set fixed parameters
        $LocalPath = (Get-Item -Path ".\" -Verbose).FullName
		$SqlDatabaseServerExists = $null
		$WebSiteDeploymentPackagePath = (Get-Item -Path "..\..\" -Verbose).FullName + "\Packages\" + "TenantProvisioning.Mvc.zip"

		$WebSiteDeploymentPackageExists = (Test-Path $WebSiteDeploymentPackagePath)
		if(!$WebSiteDeploymentPackageExists){
			Write-Host "### Error: There is no web application package at '$WebSiteDeploymentPackagePath'." -ForegroundColor "red"		
			return 2	
		}

        Try 
        {
            # Silence Verbose Output
            Write-Host "### Silencing Verbose Output. ###" -foregroundcolor "yellow"
            $global:VerbosePreference = "SilentlyContinue"

            # Check installed PowerShell Version
            Write-Host "### Checking whether installed Azure PowerShell Version is at least 0.9.3. ###" -foregroundcolor "yellow"

            $InstalledAzurePowerShellVersion = CheckInstalledPowerShellVersion
            if ($InstalledAzurePowerShellVersion -ge 0)
            {
                Write-Host "### Installed Azure PowerShell Version is at least 0.9.3. ###" -foregroundcolor "yellow"

                # Get the current subscription
                Write-Host "### Getting the current Azure subscription ###" -foregroundcolor "yellow"

				$CurrentSubscription = (Get-AzureSubscription -Current)
                if (!$CurrentSubscription){
					Write-Host "### Error: There are no subscriptions to Azure currently available on this machine." -ForegroundColor "red"
					Write-Host "### To easily import your current subscription, please run 'Get-AzurePublishSettingsFile' and follow the instructions" -ForegroundColor "yellow"
					return 1
				}

                # Check if both ASM and ARM are provisioned
                Write-Host "### Checking whether Azure Service Model (ASM) and Azure Resource Model (ARM) are provisioned. ###" -foregroundcolor "yellow"                				
				$SupportedModes = $CurrentSubscription.SupportedModes.Split(",")
	
                if ($SupportedModes.Count -eq 2)
                {
                    Write-Host "### Both Azure Service Model (ASM) and Azure Resource Model (ARM) are provisioned. ###" -foregroundcolor "yellow"
                    
					# Unblock Files
                    Write-Host "### Unblocking all PowerShell Scripts in the '$LocalPath' folder. ###" -foregroundcolor "yellow"
                    Get-ChildItem -Path $LocalPath -Filter *.ps1 | Unblock-File                               

					# Load (DotSource) Scripts
                    Write-Host "### Loading all PowerShell Scripts in the '$LocalPath' folder. ###" -foregroundcolor "yellow"
                    Get-ChildItem -Path $LocalPath -Filter *.ps1 | ForEach { . $_.FullName }
                    
					# Check if Resource Group exists
                    Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
                    Write-Host "### Checking whether Azure Resource Group '$ApplicationName' already exists. ###" -foregroundcolor "yellow"
                    $ResourceGroupExists = Get-AzureResourceGroup -Name $ApplicationName -ErrorVariable ResourceGroupExistsErrors -ErrorAction SilentlyContinue
                    
					If($ResourceGroupExists.Count -gt 0) 
                    {
                        Write-Host "### Azure Resource Group '$ApplicationName' exists. ###" -foregroundcolor "green"

                        # Check if SQL Database Server Exists
                        Write-Host "### Checking whether SQL Database Server '$ApplicationName' already exists. ###" -foregroundcolor "yellow"
                        $SqlDatabaseServerExists = Get-AzureSqlServer -ServerName $ApplicationName -ResourceGroupName $ApplicationName -ErrorVariable SqlDatabaseServerExistsErrors -ErrorAction SilentlyContinue
                        
                        If($SqlDatabaseServerExists.Count -gt 0) 
                        {
                            Write-Host "### SQL Database Server '$ApplicationName' already exists. ###" -foregroundcolor "green"
                            $Location = $SqlDatabaseServerExists.Location
                        }                
                    }
					
					# Find a V12 Data Centre to Create SQL Database Server if not Exists
                    if ($Location -eq "")
                    {
                        Write-Host "### Finding a Data centre that has Azure SQL Database Server version 12.0 capacity for your subscription. ###" -foregroundcolor "yellow"
                        if($TenantName -eq "")
                        {
                            $SqlServerV12Location = Get-WTTSqlServerV12RegionAvailability -ApplicationName $ApplicationName
                        }
                        else
                        {
                            $SqlServerV12Location = Get-WTTSqlServerV12RegionAvailability -ApplicationName $ApplicationName -TenantName $TenantName
                        }

                        if ($SqlServerV12Location)
                        {
                            $Location = $SqlServerV12Location
                            Write-Host "### Data centre Region set to: '$Location'. ###" -foregroundcolor "green"
                        }
                        else
                        {
                            Write-Host "### Error: A Data centre Region that support Azure SQL Database Server version 12.0 could not be found for your subscription, please try a different subscription. ###" -foregroundcolor "red"
                            break
                        }
                    }
                                        
					# Create Azure Resource Group
                    Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
                    if ($ResourceGroupExists.Count -eq 0)
                    {						
                        New-WTTResourceGroup -ResourceGroupName $ApplicationName -Location $Location
                    }
            
                    # Create Storage Account
                    # For the 2.1 release, the ARM based Storage Account is switched back to an ASM based Storage Account as the Auditing team will be releasing new cmdlets in an upcoming release
                    # of Azure PowerShell that will support ARM based Storage Accounts.  Until then, they only support ASM based Storage Accounts.

                    Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue
					$ApplicationStorageAccount = $ApplicationName
					$ApplicationStorageAccount += "storage"

                    New-WTTStorageAccount -Name $ApplicationStorageAccount -Location $Location 
                    Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue                  
                    
					# Create Azure SQL Database Server if it doesn't already exist
                    if ($SqlDatabaseServerExists.Count -eq 0)
                    {
                        New-WTTDatabaseServer -ServerName $ApplicationName -Location $Location -UserName $UserName -Password $Password -ServerVersion "12.0" -ResourceGroupName $ApplicationName                        
                        $SqlDatabaseServerExists = Get-AzureSqlServer -ServerName $ApplicationName -ResourceGroupName $ApplicationName -ErrorVariable SqlDatabaseServerExistsErrors -ErrorAction SilentlyContinue                        
                    }

					# Deploy schema and data to the database server
                    if ($SqlDatabaseServerExists.Count -gt 0)
                    {   
                        Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue
                        Database-Schema -ServerName $ApplicationName -DatabaseEdition "Basic" -UserName $UserName -Password $Password -Location $Location -DatabaseName "WingTipTicketsProvisioningSite"            
                        Database-Populate -ServerName $ApplicationName -Username $UserName -Password $Password -DatabaseName "WingTipTicketsProvisioningSite"
                    }
                    
                    if ($Location -notcontains "")
                    {
						# Create Hosting Plan
                        Switch-AzureMode AzureResourceManager -WarningVariable null -WarningAction SilentlyContinue
                        Write-Host "### Creating Application Service Plan '$ApplicationName' if it doesn't already exist. ###" -foregroundcolor "yellow"
                        $null = New-AzureAppServicePlan -Location "$($Location)" -Sku Standard -ResourceGroupName $ApplicationName -Name $ApplicationName
                        
						# Create Web Application
						$ApplicationWebAppName = $ApplicationName

                        Write-Host "### Creating Application '$ApplicationWebAppName' in Application Service Plan '$ApplicationName' if it doesn't already exist. ###" -foregroundcolor "yellow"

                        $null = New-AzureWebApp -Location "$($Location)" -AppServicePlan $ApplicationName -ResourceGroupName $ApplicationName -Name $ApplicationWebAppName
                                                
                        Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue

						$connectionStrings = ( 	
							@{
								Name = "ProvisionSiteDb"; 
								Type = "SQLAzure"; 
								ConnectionString = "Data Source=$ApplicationName.database.windows.net;Initial Catalog=WingTipTicketsProvisioningSite;Integrated Security=False;User=$UserName@$ApplicationName;Password=$Password";								
							}	
						)

						Write-Host "### Setting Web Application parameters ###"
						Set-AzureWebsite -Name $ApplicationWebAppName -ConnectionStrings $connectionStrings

						# Deploy Web Application
                        Write-Host "### Deploying WebDeploy Package '$ApplicationName' to Application '$ApplicationWebAppName'. ###" -foregroundcolor "yellow"
                        Publish-AzureWebsiteProject -Name $ApplicationWebAppName -Package $WebSiteDeploymentPackagePath
						
                        Write-Host "### Successfully deployed Package '$ApplicationName' to Application '$ApplicationWebAppName'. ###" -foregroundcolor "green"		
							 
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
                Write-Host "### Error: Installed Azure PowerShell Version is older than 0.9.3.  Please install the latest version from: ###" -foregroundcolor "red"
                Write-Host "### http://azure.microsoft.com/en-us/downloads/, under Command-line tools, under Windows PowerShell, click Install ###" -foregroundcolor "red"
            }
            
        }
        Catch
        {
	        Write-Error "Error: $Error "
        }  	    
   }
 }
 
#Check Installed Azure PowerShell Version
# Bitwise left shift
function Lsh([UInt32] $n, [Byte] $bits) 
    {
        $n * [Math]::Pow(2, $bits)
    }

# Returns a version number "a.b.c.d" as a two-element numeric
# array. The first array element is the most significant 32 bits,
# and the second element is the least significant 32 bits.
function GetVersionStringAsArray([String] $ServerVersion) 
{
    $parts = $ServerVersion.Split(".")
    if ($parts.Count -lt 4) 
    {
        for ($n = $parts.Count; $n -lt 4; $n++) 
        {
            $parts += "0"
        }
    }
    [UInt32] ((Lsh $parts[0] 16) + $parts[1])
    [UInt32] ((Lsh $parts[2] 16) + $parts[3])
}

# Compares two version numbers "a.b.c.d". If $ServerVersion1 < $ServerVersion2,
# returns -1. If $ServerVersion1 = $ServerVersion2, returns 0. If
# $ServerVersion1 > $ServerVersion2, returns 1.
function CheckInstalledPowerShellVersion() 
    {
        Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue

        $installedVersion = ((Get-Module Azure).Version.Major -as [string]) +'.'+ ((Get-Module Azure).Version.Minor -as [string]) +'.'+ ((Get-Module Azure).Version.Build -as [string])        
        $minimumRequiredVersion = '0.9.3'        
        $ver1 = GetVersionStringAsArray $installedVersion
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
            elseif ($ver1[1] -eq $ver2[1]) 
            {
                $out = 0
            }
            else 
            {
                $out = 1
            }
        }
        else 
            {
                $out = 1
            }
        return $out
}