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
		$ResourceGroupName,

		# Resource Group Location
		[Parameter(Mandatory=$true)]
		[String]
		$Location,
		
		# Website Hosting Plan Name
		[Parameter(Mandatory=$true)]
		[String]
		$WebsiteHostingPlanName,

		# SQL Database Server Name
		[Parameter(Mandatory=$true)]
		[String]
		$DatabaseServerName,

		# SQL Database name
		[Parameter(Mandatory=$true)]
		[String]        
		$DatabaseName,

		# SQL database edition
		[Parameter(Mandatory=$true, HelpMessage="Please specify edition for AzureSQL database ('Basic','Standard', 'Premium')?")]
		[ValidateSet('Basic','Standard', 'Premium')]
		[String]
		$DatabaseEdition,

		# SQL Database UserName
		[Parameter(Mandatory=$true)]
		[String]
		$DatabaseUserName,

		# SQL Database Password
		[Parameter(Mandatory=$true)]
		[String]
		$DatabasePassword
	)

	Process
	{
		# Check if DataFactory exists
		LineBreak
		WriteLabel("Checking for DataFactory '$ApplicationName")
		$azureDataFactory = Find-AzureRmResource -ResourceType "Microsoft.DataFactory/dataFactories" -ResourceNameContains $ApplicationName -ResourceGroupNameContains $ResourceGroupName

		If($azureDataFactory -ne $null)
		{
			WriteValue("Found")
		}
		else
		{
			WriteValue("Not Found")

			try 
			{
                $global:path = (Get-Item -Path ".\" -Verbose).FullName
				# Register DataFactory Provider
				RegisterProvider

				# Get StorageAccount Key
				$storageAccountKey = GetStorageAccountKey

				# Set up Mapping Dictionary
				SetupMappingDictionary($storageAccountKey)

				# Create and Deploy Database
				CreateDatabase
				CreateSchema
				PopulateDatabase

				# Create and Deploy Website
				CreateWebsite
				DeployWebsite($storageAccountKey)
				SetWebsiteConfig

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
	$provider = Find-AzureRmResource -ResourceType "Microsoft.Resources/providers" -ResourceNameContains "DataFactory" -ResourceGroupNameContains $ApplicationName

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
	$storageAccountkey = (Get-AzureRMStorageAccountKey -ResourceGroupName $ResourceGroupName -storageAccountName $ApplicationName).Key1

	return $storageAccountKey
}

function SetupMappingDictionary($StorageAccountKey)
{
	# Set up the Mapping Dictionary
	$global:dict = @{}
	$global:dict.Add('<account name>', $ApplicationName)
	$global:dict.Add('<account key>', $StorageAccountKey)
	$global:dict.Add('<azuredbname>', $DatabaseServerName)
	$global:dict.Add('<userid>', $DatabaseUserName)
	$global:dict.Add('<password>', $DatabasePassword)
	$global:dict.Add('<dbname>', $DatabaseName)

	$pipelineEndTime = [DateTimeoffset]::UtcNow
	$pipelineStartTime = $pipelineEndTime.AddDays(-365)

	$global:dict.Add('<pipeline end time>',$pipelineEndTime.ToString("yyyy-MM-01T00:00:00Z"))##
	$global:dict.Add('<pipeline start time>',$pipelineStartTime.ToString("yyyy-MM-01T00:00:00Z"))##
}

function CreateDatabase()
{
	Try
	{
		# Create Database
		WriteLabel("Creating database '$DatabaseName'")
		$null = New-AzureRMSqlDatabase -ResourceGroupName $ApplicationName -ServerName $DatabaseServerName -DatabaseName $DatabaseName -Edition $DatabaseEdition
		WriteValue("Successful")

		# Test the Connection to the Database
		$ConnectionString = "Server=tcp:$DatabaseServerName.database.windows.net; Database=$DatabaseName; User ID=$DatabaseUserName; Password=$DatabasePassword; Trusted_Connection=False; Encrypt=True;"
		$Connection = New-object system.data.SqlClient.SqlConnection($ConnectionString)

		# Open the connection to the Database
		WriteLabel("Testing database connection")
		$Connection.Open()

		If(!$Connection)
		{
			WriteValue("Failed")
			throw "Failed to Connect $ConnectionString"
		}

		WriteValue("Successful")
	} 
	Catch 
	{
		WriteError($Error)
		throw
	}
}

function CreateSchema()
{
	Try
	{
		# Create Database Schema
		WriteLabel("Creating Database Schema")
        
        Push-Location

        $DatabaseServer = (Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains "primary" -ExpandProperties).properties.FullyQualifiedDomainName
        $result = Invoke-Sqlcmd -Username "$DatabaseUserName@$DatabaseServerName" -Password $DatabasePassword -ServerInstance $DatabaseServer -Database $DatabaseName -InputFile ".\Resources\DataFactory\Database\Schema.sql" -QueryTimeout 0

        Set-Location -Path $global:path
        Pop-Location
        

		WriteValue("Successful")
	}
	Catch
	{
		WriteValue("Failed")
		throw $Error
	}
}

function PopulateDatabase()
{
	Try
	{
		# Populate Database
		WriteLabel("Populating Database")

        Push-Location

        $DatabaseServer = (Find-AzureRmResource -ResourceType "Microsoft.Sql/servers" -ResourceNameContains "primary" -ExpandProperties).properties.FullyQualifiedDomainName
        $result = Invoke-Sqlcmd -Username "$DatabaseUserName@$DatabaseServerName" -Password $DatabasePassword -ServerInstance $DatabaseServer -Database $DatabaseName -InputFile ".\Resources\DataFactory\Database\Populate.sql" -QueryTimeout 0
        
        Set-Location -Path $global:path
        Pop-Location

		WriteValue("Successful")
	}
	Catch
	{
		WriteValue("Failed")
		throw $Error
	}
}

function CreateWebsite()
{
	Try
	{
		# Create website under Primary location
		WriteLabel("Creating web application '$DatabaseName'")
		$null = New-AzureRMWebApp -Location $Location -AppServicePlan $WebsiteHostingPlanName -ResourceGroupName $ResourceGroupName -Name $ApplicationName$DatabaseName
		WriteValue("Successful")
	}
	Catch
	{
		WriteValue("Failed")
		throw $Error
	}
}

function DeployWebsite($storageAccountKey)
{
	Try
	{
		$containerName = "deployment-files"

		# Get the storage account context
		$context = New-AzureStorageContext –StorageAccountName $ApplicationName -StorageAccountKey $storageAccountKey -ea silentlycontinue
		If ($context -eq $null) { throw "Invalid storage account name and/or storage key provided" }

		# Find the Container
		$container = Get-AzureStorageContainer -context $context | Where-Object { $_.Name -eq $containerName }

		If ($container -eq $null)
		{
			# Create the Container
			New-AzureStorageContainer -Name $containerName -Permission "Blob" -context $context >> setup-log.txt
		}

		# Upload Deployment Package
		WriteLabel("Uploading Deployment Package")
		Set-AzureStorageBlobContent -File ".\packages\ProductRecommendations.zip" -Container $containerName -Context $context -Blob "recommendations-package.zip" -Force
		WriteValue("Successful")

		# Build Paths
		$templateFilePath = (Get-Item -Path ".\" -Verbose).FullName + "\Resources\DataFactory\Website\Deployment.json"
		$packageUri = "https://$ApplicationName.blob.core.windows.net/deployment-files/recommendations-package.zip"

		# Deploy application
		WriteLabel("Deploying Web Application '$DatabaseName'")
		$null = New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $DatabaseName -Mode "Incremental" -TemplateFile $templateFilePath -siteName $ApplicationName$DatabaseName -hostingPlanName $WebsiteHostingPlanName -siteLocation $Location -sku "Standard" -packageUri $packageUri
		WriteValue("Successful")
	}
	Catch
	{
		WriteValue("Failed")
		throw $Error
	}
}

function SetWebsiteConfig()
{
	# Update website config
	WriteLabel("Updating Config Settings")

	$settings = New-Object Hashtable
	$settings = 
	@{
		"SqlServer" = "$DatabaseServerName.database.windows.net" ;
		"SqlDB" = $DatabaseName; 
		"SqlUserID" = $DatabaseUserName; 
		"SqlPassword" = $DatabasePassword
	}

	$null = Set-AzureRMWebApp -AppSettings $settings -Name $ApplicationName$DatabaseName -ResourceGroupName $ResourceGroupName

	WriteValue("Successful")
}

function CreateDataFactory()
{
	Try
	{
		# Create DataFactory
		WriteLabel("Creating Data Factory '$ApplicationName'")
		$dataFactory = New-AzureRMDataFactory -Name $ApplicationName -location 'West US' -ResourceGroupName $ResourceGroupName -Force  | out-null
		WriteValue("Successful")

		return $dataFactory
	}
	Catch 
	{
		WriteValue("Failed")
		throw $Error
	}
}

function PopulateProductRecommendation($StorageAccountKey)
{
	WriteLabel("Deploying DataFactory Content")

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
	$argumentList += ("-ResourceGroupName", $ResourceGroupName )
	$argumentList += ("-DataFactoryName", $ApplicationName)
	$argumentList += ("-JsonFilesFolder",  $jsonPath )    

	$argString = ""
	foreach($arg in $argumentList) 
	{
		$argString += $arg + " "
	}

	# Deploy the pipelines/data sets and linked services
	Invoke-Expression "$scriptPath $argumentList >> setup-log.txt"

	WriteValue("Successful")
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

