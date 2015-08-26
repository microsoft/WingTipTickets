<#
.Synopsis
    WingtipTickets (WTT) Demo Environment.
 .DESCRIPTION
    This script is used to edit the Application Settings values of the web.config file in the Azure WebSites WebDeploy Zip Package.
 .EXAMPLE
    Set-WTTEnvironmentWebConfig -WTTEnvironmentApplicationName <string> -AzureWebSiteWebDeployPackageName <string> -SearchServicePrimaryManagementKey <string>
#>
function Set-WTTEnvironmentWebConfig
{
    [CmdletBinding()]
    Param
    (   
        #WTT Environment Application Name
        [Parameter(Mandatory=$true)]
        [String]
        $WTTEnvironmentApplicationName,

        #Primary Azure SQL Database Server Name
        [Parameter(Mandatory=$false)]
        [String]
        $AzureSqlDatabaseServerPrimaryName,

        #Secondary Azure SQL Database Server Name
        [Parameter(Mandatory=$false)]
        [String]
        $AzureSqlDatabaseServerSecondaryName,

        #Azure SQL Database Server Administrator User Name
        [Parameter(Mandatory=$false)]
        [String]
        $AzureSqlDatabaseServerAdministratorUserName,

        #Azure SQL Database Server Adminstrator Password
        [Parameter(Mandatory=$false)]
        [String]
        $AzureSqlDatabaseServerAdministratorPassword,
        
        #Azure SQL Database Name
        [Parameter(Mandatory=$false)]
        [String]
        $AzureSqlDatabaseName,

         #Path to Azure Web Site WebDeploy Package
        [Parameter(Mandatory = $false)] 
        [String]$AzureWebSiteWebDeployPackagePath, 
                        
        #Azure Search Service Primary Management Key
        [Parameter(Mandatory = $true)] 
        [String]$SearchServicePrimaryManagementKey        
    )
    Process
    {   
        try
        {
         
            if($AzureSqlDatabaseServerAdministratorUserName -eq "")
            {
                $AzureSqlDatabaseServerAdministratorUserName = "developer"
            }

            if($AzureSqlDatabaseServerAdministratorPassword -eq "")
            {
                $AzureSqlDatabaseServerAdministratorPassword = "P@ssword1"
            }

            if($AzureSqlDatabaseServerVersion -eq "")
            {
                $AzureSqlDatabaseServerVersion = "12.0"
            }

            if($AzureSqlDatabaseName -eq "")
            {
                $AzureSqlDatabaseName = "Customer1"
            }
     
            if($AzureWebSiteWebDeployPackagePath -eq "")
            {
                $AzureWebSiteWebDeployPackagePath = (Get-Item -Path ".\" -Verbose).FullName + "\Packages"
            }
            
            if($AzureSqlDatabaseServerPrimaryName -eq "")
            {
                $AzureSqlDatabaseServerPrimaryName = $WTTEnvironmentApplicationName + "primary"
            }
            if($AzureSqlDatabaseServerSecondaryName -eq "")
            {
                $AzureSqlDatabaseServerSecondaryName = $WTTEnvironmentApplicationName + "secondary"                    
            }
            

            # Open zip and find the particular file (assumes only one inside the Zip file)
            $fileToEdit = "web.config"
            Add-Type -assembly  System.IO.Compression.FileSystem            
            $webDeployPackage = [System.IO.Compression.ZipFile]::Open($AzureWebSiteWebDeployPackagePath,"Update")
            $desiredWebConfigFile = $webDeployPackage.Entries | Where({$_.name -eq $fileToEdit})   
            if($desiredWebConfigFile.Count -gt 1)
            {
                foreach($webConfigFile in $desiredWebConfigFile)                
                {
                    if ($webConfigFile.FullName -notcontains "Views")
                    {
                        $desiredWebConfigFile = $webConfigFile
                    }
                }
            }
            
            # Read the contents of the web.config file
            $webConfigFile = [System.IO.StreamReader]($desiredWebConfigFile).Open()            
            [xml]$webConfig = [xml]$webConfigFile.ReadToEnd()
            $webConfigFile.Close()
            
            #Set the appSetttings values 
            $obj = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'TenantName'}
            $obj.value = $WTTEnvironmentApplicationName

            $obj = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'DatabaseUserName'}
            $obj.value = $AzureSqlDatabaseServerAdministratorUserName

            $obj = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'DatabaseUserPassword'}
            $obj.value = $AzureSqlDatabaseServerAdministratorPassword        
        
            $obj = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'PrimaryDatabaseServer'}
            $obj.value = $AzureSqlDatabaseServerPrimaryName

            $obj = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'SecondaryDatabaseServer'}
            $obj.value = $AzureSqlDatabaseServerSecondaryName

            $obj = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'TenantDbName'}
            $obj.value = $AzureSqlDatabaseName

            $obj = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'SearchServiceKey'}
            $obj.value = $SearchServicePrimaryManagementKey

            if ($WTTEnvironmentApplicationName.Length -gt 15)
            {
                $wTTEnvironmentApplicationName = $WTTEnvironmentApplicationName.Substring(0,15)
            }
            else
            {
                $wTTEnvironmentApplicationName = $WTTEnvironmentApplicationName
            }                        

            $obj = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'SearchServiceName'}
            $obj.value = $wTTEnvironmentApplicationName
                        
            $formattedXml = Format-XML -xml $webConfig.OuterXml
            
            # Write the changes and close the zip file
            $webConfigFileFinal = [System.IO.StreamWriter]($desiredWebConfigFile).Open()            
            $webConfigFileFinal.BaseStream.SetLength(0)
            $webConfigFileFinal.Write($formattedXml)            
            $webConfigFileFinal.Close()
            $webDeployPackage.Dispose()
        }
        catch
        {            
            Write-Host $Error
        }
    }
}

function Format-XML ([xml]$xml, $indent=2) 
{ 
    try
    {
        $StringWriter = New-Object System.IO.StringWriter 
        $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter 
        $xmlWriter.Formatting = "indented" 
        $xmlWriter.Indentation = $Indent 
        $xml.WriteContentTo($XmlWriter) 
        $XmlWriter.Flush() 
        $StringWriter.Flush() 
        Write-Output $StringWriter.ToString() 
    }
    catch
    {            
        Write-Host $Error
    }
}
