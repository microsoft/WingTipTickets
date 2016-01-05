<#
.Synopsis
    Azure SQL database operation.
 .DESCRIPTION
    This script is used to create object in azure sql database.
 .EXAMPLE
    Deploy-DBSchema 'ServerName', 'UserName', 'Password', 'Location', 'DatabaseEdition', 'DatabaseName'
 .INPUTS    
    1. ServerName
        Azure sql database server name for connection.
    2. UserName
        Username for sql database connection.
    3. Password
        Password for sql database connection.
    4. Location
        Location ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast') for object creation
    5. DatabaseEdition
        DatabaseEdition ('Basic','Standard', 'Premium') for object creation    
    6. DatabaseName
        Azure sql database name.    

 .OUTPUTS
    Message creation of DB schema.
 .NOTES
    All parameters are mandatory.
 .COMPONENT
    The component this cmdlet belongs to Azure Sql.
 .ROLE
    The role this cmdlet belongs to the person having azure sql access.
 .FUNCTIONALITY
    The functionality that best describes this cmdlet.
#>
function Deploy-WTTAzureDWDatabase
{
    [CmdletBinding()]
    Param
    (        
        #WTT Environment Application Name
        [Parameter(Mandatory=$true)]
        [String]
        $WTTEnvironmentApplicationName,

        #Azure SQL server name for connection.
        [Parameter(Mandatory=$true)]
        [String]
        $ServerName,

        #Azure SQL database server location
        [Parameter(Mandatory=$true, HelpMessage="Please specify location for AzureSQL server ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
        [ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')]
        [String]
        $ServerLocation,

        #Azure SQL database server location
        [Parameter(Mandatory=$true, HelpMessage="Please specify edition for AzureSQL database ('DataWarehouse')?")]
        [ValidateSet('DataWarehouse')]
        [String]
        $DatabaseEdition,
	
        #Azure SQL db user name for connection.
        [Parameter(Mandatory=$true)]
        [String]
        $UserName,

        #Azure SQL db password for connection.
        [Parameter(Mandatory=$true)]
        [String]
        $Password,
                
		#Azure SQL Database name.
        [Parameter(Mandatory=$true)]
        [String]        
        $DWDatabaseName
    )
        Process
    {
        
    	#Add-AzureAccount

        #
        # ****** Check Server exists ******
        #
        
        $dbServerExists=$true
        Try 
        {
            Write-Host "### Checking whether Azure SQL Database Server $ServerName already exists. ###" -foregroundcolor "yellow"
            $existingDbServer=Get-AzureSqlDatabaseServer -ServerName $ServerName -ErrorVariable existingDbServerErrors -ErrorAction SilentlyContinue
            If($existingDbServer.ServerName -eq $ServerName) 
            {
                Write-Host "### Azure SQL Database Server: $ServerName exists. ###" -foregroundcolor "yellow"
                $dbServerExists=$true
            }
            else
            {
                Write-Host "### Existing Azure SQL Database Server: $ServerName does not exist. ###" -foregroundcolor "red"
                $dbServerExists=$false
	        }
        }
        Catch
        {
	            Write-Host "Get-AzureSqlDatabaseServer failed.."
                $dbServerExists=$false
        }
    
        #
        # ****** Check Database exists ******
        #

        $dbExists=$true
        if(!$dbServerExists) 
        {
            $dbExists=$false
        }
        else
        {
	        Try
        {
                #$azureSqlDatabaseExists = Get-AzureSqlDatabase -ServerName $ServerName -DatabaseName $DatabaseName  -ErrorVariable azureSqlDatabaseExistsErrors -ErrorAction SilentlyContinue
                $azureSqlDatabaseExists = Get-AzureRMSqlDatabase -ServerName $ServerName -DatabaseName $DWDatabaseName -ResourceGroupName $WTTEnvironmentApplicationName -ErrorVariable azureSqlDatabaseExistsErrors -ErrorAction SilentlyContinue

                if($azureSqlDatabaseExists.Count -gt 0)
                {
                    Write-Host $DWDatabaseName " Database already exists on the server '" $ServerName "'"  -foregroundcolor "red"
                }

                elseif($azureSqlDatabaseExists.Count -eq 0)
                {
                    $dbExists=$false
                    Write-Host " "
                    Write-Host "### Creating database ' " $DWDatabaseName " ' ###"
                    New-AzureRMSqlDatabase -RequestedServiceObjectiveName "DW2000" -ServerName $ServerName -DatabaseName "$DWDatabaseName" -Edition "$DatabaseEdition" -ResourceGroupName $WTTEnvironmentApplicationName
                    Write-Host "Success: New database $DWDatabaseName created" -foregroundcolor "green"

                    $DWServer = "$ServerName.database.windows.net"
                    $ConnectionString = "Server=tcp:$ServerName.database.windows.net;
					Database=$DWDatabaseName;
					User ID=$UserName;
					Password=$Password;
					Trusted_Connection=False;
					Encrypt=True;"
                    
                    $Connection = New-object system.data.SqlClient.SqlConnection($ConnectionString)
                    $Command = New-Object System.Data.SqlClient.SqlCommand('',$Connection)
                    #Open the connection with db server.
                    $Connection.Open()
                    If(!$Connection)
                    {
                        throw "Failed to open connection $ConnectionString"
                    }
                    Write-Host "Success: Connection opened to database.. '" $DatabaseName "'"

           
                    If ($DWDatabaseName -eq $DWDatabaseName)
                    {
                        Write-Host "Creating Customer Data Warehouse database..."
                        Get-ChildItem ".\Scripts\Datawarehouse" -Filter *.sql | `
                        Foreach-Object{
                        Write-Host 'Executing' $_.FullName
                        sqlcmd -U $UserName@$ServerName -P $Password -S $DWDatabaseName -d $DWDatabaseName -i $_.FullName -I
                        }
                    }

	        $Connection.Close()
	        $Connection=$null
            
            Set-AzureRmSqlDatabase -RequestedServiceObjectiveName "DW100" -ServerName $ServerName -DatabaseName "$DWDatabaseName" -ResourceGroupName $WTTEnvironmentApplicationName
        }
        Write-Host " "
        Write-Host "SUCCESS:Warehouse Database tables created and database connection closed. " -foregroundcolor "yellow"
        Write-Host " "    
    }
                   
        Catch
        {
            Write-Error "Error -- $Error "
            $dbExists=$false
        }
    }
    }
   }
