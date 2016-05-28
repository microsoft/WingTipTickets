<#
.Synopsis
	Azure DataFactory operations.
.DESCRIPTION
	This script is used to create an Azure Data Factory.
.EXAMPLE
	New-WTTADFEnvironment -ApplicationName <string> -ResourceGroupName <string> -Location <string> -WebsiteHostingPlanName <string> -DatabaseServerName <string> -DatabaseName <string> -DatabaseEdition <string> -DatabaseUserName <string> -DatabasePassword <string>
#>
function New-WTTADFEnvironment
{
	[CmdletBinding()]
	Param
	(
		# Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$ApplicationName,

		# Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureResourceGroupName,

		# SQL Database Server Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureSqlServerName,

		# SQL Database name
		[Parameter(Mandatory=$true)]
		[String]        
		$azureSQLDatabaseName,

		# SQL database edition
		[Parameter(Mandatory=$true, HelpMessage="Please specify edition for AzureSQL database ('Basic','Standard', 'Premium')?")]
		[ValidateSet('Basic','Standard', 'Premium')]
		[String]
		$DatabaseEdition,

		# SQL Database UserName
		[Parameter(Mandatory=$true)]
		[String]
		$adminUserName,

		# SQL Database Password
		[Parameter(Mandatory=$true)]
		[String]
		$adminPassword
	)

	Process
	{
		# Check if DataFactory exists
		LineBreak
		WriteLabel("Checking for DataFactory '$ApplicationName")
		$azureDataFactory = Find-AzureRmResource -ResourceType "Microsoft.DataFactory/dataFactories" -ResourceNameContains $ApplicationName -ResourceGroupNameContains $azureResourceGroupName

	    If($azureDataFactory -ne $null)
	    {
		    WriteValue("Found")
            RemoveDataFactory
	    }
        $azureDataFactory = Find-AzureRmResource -ResourceType "Microsoft.DataFactory/dataFactories" -ResourceNameContains $ApplicationName -ResourceGroupNameContains $azureResourceGroupName
	    if($azureDataFactory -eq $null)
	    {
		    WriteValue("Not Found")

		    try 
		    {
			    # Register DataFactory Provider
			    RegisterProvider

			    # Get StorageAccount Key
			    $storageAccountKey = GetStorageAccountKey
                CreateStorageContainer($storageAccountKey)

			    # Set up Mapping Dictionary
			    SetupMappingDictionary($storageAccountKey)
                
                # Create and Deploy Database
			    CreateDatabase
			    CreateSchema
			    PopulateDatabase

			    # Create DataFactory
			    CreateDataFactory
			    PopulateProductRecommendation($storageAccountKey)
		    }
		    Catch
		    {
			    WriteError($Error)
		    }
        }
	}
}

function RegisterProvider()
{
	WriteLabel("Checking for DataFactory Provider")
	$provider = Find-AzureRmResource -ResourceType "Microsoft.Resources/providers" -ResourceNameContains "DataFactory" -ResourceGroupNameContains $azureResourceGroupName

	if ($provider -eq $null)
	{
		WriteValue("Not Found")

		WriteLabel("Registering DataFactory Provider")
		$null = Register-AzureRmResourceProvider -ProviderNamespace Microsoft.DataFactory -Force
		WriteValue("Successful")
	}
	else
	{
		WriteValue("Found")
	}
}

function GetStorageAccountKey()
{
	# Get Storage Account Primary Key
    $storageExists = Find-AzureRmResource -ResourceNameContains $ApplicationName -ResourceGroupNameContains $azureResourceGroupName -ResourceType Microsoft.Storage/storageaccounts
    if($storageExists)
    {
	    $storageAccountkey = (Get-AzureRMStorageAccountKey -ResourceGroupName $azureResourceGroupName -storageAccountName $ApplicationName).Value[0]
    }
    Else
    {
        WriteError("Storage Account does not exist")
    }

	return $storageAccountKey
}

function CreateStorageContainer($storageAccountKey)
{
        WriteLabel("Creating Storage Container")
        try{
            # Get Context
            $context = New-AzureStorageContext -storageAccountName $ApplicationName -StorageAccountKey $storageAccountKey -ErrorAction SilentlyContinue
             
            $containerExist = Get-AzureStorageContainer -Name 'productrec' -Context $context -ErrorAction SilentlyContinue
            if(!$containerExist)
            {
                # Create the container to store blob
                $container = New-AzureStorageContainer -Name 'productrec' -Context $context -ErrorAction SilentlyContinue
                WriteValue("Successful")
            }
            else
            {
                WriteValue("Successful")
            }

        }catch{
            if($error[0].CategoryInfo.Category -eq 'ResourceExists'){
                Write-Host 'resource exists.'
            }else{
                Write-Host 'error.'
            }
        }       
}

function SetupMappingDictionary($StorageAccountKey)
{
	# Set up the Mapping Dictionary
	$global:dict = @{}
	$global:dict.Add('<account name>', $ApplicationName)
	$global:dict.Add('<account key>', $StorageAccountKey)
	$global:dict.Add('<azuredbname>', $azureSQLServerName)
	$global:dict.Add('<userid>', $adminUserName)
	$global:dict.Add('<password>', $adminPassword)
	$global:dict.Add('<dbname>', $azureSQLDatabaseName)

	$pipelineEndTime = [DateTimeoffset]::UtcNow
	$pipelineStartTime = $pipelineEndTime.AddDays(-365)
    
	$global:dict.Add('<pipeline end time>',$pipelineEndTime.ToString("yyyy-MM-01T00:00:00Z"))##
	$global:dict.Add('<pipeline start time>',$pipelineStartTime.ToString("yyyy-MM-01T00:00:00Z"))##
}

function CreateDatabase()
{
	Try
	{
        $recommendationExist = $false
        Do
        {
            $recommendationDB = Get-AzureRmSqlDatabase -DatabaseName $azureSQLDatabaseName -ServerName $azureSQLServerName -ResourceGroupName $azureResourceGroupName -ErrorAction SilentlyContinue
            if(!$recommendationDB)
            {
		        # Create Database
		        WriteLabel("Creating database '$azureSQLDatabaseName'")
		        $null = New-AzureRMSqlDatabase -ResourceGroupName $azureResourceGroupName -ServerName $azureSQLServerName -DatabaseName $azureSQLDatabaseName -Edition $DatabaseEdition
		        WriteValue("Successful")
                $recommendationExist = $true
            }
            else
            {
                Push-Location -StackName wtt
                $result = Invoke-Sqlcmd -Username "$adminUserName@$azureSQLServerName" -Password $adminPassword -ServerInstance "$azureSQLServerName.database.windows.net" -Database $azureSQLDatabaseName -Query "Select top 1 * from Customers;" -QueryTimeout 0 -SuppressProviderContextWarning -ErrorAction SilentlyContinue
                Pop-Location -StackName wtt
                if([string]$result -eq $null)
                {
                    WriteError("Recommendation Database is not deployed")
                    Remove-AzureRmSqlDatabase -ResourceGroupName $azureResourceGroupName -ServerName $azureSQLServerName -DatabaseName $azureSQLDatabaseName -Force -ErrorAction SilentlyContinue
                    $recommendationExist = $false          
                }
            }
        }Until($recommendationExist -eq $true)
	} 
	Catch 
	{
		WriteError($Error)
		throw
	}
}

function CreateSchema
{
	Try
	{
		# Create Database Schema	
		WriteLabel("Creating Database Schema")
		Push-Location -StackName wtt        
		$azureSQLServerName = (Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains "primary" -ExpandProperties -ResourceGroupNameContains $azureResourceGroupName).properties.FullyQualifiedDomainName
		$result = Invoke-Sqlcmd -Username "$adminUserName@$azureSQLServerName" -Password $adminPassword -ServerInstance $azureSQLServerName -Database $azureSQLDatabaseName -InputFile ".\Resources\DataFactory\Database\Schema.sql" -QueryTimeout 0 -ErrorAction SilentlyContinue
		Pop-Location -StackName wtt
		WriteValue("Successful")
	}
	Catch
	{
		WriteValue("Failed")
		throw $Error
	}
}

function PopulateDatabase
{
	Try
	{
        $testSQLConnection = Test-WTTAzureSQLConnection -azureSQLServerName $azureSQLServerName -adminUserName $adminUserName -adminPassword $adminPassword -azureSQLDatabaseName $azureSQLDatabaseName -azureResourceGroupName $azureResourceGroupName
        if ($testSQLConnection -notlike "success")
        {
            WriteError("Unable to connect to SQL Server")
        }
        Else
        {
		    # Populate Database
		    WriteLabel("Populating Database")
		    Push-Location -StackName wtt
		    $azureSQLServerName = (Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains "primary" -ExpandProperties -ResourceGroupNameContains $azureResourceGroupName).properties.FullyQualifiedDomainName
		    $result = Invoke-Sqlcmd -Username "$adminUserName@$azureSQLServerName" -Password $adminPassword -ServerInstance $azureSQLServerName -Database $azureSQLDatabaseName -InputFile ".\Resources\DataFactory\Database\Populate.sql" -QueryTimeout 0 -ErrorAction SilentlyContinue
		    Pop-Location -StackName wtt
		    WriteValue("Successful")
        }
	}
	Catch
	{
		WriteValue("Failed")
		throw $Error
	}
}

function CreateDataFactory()
{
	Try
	{
        $adf = (Get-AzureRmResourceProvider -ProviderNamespace Microsoft.DataFactory).ResourceTypes
        $adfLocation = ($adf | Where-Object {$_.ResourceTypeName -eq "dataFactories"}).locations
		# Create DataFactory
		WriteLabel("Creating Data Factory '$ApplicationName'")
        foreach($location in $adfLocation)
        {
		    $dataFactory = New-AzureRMDataFactory -Name $ApplicationName -location $location -ResourceGroupName $azureResourceGroupName -Force -ErrorAction SilentlyContinue
            $adfExists = (Find-AzureRmResource -ResourceNameContains $ApplicationName -ResourceGroupNameContains $azureResourceGroupName -ResourceType Microsoft.DataFactory/dataFactories -ExpandProperties).Properties.provisioningstate
            $adfExistsNow = $false
            if($adfExists -eq "Succeeded")
            {          
                $adfExistsNow = $true
                WriteValue("Successful")
                return $dataFactory
            }
            else
            {
		        WriteValue("Failed")
            }
        }
	}
	Catch 
	{
		WriteValue("Failed")
		throw $Error
	}
}

function RemoveDataFactory()
{
    Try
    {
        WriteLabel("Checking data factory '$ApplicationName' status")
        $dataFactory = Get-AzureRmDataFactory -Name $ApplicationName -ResourceGroupName $azureResourceGroupName -ErrorAction SilentlyContinue
        if($dataFactory.ProvisioningState -eq "Succeeded")
        {
            WriteValue("Found")
            $azureDataFactoryRemove = Remove-AzureRmDataFactory -Name $ApplicationName -ResourceGroupName $azureResourceGroupName -Force -ErrorAction SilentlyContinue
        }
        else
        {
            WriteValue("Not Deployed")
        }
    }
    Catch
    {
        WriteValue("Failed")
		throw $Error
    }
}

function PopulateProductRecommendation($StorageAccountKey)
{
    LineBreak

	# Remove files in temp directory
	$files = Get-ChildItem "temp\json\*" -Include *.json -Recurse -ErrorAction Stop

	foreach($file in $files)
	{
		remove-item  $file.FullName
	}

	# Copy files from Source to Temp directory
	copy -Path "src\productrec\*" -Destination "temp\json" -Recurse -Exclude *.config -Force

	# Update placeholders in the files
	$files = Get-ChildItem "temp\json\*" -Include *.json -Recurse -ErrorAction Stop

	foreach($file in $files)
	{
		Update-JSONFile $file.FullName
	}

	# Get the Storage Context
	$context = New-AzureStorageContext –StorageAccountName $ApplicationName -StorageAccountKey $storageAccountKey -ea silentlycontinue
	If ($context -eq $null) { throw "Invalid storage account name and/or storage key provided" }

	# Check for Script Container
	$scriptcontainerName = "scripts"
	$container = Get-AzureStorageContainer -context $context | Where-Object { $_.Name -eq $scriptcontainerName }

	If ($container -eq $null)
	{
		# Create the Container
		New-AzureStorageContainer -Name $scriptcontainerName -Permission "Blob" -context $context >> setup-log.txt
	}

	# Check for Jar Container
	$jarscontainerName = "jars"
	$container = Get-AzureStorageContainer -context $context | Where-Object { $_.Name -eq $jarscontainerName }

	If ($container -eq $null)
	{
		# Create the Container
		New-AzureStorageContainer -Name $jarscontainerName -Permission "Blob" -context $context >> setup-log.txt
	}

	# Check for Packages Container
	$packagecontainerName = "packages"
	$container = Get-AzureStorageContainer -context $context | Where-Object { $_.Name -eq $packagecontainerName }

	If ($container -eq $null)
	{
		# Create the Container
		New-AzureStorageContainer -Name $packagecontainerName -Permission "Blob" -context $context >> setup-log.txt
	}

	# Upload Script Files
	$files = Get-ChildItem "scripts\productrec\*" -Include *.hql -Recurse -ErrorAction Stop
	foreach($file in $files)
	{
		Set-AzureStorageBlobContent -File $file.FullName -Container $scriptcontainerName -Context $context -Blob $file.Name -Force >> setup-log.txt
	}

	# Upload Jar Files
	Set-AzureStorageBlobContent -File ".\jars\mahout\mahout-core-0.9.0.2.1.12.0-2329-job.jar" -Container $jarscontainerName -Context $context -Blob "mahout\mahout-core-0.9.0.2.1.12.0-2329-job.jar" -Force >> setup-log.txt

	# Upload Package Files
	Set-AzureStorageBlobContent -File ".\packages\ProductRecDataGenerator.zip" -Container $packagecontainerName -Context $context -Blob "ProductRecDataGenerator.zip" -Force >> setup-log.txt

	# Build up Script Paths and arguments to deploy
	$scriptPath = ".\src\deployFolder.ps1"
	$jsonPath = ".\temp\json"

	$argumentList = @()
	$argumentList += ("-ResourceGroupName", $azureResourceGroupName )
	$argumentList += ("-DataFactoryName", $ApplicationName)
	$argumentList += ("-JsonFilesFolder",  $jsonPath )    

	$argString = ""
	foreach($arg in $argumentList) 
	{
		$argString += $arg + " "
	}

	# Deploy the pipelines/data sets and linked services
	Invoke-Expression "$scriptPath $argumentList >> setup-log.txt"
}

function Update-JSONFile( $file )
{
	(Get-Content $file ) | Foreach-Object {
		$_ -replace '<account name>', $global:dict["<account name>"] `
		-replace '<account key>', $global:dict["<account key>"] `
		-replace '<ML BES Endpoint>', $global:dict["<ML BES Endpoint>"] `
		-replace '<API Key>', $global:dict["<API Key>"] `
		-replace '<azuredbname>', $global:dict["<azuredbname>"] `
		-replace '<dbname>', $global:dict["<dbname>"] `
		-replace '<userid>', $global:dict["<userid>"] `
		-replace '<password>', $global:dict["<password>"] `
		-replace '<usecase>', $global:dict["<usecase>"] `
		-replace '<pipeline start time>', $global:dict["<pipeline start time>"] `
		-replace '<pipeline end time>', $global:dict["<pipeline end time>"] `
		-replace '<subId>', $global:dict["<subId>"] `
		-replace '<subName>', $global:dict["<subName>"] ` 
	} | Set-Content  $file
}