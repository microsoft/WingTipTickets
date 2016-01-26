<#
.Synopsis
	Azure DataFactory operation.
.DESCRIPTION
	This script is used to create an Azure Data Factory.
.EXAMPLE
	Test
#>
function New-WTTADFEnvironment
{
	[CmdletBinding()]
	Param
	(
		[Parameter()]
		[string]
		$SubscriptionId,

		[Parameter(Mandatory=$true)]
		[ValidateSet('deploy', 'delete')]
		[string]
		$Mode,

		[Parameter()]
		[string]
		$SqlServerLogin = 'developer',

		[Parameter()]
		[string]
		$SqlServerPassword = 'P@ssword1',

		#WTT Environment Application Name
		[Parameter()]
		[String]
		$WTTEnvironmentApplicationName,

		#Azure Active Directory Tenant Name
		[Parameter(Mandatory=$false)]
		[String]
		$AzureActiveDirectoryTenantName,

		#Azure Storage Account Name
		[Parameter(Mandatory=$false)]
		[String]
		$azureStorageAccountName,

		#Azure Storage Account Name
		[Parameter(Mandatory=$false)]
		[String]
		$azureSqlDatabaseServerPrimaryName
	)

	Process
	{
		# Check if DataFactory exists
		$azureDataFactory = Find-AzureRmResource -ResourceType "Microsoft.DataFactory/dataFactories" -ResourceNameContains $WTTEnvironmentApplicationName -ResourceGroupNameContains $WTTEnvironmentApplicationName

		If($azureDataFactory -ne $null)
		{
			WriteValue("Found")
		}
		else
		{
			#SetGlobalParams()
			RegisterProvider

			try {
				switch($Mode)
				{
					'deploy'
					{
						WriteLabel("Creating DataFactory")
						# CreateProductRecommendationResources
						# SetMappingDictionary
						# writeAccountInformation
						# PopulateProductRecommendation
						
						# Write-Host "### Deploying ADF Website $global:azureWebsiteName. ###" -foregroundcolor Yellow
						#$azureADFWebSiteWebDeployPackagePath = (Get-Item -Path ".\" -Verbose).FullName + "\Packages\ProductRecommendations.zip"
						#Publish-AzureWebsiteProject -Name $global:azureWebsiteName -Package $azureADFWebSiteWebDeployPackagePath 
						#Set-ADFWebsiteWebConfig            
					}
				} 
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
	$status = Get-AzureRmResourceProvider -ProviderNamespace Microsoft.DataFactory
	
	if ($status -ne "Registered")
	{
		Register-AzureRmResourceProvider -ProviderNamespace Microsoft.DataFactory -Force
	}
}

function CreateProductRecommendationResources{
    Write-Host 'Creating Azure services for product recommendation use case:'
    $storageAccount = GetStorageAccount
    CreateSQLServerAndDB 
	CreateAzureWebsite
    $adf = CreateDataFactory

    Write-Host 'Completed creating Azure services.'
}

function SetMappingDictionary {
    #map the global vars to the dictionary  used for string substitution
    $global:dict.Add('<account name>',$global:storageAccountName)
    $global:dict.Add('<account key>',$global:storageAccountKey)

    $global:dict.Add('<azuredbname>',$global:sqlserverName)
    $global:dict.Add('<userid>', $global:sqlServerLogin)
    $global:dict.Add('<password>', $global:sqlServerPassword)
    $global:dict.Add('<dbname>',$global:sqlDBName)
	$global:dict.Add('<usecase>',$global:useCaseName)
	$global:dict.Add('<eventhubname>',$global:EventHubName)
	$global:dict.Add('<servicebusnamespace>',$global:ServiceBusNamespace)
	$global:dict.Add('<container>',$global:useCaseName)
	$global:dict.Add('<sharedaccesspolicyname>',$global:sharedaccesskeyname)
	$global:dict.Add('<sharedaccesspolicykey>',$global:sharedaccesskey)
    $pipelineEndTime = [DateTimeoffset]::UtcNow
    $pipelineStartTime = $pipelineEndTime.AddDays($global:pipelineDuration)
    
    $global:dict.Add('<pipeline end time>',$pipelineEndTime.ToString("yyyy-MM-01T00:00:00Z"))
    $global:dict.Add('<pipeline start time>',$pipelineStartTime.ToString("yyyy-MM-01T00:00:00Z"))
}

function writeAccountInformation {
   $accountFile = "$global:useCaseName-accounts.txt"
   copy -Path "src\\account-template.txt" -Destination ".\\$accountFile" -Force
   Update-JSONFile ".\\$accountFile"
}

function PopulateProductRecommendation{
    Write-Host "Deploying use case content (scripts, sample data, etc) to the resources created..."

    #$global:dict
    #Remove files in temp\json
    $files = Get-ChildItem "temp\json\*" -Include *.json -Recurse -ErrorAction Stop

    foreach($file in $files)
    {
        remove-item  $file.FullName
    }

    copy -Path "src\productrec\*" -Destination "temp\json" -Recurse -Exclude *.config -Force
    $files = Get-ChildItem "temp\json\*" -Include *.json -Recurse -ErrorAction Stop
 
    #Prep work to deplpoy the pipelines/data sets and linked services
    foreach($file in $files)
    {
        Update-JSONFile  $file.FullName
    }
    $destContext = New-AzureStorageContext –StorageAccountName $global:storageAccountName -StorageAccountKey $blobAccountkey -ea silentlycontinue

    If ($destContext -eq $Null) {
	    Write-Verbose "Invalid storage account name and/or storage key provided"
	    Exit
    }

    #check whether the Azure storage container already exists
    $scriptcontainerName = "scripts"
    #Write-Verbose   "Preparing the container [$scriptcontainerName] storage account - $global:storageAccountName "
    $container = Get-AzureStorageContainer -Name $scriptcontainerName -context $destContext –ea silentlycontinue
    If ($container -eq $Null) {
	    #Write-Host "Creating storage container [$scriptcontainerName]"
	    New-AzureStorageContainer -Name $scriptcontainerName -context $destContext >> setup-log.txt
    }
    else {
	    #Write-Host "[$scriptcontainerName] exists."
    }

    $files = Get-ChildItem "scripts\productrec\*" -Include *.hql -Recurse -ErrorAction Stop
    #Write-Host  "Uploading demo scripts to the storage container [$scriptcontainerName]"
    foreach($file in $files)
    {
        Set-AzureStorageBlobContent -File $file.FullName -Container $scriptcontainerName -Context $destContext -Blob $file.Name -Force >> setup-log.txt
    }
    
	#check whether the Azure storage container already exists
    $jarscontainerName = "jars"
    #Write-Verbose   "Preparing the container [$jarscontainerName] storage account - $global:storageAccountName "
    $container = Get-AzureStorageContainer -Name $jarscontainerName -context $destContext –ea silentlycontinue
    If ($container -eq $Null) {
	    #Write-Host "Creating storage container [$jarscontainerName]"
	    New-AzureStorageContainer -Name $jarscontainerName -context $destContext >> setup-log.txt
    }
    else {
	    #Write-Host "[$jarscontainerName] exists."
    }
	
	# Upload Mahout jar file to azure blob storage
	Set-AzureStorageBlobContent -File ".\jars\mahout\mahout-core-0.9.0.2.1.12.0-2329-job.jar" -Container $jarscontainerName -Context $destContext -Blob "mahout\mahout-core-0.9.0.2.1.12.0-2329-job.jar" -Force >> setup-log.txt
	
	#check whether the Azure storage container already exists
    $packagecontainerName = "packages"
    #Write-Verbose   "Preparing the container [$packagecontainerName] storage account - $global:storageAccountName "
    $container = Get-AzureStorageContainer -Name $packagecontainerName -context $destContext –ea silentlycontinue
    If ($container -eq $Null) {
	    #Write-Host "Creating storage container [$packagecontainerName]"
	    New-AzureStorageContainer -Name $packagecontainerName -context $destContext >> setup-log.txt
    }
    else {
	    #Write-Host "[$packagecontainerName] exists."
    }
	
	# Upload package zip to azure blob storage
	Set-AzureStorageBlobContent -File ".\packages\ProductRecDataGenerator.zip" -Container $packagecontainerName -Context $destContext -Blob "ProductRecDataGenerator.zip" -Force >> setup-log.txt
	
    #Write-Host "Preparing the Azure SQL Database with output tables/stored procedures and types"
    sqlcmd -S "$azureSqlDatabaseServerPrimaryName.database.windows.net" -U "$azureSqlDatabaseServerPrimaryName@developer" -P "P@ssword1" -i .\scripts\productrec\productrecommendationssqldb.sql -d $global:useCaseName 2>&1 3>&1 4>&1 1>>setup-log.txt
   
    $scriptPath = ".\src\deployFolder.ps1"
    $jsonPath = ".\temp\json"

    $argumentList = @()
    $argumentList += ("-ResourceGroupName", $global:resourceGroupName )
    $argumentList += ("-DataFactoryName", $global:defaultResourceName)
    $argumentList += ("-JsonFilesFolder",  $jsonPath )    
   
    $argString = ""
    foreach($arg in $argumentList) {
        $argString += $arg + " "
    }
    Write-Verbose $argString 2>&1 3>&1 4>&1 1>>setup-log.txt

    #Deploy the pipelines/data sets and linked services
    Invoke-Expression "$scriptPath $argumentList >> setup-log.txt"


}

function Update-JSONFile( $file ){

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

function SetGlobalParams($parent) {
    #this function must be called after ValidateParams
    
	$parent.$SubscriptionId = 'TEST'

    [string]$global:location = 'CentralUS'
    [string]$global:locationMultiWord = 'Central US'

    $global:useCaseName = "productrec"
 
    if($WTTEnvironmentApplicationName -like 'data*')
    {
        $WTTEnvironmentApplicationName = $WTTEnvironmentApplicationName.Substring(4)
        $output = ($global:useCaseName + $WTTEnvironmentApplicationName).ToLower()
    }
    else
    {
    $output = ($global:useCaseName + $WTTEnvironmentApplicationName).ToLower()
    if($output.Length -gt 14) { $output = $output.Remove(15) }
    }

	if ($global:mode -eq 'deploy')
	{
		$global:ServiceBusNamespace = $output
		$global:ServiceBusNamespace | out-file -filepath "temp\sbnamespace.txt"
	}
	
    $global:useCaseName = $output.ToLower()
    $global:useCaseName = $global:useCaseName

    $global:defaultResourceName = $output 
    $global:storageAccountName = $WTTEnvironmentApplicationName
    $global:storageAccountKey = ""
    $global:blobContainerName = $output
	$global:azureWebsiteName = $output
	$global:EventHubName = $output

    $global:resourceGroupName = $output
    $global:affinityGroupName = $output

    $global:sqlserverName = ""
    $global:sqlDBName = $output
    

    $global:configPath = ('.\temp\setup\' + $global:useCaseName + '.txt')

    $global:dict = @{}    
    $global:progressMessages = New-Object System.Collections.ArrayList($null)

    $global:pipelineDuration = -365


}








#function CreateStorageAccount
function GetStorageAccount{
            # Get Storage Key information
            $blobAccountkey = (Get-AzureRMStorageAccountKey -ResourceGroupName $WTTEnvironmentApplicationName -storageAccountName $global:storageAccountName).Key1
            # Get Context
                    
}

function CreateSQLServerAndDB{
    process{
            
        #create sql server & DB
        
            try{
                Write-Host 'Creating SQL DB [' $global:sqlDBName ']......' -NoNewline 
                #$servercredential = new-object System.Management.Automation.PSCredential("developer", ("P@ssword1"  | ConvertTo-SecureString -asPlainText -Force))
                #create a connection context
                #$ctx = New-AzureSqlDatabaseServerContext -ServerName $sqlsvrname -Credential $serverCredential 
                $sqldb = New-AzureRMSqlDatabase -ResourceGroupName $WTTEnvironmentApplicationName -ServerName $azureSqlDatabaseServerPrimaryName –DatabaseName $sqlDBName  -Edition Basic   >> setup-log.txt
                Write-Host 'created.'
            } catch {
                Write-Host 'error.'
                throw
            }
        }
    
}

function CreateDataFactory{
    Process{
        $adf = $null
        try{
            Write-Host 'Creating Data Factory [' $global:defaultResourceName ']......' -NoNewline
            #will force overwrite if already exists
            $adf = New-AzureRMDataFactory -Name $global:defaultResourceName -location 'West US' -ResourceGroupName $WTTEnvironmentApplicationName -Force  | out-null
            Write-Host 'created.'    
        }catch {
            Write-Host 'error.'
            throw
        }
        return $adf
    }
}

function CreateAzureWebsite{  
    Process{
        $azurewebsite = $null
		$eventhub = $null
		
        try{            
			$azurewebsite = Get-AzureRMWebApp -ResourceGroupName $WTTEnvironmentApplicationName -Name $global:azureWebsiteName 
			if($azurewebsite.name -ne $global:azureWebsiteName)
			{
			Write-Host 'Creating Azure Website ['$global:azureWebsiteName']......' -NoNewline
            $null = New-AzureRMAppServicePlan -Name $global:azureWebsiteName -Location $global:locationMultiWord -Tier Free -ResourceGroupName $WTTEnvironmentApplicationName
            #create a new Azure Website
            $azurewebsite = New-AzureRmWebApp -ResourceGroupName $WTTEnvironmentApplicationName -Name $global:azureWebsiteName -Location $global:locationMultiWord -ErrorAction Stop | out-null
			Write-Host 'created.'
			}
			else {
				Write-Host 'Creating Azure Website ['$global:azureWebsiteName']...... already exists.'
				Remove-AzureRMWebApp -ResourceGroupName $WTTEnvironmentApplicationName -Name $global:azureWebsiteName
				Write-Host 'An error occured during setup; it was repaired. :) Please, run script again.'
				throw
			}
		 }catch{
                Write-Host 'created.'
		}          
    }
}



function Set-ADFWebsiteWebConfig
{
   
	#Get the ADF website
	$ADFWebSite = Get-AzureRMWebApp | Where-Object {$_.Name -like "*product*"}

	$ADFWebSite = [string]$ADFWebSite.Name
	
	#Set the RecommendationSiteURL for the ADF website setting in the WTT website 
	$settings = New-Object Hashtable
	$settings = @{"SqlServer" = $ADFWebSite; "SqlDB" = $global:sqlDBName; "SqlUserID" = "Developer"; "SqlPassword" = "P@ssword1"}
	
	Set-AzureRMWebApp -AppSettings $settings -Name $ADFWebSite

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

