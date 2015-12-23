[CmdletBinding()]
Param(
   [Parameter()]
   [Alias("subscriptionID")]
   [string]$global:subscriptionID,

   [Parameter()]
   [Alias("usecase")]
   [string]$global:useCaseName,

   [Parameter()]
   [Alias("mode")]
   [string]$global:mode,

   [Parameter()]
   [Alias("sqllogin")]
   [string]$global:sqlServerLogin = 'mylogin',

   [Parameter()]
   [Alias("sqlpassword")]
   [string]$global:sqlServerPassword = 'pass@word1'   
)

# global variables
#[string]$global:subscriptionDefaultAccount
#[string]$global:defaultResourceName
#[string]$global:resourceGroupName 
#[string]$global:affinityGroupName
#[string]$global:location
#[string]$global:defaultResourceName
#[string]$global:storageAccountName 
#[string]$global:blobContainerName
#[string]$global:azureWebsiteName
#[string]$global:EventHubName
#[string]$global:ServiceBusNamespace
#[string]$global:sqlDBName
#[string]$global:configPath

function Update-JSONFile( $file ){
	#Write-Host  -foreground green (Get-Date)   "Updating [$file]"

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

function Update-ASAJSONFile( $file ){
	#Write-Host  -foreground green (Get-Date)   "Updating [$file]"

	(Get-Content $file ) | Foreach-Object {
		$_ -replace '<accountname>', $global:dict["<account name>"] `
 		    -replace '<accountkey>', $global:dict["<account key>"] `
 		    -replace '<eventhubname>', $global:dict["<eventhubname>"] `
 		    -replace '<servicebusnamespace>', $global:dict["<servicebusnamespace>"] `
 		    -replace '<sharedaccesspolicykey>', $global:dict["<sharedaccesspolicykey>"] `
 		    -replace '<sharedaccesspolicyname>', $global:dict["<sharedaccesspolicyname>"] `
			-replace '<container>', $global:dict["<usecase>"] `
			-replace '<sqlserver>', $global:dict["<azuredbname>"] `
			-replace '<dbname>', $global:dict["<dbname>"] `
 		    -replace '<userid>', $global:dict["<userid>"] `
 		    -replace '<password>', $global:dict["<password>"] `
		
	} | Set-Content  $file

}

function ValidateParameters{
    $modeList = 'deploy', 'delete'
    if($modeList -notcontains $global:mode){
        Write-Host ''
        Write-Host 'MISSING REQUIRED PARAMETER: -mode parameter must be set to one of: ' $modeList
        $global:mode = Read-Host 'Enter mode'
        while($modeList -notcontains $global:mode){
            Write-Host 'Invalid mode. Please enter a mode from the list above.'
            $global:mode = Read-Host 'Enter mode'                     
        }
    }

    $useCaseNameList = 'productrec'
    if($useCaseNameList -notcontains $global:useCaseName.ToLower()){
        Write-Host ''
        Write-Host 'MISSING REQUIRED PARAMETER: -usecase parameter must be set to one of: ' $useCaseNameList
        $global:useCaseName = Read-Host 'Enter use case name'
        while($useCaseNameList -notcontains $global:useCaseName){
            Write-Host 'Invalid use case name. Please enter a name from the list above.'
            $global:useCaseName = Read-Host 'Enter use case name'                     
        }
    }

    Write-Host
    Write-Host '------------------------------------------'
    Write-Host 'Mode: ' $global:mode
    Write-Host 'Use Case: ' $global:useCaseName   
    Write-Host '------------------------------------------'
}

function SetGlobalParams {
    #this function must be called after ValidateParams
    

    [string]$global:location = 'WestUS'
    [string]$global:locationMultiWord = 'West US'


    $output = ($global:useCaseName + $env:COMPUTERNAME).Replace('-','').Replace('_','').ToLower()
    if($output.Length -gt 24) { $output = $output.Remove(23) }

	if ($global:mode -eq 'deploy')
	{
		$uniquesuffix = Get-Random -Maximum 999
		$global:ServiceBusNamespace = $output + $uniquesuffix
		$global:ServiceBusNamespace | out-file -filepath "temp\sbnamespace.txt"
	}
	
    $global:useCaseName = $global:useCaseName.ToLower()

    $global:defaultResourceName = $output 
    $global:storageAccountName = $output
    $global:storageAccountKey = ""
    $global:blobContainerName = $global:useCaseName
	$global:azureWebsiteName = $output
	$global:EventHubName = $output

    $global:resourceGroupName = $global:useCaseName
    $global:affinityGroupName = $global:useCaseName

    $global:sqlserverName = ""
    $global:sqlDBName = $global:useCaseName
    

    $global:configPath = ('.\temp\setup\' + $global:useCaseName + '.txt')

    $global:dict = @{}    
    $global:progressMessages = New-Object System.Collections.ArrayList($null)

    $global:pipelineDuration = -365


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


function InitSubscription{
    #login
    $account = Get-AzureAccount
	Write-Host You are signed-in with $account.id
	
	If ($account.id -eq $null)
	{
	Add-AzureAccount -WarningAction SilentlyContinue | out-null
	}
    if($global:subscriptionID -eq $null -or $global:subscriptionID -eq ''){
        $subList = Get-AzureSubscription

        if($subList.Length -lt 1){
            throw 'Your azure account does not have any subscriptions.  A subscription is required to run this tool'
        } 

        $subCount = 0
        foreach($sub in $subList){
            $subCount++
            $sub | Add-Member -type NoteProperty -name RowNumber -value $subCount
        }

        Write-Host ''
        Write-Host 'Your Azure Subscriptions: '
		if ($global:useCaseName -eq 'connectedcar')
		{
			Write-Host 'Select a subscription that has Azure Stream Analytics (ASA) enabled. If you do not have access to the ASA preview email nrtpmteam@microsoft.com for assistance.'
		}
        $subList | Format-Table RowNumber,SubscriptionId,SubscriptionName -AutoSize
        $rowNum = Read-Host 'Enter the row number (1 -'$subCount') of a subscription'

        while( ([int]$rowNum -lt 1) -or ([int]$rowNum -gt [int]$subCount)){
            Write-Host 'Invalid subscription row number. Please enter a row number from the list above'
            $rowNum = Read-Host 'Enter subscription row number'                     
        }
        $global:subscriptionID = $subList[$rowNum-1].SubscriptionId;
        $global:subscriptionDefaultAccount = $subList[$rowNum-1].DefaultAccount.Split('@')[0]
    }

    #switch to appropriate subscription
    try{
        Select-AzureSubscription -SubscriptionId $global:subscriptionID
        $global:dict.Add('<subId>', $global:subscriptionID)
        $global:dict.Add('<subName>', $subList[[int]$rowNum-1].SubscriptionName)
    } catch {
        throw 'Subscription ID provided is invalid: ' + $global:subscriptionID 
    }
}


function CreateAffinityGroup{
    #create affinity group
    Switch-AzureMode AzureServiceManagement
    $affinityGroup = $null
    try {
            $affinityGroup = New-AzureAffinityGroup -Name $global:affinityGroupName -location $global:locationMultiWord
        } 
    catch
        { 
            Write-Host 'error.'
            throw
        }    
    Write-Host 'created.'
    return $affinityGroup
}


function DeleteAffinityGroup{
    Switch-AzureMode AzureServiceManagement
    try{
        Write-Host 'Deleting Affinity Group [' $global:affinityGroupName ']......' -NoNewline
        Remove-AzureAffinityGroup -Name $global:defaultResourceName -ErrorAction Stop
    }catch{        
        if($error[0].Exception.Error.Code -ne 'ResourceNotFound'){ 
            Write-Host 'error.'
            throw 
        }
    }
    Write-Host 'deleted.'
}

function CreateResourceGroup{
    Switch-AzureMode -Name AzureResourceManager
    #create resource group
    $rg = $null
    try{
        Write-Host 'Creating Resource Group [' $global:resourceGroupName ']......' -NoNewline
        $rg = New-AzureResourceGroup -Name ($global:resourceGroupName) -location $global:location -ErrorAction Stop -Force | out-null
        #will update if already exists
    } catch {
        Write-Host 'error.' 
        throw
    }
    Write-Host 'created.'
    return $rg
}


function DeleteResourceGroup{
    Switch-AzureMode AzureResourceManager
    try{
        Write-Host 'Deleting Resource Group [' $global:resourceGroupName ']......' -NoNewline
        Remove-AzureResourceGroup -Name $global:resourceGroupName -ErrorAction Stop -Force
    }catch [ArgumentException]{
        # resource group does not exist
    } catch {
        Write-Host 'error.'
    }
    Write-Host 'deleted.'
}

function CreateStorageAccount{
    Param($affinityGroup)
    Process{
        Switch-AzureMode AzureServiceManagement
        $storage = $null
        try{
            Write-Host 'Creating Storage Account [' $global:storageAccountName ']......' -NoNewline
            #create a new Azure Storage Account
            $storage = New-AzureStorageAccount -storageAccountName $global:storageAccountName -location $global:locationMultiWord -ErrorAction Stop
        } catch {
            if($storage -eq $null -and $error[0].Exception.Error.Code -eq 'ConflictError'){
                Write-Host 'already exists.'
                #storage account already exists 
            }else{
                Write-Host 'error.'
                throw
            }
        }

        
        try{
            # Get Storage Key information
            $blobAccountkey = Get-AzureStorageKey -storageAccountName $global:storageAccountName
            # Get Context
            $context = New-AzureStorageContext -storageAccountName $global:storageAccountName -StorageAccountKey $blobAccountkey.Primary
            $global:storageAccountKey = $blobAccountkey.Primary
            
            # Create the container to store blob
            $container = New-AzureStorageContainer -Name $global:blobContainerName -Context $context -ErrorAction Stop        
        }catch{
            if($error[0].CategoryInfo.Category -eq 'ResourceExists'){
                Write-Host 'resource exists.'
            }else{
                Write-Host 'error.'
            }
        }
        Write-Host 'created.'
        return $storage
    }
}

function DeleteStorageAccount{
    Switch-AzureMode AzureServiceManagement
    try{
        Write-Host 'Deleting Storage Account [' $global:storageAccountName ']......' -NoNewline
        Remove-AzureStorageAccount -storageAccountName $global:storageAccountName -ErrorAction Stop | out-null
    }catch{
        if($error[0].Exception.Error.Code -ne 'ResourceNotFound'){ 
            Write-Host 'error.'
            throw 
        }
    }
    Write-Host 'deleted'.
}

function CreateSQLServerAndDB{
    process{
        Write-Host 'Creating SQL Server ...... ' -NoNewline
        Switch-AzureMode AzureServiceManagement
        #create sql server & DB
    
        $sqlsvr = $null
        $createdNew = $FALSE


        try{ 
            $sqlsvrname = Get-Content -Path $global:configPath -ErrorAction SilentlyContinue -WarningAction SilentlyContinue 
            $global:sqlserverName = $sqlsvrname
            
            if($sqlsvrname -eq $null -or $sqlsvrname.Length -le 1){
                $sqlsvr = New-AzureSqlDatabaseServer -location $global:locationMultiWord -AdministratorLogin $global:sqlServerLogin -AdministratorLoginPassword $global:sqlServerPassword 
                $sqlsvrname = $sqlsvr.ServerName
                Set-Content -Path $global:configPath -Value $sqlsvrname 
                $createdNew = $TRUE;
                
                Write-Host '[svr name: ' $sqlsvrname ']....created.' 
                $global:sqlserverName = $sqlsvrname
            } else {
                Write-Host '[svr name: ' $sqlsvrname ']......already exists.'
            }
        } catch{        
            Write-Host 'error.'
            throw
        }

        if($createdNew){
            $rule = New-AzureSqlDatabaseServerFirewallRule -ServerName $sqlsvr.ServerName -RuleName “demorule” -StartIPAddress “0.0.0.0” -EndIPAddress “255.255.255.255” -ErrorAction SilentlyContinue 

            $global:progressMessages.Add("Creating database - $global:sqlDBName")     
            try{
                Write-Host 'Creating SQL DB [' $global:sqlDBName ']......' -NoNewline 
                $servercredential = new-object System.Management.Automation.PSCredential($sqlServerLogin, ($sqlServerPassword  | ConvertTo-SecureString -asPlainText -Force))
                #create a connection context
                $ctx = New-AzureSqlDatabaseServerContext -ServerName $sqlsvrname -Credential $serverCredential 
                $sqldb = New-AzureSqlDatabase $ctx –DatabaseName $global:sqlDBName -Edition Basic   >> setup-log.txt
                Write-Host 'created.'
            } catch {
                Write-Host 'error.'
                throw
            }
        }
        return $sqldb
    }
}


function DeleteSQLServerAndDB{
    Switch-AzureMode AzureServiceManagement
    $sqlsvrname = ""

    # check whether the file exist before Get-Content
    # if there are no prior deployment, the file does not exist.
    if( (Test-Path "$global:configPath") -eq "True") 
    {
        $sqlsvrname = Get-Content $global:configPath
    }

    if($sqlsvrname.Length -gt 0) {
        try{
            Write-Host 'Deleting SQL Svr [' $sqlsvrname '] & SQL DB [' $global:sqlDBName ']......' -NoNewline 
            Remove-AzureSqlDatabaseServer -ServerName $sqlsvrname -Force            
            Set-Content -Path $global:configPath -Value ''
        
            Write-Host 'deleted.' 
        } catch [InvalidOperationException] {
            #thrown when svr doesnt exist
            Write-Host 'doesnt exist.'
        } catch {
            Write-Host 'error.'
        }
    }    
}


function CreateDataFactory{
    Process{
        Switch-AzureMode AzureResourceManager
        $adf = $null
        try{
            Write-Host 'Creating Data Factory [' $global:defaultResourceName ']......' -NoNewline
            #will force overwrite if already exists
            $adf = New-AzureDataFactory -Name $global:defaultResourceName -location $global:locationMultiWord -ResourceGroupName $resourceGroupName -Force  | out-null
            Write-Host 'created.'    
        }catch {
            Write-Host 'error.'
            throw
        }
        return $adf
    }
}

function DeleteDataFactory{
    Process{
        Switch-AzureMode AzureResourceManager
        $retryCount = 2;
        $done = $false
        $errormsg = ''
        while($retryCount -gt 0 -and $done -ne $true){
            try{
                Write-Host 'Deleting Data Factory [' $global:defaultResourceName ']......' -NoNewline
                #does not throw if datafactory does not exist
                Remove-AzureDataFactory -Name $global:defaultResourceName -ResourceGroupName $resourceGroupName -WarningAction SilentlyContinue -Force -ErrorAction Stop
                $done = $true
                Write-Host 'deleted.'                
            } catch {
                if($error[0].Exception.ToString().contains('ResourceGroupNotFound')){
                    Write-Host 'doesnt exist.'
                    $retryCount = 0
                    $done = $true
                } else{
                    Write-Host 'error. retrying delete....'
                    $errormsg = $error[0].Exception.Message
                }                         
            }
            $retryCount--; 
        }
        if($done -eq $false){ 
            Write-Host 'error.' $errormsg
        }
    }
}

function CreateASAJob{
	Process{
		Switch-AzureMode AzureResourceManager
		
		copy -Path "src\\$global:useCaseName\\ASAJobForADFOutput\\ASAJob.json" -Destination temp\json\asa\ -Force
		$files = Get-ChildItem "temp\json\asa\*" -Include ASAJob.json -Recurse -ErrorAction Stop
		foreach($file in $files)
		{
        Update-ASAJSONFile  $file.FullName
		}
	
		try{
			Write-Host 'Creating the ASA Job......' -NoNewline
            $ASAJob = New-AzureStreamAnalyticsJob -File "temp\json\asa\ASAjob.json" -Name $global:defaultResourceName -ResourceGroupName $global:resourceGroupName -force 
			if ($ASAJob.JobName -eq $global:defaultResourceName)
			{
            Write-Host 'created.'
			}
        }catch {
            Write-Host 'error.'
            throw
        }
	
	}
}

function DeleteASAJob{
    Process{
        Switch-AzureMode AzureResourceManager
        $retryCount = 2;
        $done = $false
        $errormsg = ''
        while($retryCount -gt 0 -and $done -ne $true){
            try{
                Write-Host 'Deleting ASA Job [' $global:defaultResourceName ']......' -NoNewline
                Remove-AzureStreamAnalyticsJob -Name $global:defaultResourceName -ResourceGroupName $global:resourceGroupName -Force -ErrorAction Stop
                $done = $true
                Write-Host 'deleted.'                
            } catch {
                if($error[0].Exception.ToString().contains('ResourceGroupNotFound')){
                    Write-Host 'doesnt exist.'
                    $retryCount = 0
                    $done = $true
                } else{
                    Write-Host 'error. retrying delete....'
                    $errormsg = $error[0].Exception.Message
                }                         
            }
            $retryCount--; 
        }
        if($done -eq $false){ 
            Write-Host 'error.' $errormsg
        }
    }
}

function CreateAzureWebsite{  
    Process{
        Switch-AzureMode AzureServiceManagement
        $azurewebsite = $null
		$eventhub = $null
		
        try{            
			$azurewebsite = Get-AzureWebsite -Name $global:azureWebsiteName 
			if($azurewebsite.name -ne $global:azureWebsiteName)
			{
			Write-Host 'Creating Azure Website ['$global:azureWebsiteName']......' -NoNewline
            #create a new Azure Website
            $azurewebsite = New-AzureWebsite -Name $global:azureWebsiteName -Location $global:locationMultiWord -ErrorAction Stop | out-null
			Write-Host 'created.'
			}
			else {
			Write-Host 'Creating Azure Website ['$global:azureWebsiteName']...... already exists.'
			}
		 }catch{
                Write-Host 'error.'
                throw
		}          
    }
}

function DeleteAzureWebsite{
    Switch-AzureMode AzureServiceManagement
    try{
        Write-Host 'Deleting Azure Website [' $global:azureWebsiteName ']......' -NoNewline
        Remove-AzureWebsite -Name $global:azureWebsiteName -Force -ErrorAction Stop | out-null
    }catch{
        if($error[0].Exception.Error.Code -ne 'ResourceNotFound'){ 
            Write-Host 'error.'
            throw 
        }
    }
    Write-Host 'deleted'.
}

function CreateEventHubandSBNamespace{
  
    Process{
        Switch-AzureMode AzureServiceManagement
        $namespace = $null
		$eventhub = $null
	
		
        try{
            #Write-Host "Creating EventHub and ServiceBus Namespace"
			# WARNING: Make sure to reference the latest version of the \Microsoft.ServiceBus.dll
			$namespace = Get-AzureSBNamespace -Name $global:ServiceBusNamespace 
			if($namespace.name -eq $null)
			{
			Write-Host 'Creating Service Bus Namespace ['$global:ServiceBusNamespace']......' -NoNewline
            #create a new Service Bus Namespace
            $namespace = New-AzureSBNamespace -Name $global:ServiceBusNamespace -Location $global:locationMultiWord -CreateACSNamespace $true -NamespaceType Messaging -ErrorAction Stop
			Write-Host 'created.'
			}
			else {
			Write-Host 'exists.'
			}
		 }catch{
                Write-Host 'error.'
                throw
			}
               
        try{		
			#Create the NamespaceManager object to create the event hub
			$currentnamespace = Get-AzureSBNamespace -Name $global:ServiceBusNamespace
			Write-Host 'Creating NamespaceManager object for the ['$global:ServiceBusNamespace'] namespace...' -NoNewline
			$nsMgrType = [System.Reflection.Assembly]::LoadFrom($PSScriptRoot +"\src\\$global:useCaseName\\bin\Debug\Microsoft.ServiceBus.dll").GetType("Microsoft.ServiceBus.NamespaceManager")
			$namespacemanager = $nsMgrType::CreateFromConnectionString($currentnamespace.ConnectionString);
			Write-Host 'created.'
			Write-Host 'Creating EventHub ['$global:EventHubName']......' -NoNewline
			$eventhub = $namespacemanager.CreateEventHubIfNotExists($global:EventHubName)
			Write-Host 'created.'
			$global:constring = Get-AzureSBAuthorizationRule -Namespace $global:ServiceBusNamespace
			$constringparse = $global:constring.ConnectionString.Split(';')
			$global:sharedaccesskeyname = $constringparse[1].Substring(20)
			$global:sharedaccesskey = $constringparse[2].Substring(16)
			#	Write-Host 'Event Hub ConnectionString: ['$global:constring.ConnectionString']'
        }catch{
                  Write-Host 'error.'
				  throw
            }
        		
    }
}

function DeleteventHubandSBNamespace{

	$namespace = get-content "temp\sbnamespace.txt"
	#Write-Host The namespace is $namespace
	$serviceBusDll = $PSScriptRoot + "\src\\$global:useCaseName\\bin\Debug\Microsoft.ServiceBus.dll"
	Add-Type -Path $serviceBusDll
	try
	{
    $currentnamespace = Get-AzureSBNamespace -Name $namespace #$global:ServiceBusNamespace
	}
	catch
	{
    Write-Host Azure Service Bus Namespace: $namespace not found! 
	}

	if ($currentnamespace)
	{
  
    Write-Host 'Deleting ServiceBus Namespace......' -NoNewline
    try
    {
        Remove-AzureSBNamespace -Name $namespace -Force
        Write-Host 'deleted'.
    }
    catch
    {
         Write-Host 'error'.
        throw
    }
	}
	else
	{
    Write-Host The namespace $namespace does not exists.  
	}
}


function CreateProductRecommendationResources{
    Write-Host 'Creating Azure services for product recommendation use case:'

    CreateResourceGroup
    $affinityGroup = CreateAffinityGroup 
    $storageAccount = CreateStorageAccount $affinityGroup
    CreateSQLServerAndDB 
	CreateAzureWebsite
    $adf = CreateDataFactory

    Write-Host 'Completed creating Azure services.'
}

function DeleteProductRecommendationResources{
    Write-Host 'Deleting Azure services for product recommendation use case:'

    DeleteStorageAccount
    DeleteAffinityGroup
    DeleteSQLServerAndDB
	DeleteAzureWebsite
    DeleteDataFactory
    DeleteResourceGroup

    Write-Host 'Completed deleting Azure services.'
}

function CreateCustomerChurnResources{
    Write-Host "Creating customer churn resources"

    CreateResourceGroup
    $affinityGroup = CreateAffinityGroup 
    $storageAccount = CreateStorageAccount $affinityGroup
    CreateSQLServerAndDB
    $adf = CreateDataFactory

    # Create BES Endpoint and key
    $global:dict.Add('<ML BES Endpoint>',
          'https://ussouthcentral.services.azureml.net/workspaces/c6ae32adb5d045e3809e5ea4c551b086/services/a37aa219413843ea9ac183f985b57f7a/jobs')
    $global:dict.Add('<API Key>','VhvzrMhKkPtnCl7/kjLpaBBMcFuKIbh+EQZlOv6apJ5aj27jUfVbd5sbgcoQ3/Hl9rdPIVpftEpZ7V/yULoMbg==')

}

function DeleteCustomerChurnResources{
    DeleteStorageAccount
    DeleteAffinityGroup
    DeleteSQLServerAndDB
    DeleteDataFactory
    DeleteResourceGroup
}

function CreateConnectedCarResources{
    Write-Host "Creating connected cars resources"

    CreateResourceGroup
    $affinityGroup = CreateAffinityGroup 
    $storageAccount = CreateStorageAccount $affinityGroup
    CreateSQLServerAndDB
	CreateEventHubandSBNamespace
    $adf = CreateDataFactory
	SetMappingDictionary
	CreateASAJob

}

function DeleteConnectedCarResources{
    DeleteStorageAccount
    DeleteAffinityGroup
	DeleteventHubandSBNamespace
    DeleteSQLServerAndDB
    DeleteDataFactory
    DeleteResourceGroup
	DeleteASAJob
}


function PopulateCustomerChurn{
    Write-Host ""
    Write-Host "Deploying use case content (scripts, sample data, etc) to the resources created..."

    #$global:dict
    #Remove files in temp\json
    $files = Get-ChildItem "temp\json\*" -Include *.json -Recurse -ErrorAction Stop
    foreach($file in $files)
    {
        remove-item  $file.FullName
    }

    #Get the Excel data file in the right folder for Power BI designer
    New-Item c:\temp -ItemType directory -Force >> setup-log.txt
    copy -Path "redist\\PowerBI\\$global:useCaseName\\*.xlsx" -Destination "c:\temp" -Force >> setup-log.txt

    copy -Path "src\\$global:useCaseName\\*.json" -Destination "temp\json" -Force
    $files = Get-ChildItem "temp\json\*" -Include *.json -Recurse -ErrorAction Stop
 
    #Prep work to deplpoy the pipelines/data sets and linked services
    foreach($file in $files)
    {
        Update-JSONFile  $file.FullName
    }
    #Write-Host "Updated "  $files.Length  " ADF JSON files that will be used in deployment. JSON files are stored in temp\json"

    #Upload the hive scripts to the container
    #$global:storageAccountName
    switch-azureMode AzureServiceManagement
    #Write-Verbose   "Preparing the storage account - $global:storageAccountName "
    $destContext = New-AzureStorageContext  –StorageAccountName $global:dict["<account name>"] -StorageAccountKey $global:dict["<account key>"] -ea silentlycontinue 
    If ($destContext -eq $Null) {
	    Write-Host "Invalid storage account name and/or storage key provided"
	    Exit
    }

    #check whether the Azure storage containe already exists
    $scriptcontainerName = "scripts"
    #Write-Verbose   "Preparing the container [$scriptcontainerName] storage account - $global:storageAccountName "
    $container = Get-AzureStorageContainer -Name $scriptcontainerName -context $destContext –ea silentlycontinue
    If ($container -eq $Null) {
	    #Write-Host "Creating storage container [$scriptcontainerName]"
	    New-AzureStorageContainer -Name $scriptcontainerName -context $destContext   2>&1 3>&1 4>&1 1>>setup-log.txt
    }
    else {
	    #Write-Host "[$scriptcontainerName] exists."
    }

    $files = Get-ChildItem "scripts\$global:useCaseName\*" -Include *.hql -Recurse -ErrorAction Stop
    #Write-Host  "Uploading demo scripts to the storage container [$scriptcontainerName]"
    foreach($file in $files)
    {
        Set-AzureStorageBlobContent -File $file.FullName -Container $scriptcontainerName -Context $destContext -Blob $file.Name -Force 2>&1 3>&1 4>&1 1>>setup-log.txt
    }
    
    try {
	    # Upload seed file and data generator Python script
	    Set-AzureStorageBlobContent -File ".\scripts\datagen\CallingNumFeed.csv" -Container $scriptcontainerName -Context $destContext -Blob "datagen\CallingNumFeed.csv" -Force 2>&1 3>&1 4>&1 1>>setup-log.txt
	    Set-AzureStorageBlobContent -File ".\scripts\datagen\createCDR.py" -Container $scriptcontainerName -Context $destContext -Blob "datagen\createCDR.py" -Force 2>&1 3>&1 4>&1 1>>setup-log.txt
        Set-AzureStorageBlobContent -File ".\scripts\datagen\cat.exe" -Container $scriptcontainerName -Context $destContext -Blob "datagen\cat.exe" -Force 2>&1 3>&1 4>&1 1>>setup-log.txt
        Set-AzureStorageBlobContent -File ".\scripts\datagen\input.txt" -Container $scriptcontainerName -Context $destContext -Blob "datagen\input.txt" -Force 2>&1 3>&1 4>&1 1>>setup-log.txt
	}
    catch {
        echo "Error occured when uploading datagen scripts"  >> setup-log.txt
    }

    $datacontainerName = "data"
    Write-Verbose   "Preparing the container [$datacontainerName] storage account - $global:storageAccountName "
    $container = Get-AzureStorageContainer -Name $datacontainerName -context $destContext –ea silentlycontinue
    If ($container -eq $Null) {
	    #Write-Host "Creating storage container [$datacontainerName]"
	    New-AzureStorageContainer -Name $datacontainerName -context $destContext  2>&1 3>&1 4>&1 1>>setup-log.txt
    }
    else {
	    #Write-Host "[$datacontainerName] exists."
    }
    Set-AzureStorageBlobContent -File ".\data\customerchurn\cdr2015.csv" -Container $datacontainerName -Context $destContext -Blob "rawdata\cdr2015.csv" -Force 2>&1 3>&1 4>&1 1>>setup-log.txt
    Set-AzureStorageBlobContent -File ".\data\customerchurn\CustomerInfo.csv" -Container $datacontainerName -Context $destContext -Blob "dimcustomer\CustomerInfo.csv" -Force 2>&1 3>&1 4>&1 1>>setup-log.txt

    Switch-AzureMode AzureResourceManager
    #Write-Host $global:progressMessages

    #Write-Host "Preparing the Azure SQL Database with output tables/stored procedures and types"
    sqlcmd -S "$global:sqlserverName.database.windows.net" -U "$global:sqlServerLogin@$global:sqlserverName" -P $global:sqlServerPassword -i .\scripts\$global:useCaseName\customerchurnprepsqldb.sql -d customerchurn 2>&1 3>&1 4>&1 1>>setup-log.txt
    
    #$scriptPath = (Join-Path -Path "." -ChildPath ".\src\deployFolder.ps1")
    #$scriptPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($scriptPath)
    $scriptPath = ".\src\deployFolder.ps1"
    $jsonPath = "`"temp\json`""

    $argumentList = @()
    $argumentList += ("-ResourceGroupName", $global:resourceGroupName )
    $argumentList += ("-DataFactoryName", $global:defaultResourceName)
    $argumentList += ("-JsonFilesFolder",  $jsonPath )    
    #Write-Host $argumentList


    #ShowCustomerChurnRemainingTODOs

    #Deploy the pipelines/data sets and linked services
    Invoke-Expression "$scriptPath $argumentList >> setup-log.txt"

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

    copy -Path "src\\$global:useCaseName\\*.json" -Destination "temp\json" -Force
    $files = Get-ChildItem "temp\json\*" -Include *.json -Recurse -ErrorAction Stop
 
    #Prep work to deplpoy the pipelines/data sets and linked services
    foreach($file in $files)
    {
        Update-JSONFile  $file.FullName
    }
    #Write-Host "Updated "  $files.Length  " ADF JSON files that will be used in deployment. JSON files are stored in temp\json"
	
	copy -Path "src\\$global:useCaseName\\*.config" -Destination "temp\config" -Force	
	$files = Get-ChildItem "temp\config\*" -Include *.config -Recurse -ErrorAction Stop
 
	#Update the WebConfig file with the genrated sql server name
    foreach($file in $files)
    {
        Update-JSONFile  $file.FullName
    }
	
	copy -Path "temp\config\*.config" -Destination "website\Promotions\Promotions" -Force
	    
    #Upload the hive scripts to the container
    #$global:storageAccountName
    switch-azureMode AzureServiceManagement
    #Write-Verbose   "Preparing the storage account - $global:storageAccountName "
    $destContext = New-AzureStorageContext  –StorageAccountName $global:dict["<account name>"] -StorageAccountKey $global:dict["<account key>"] -ea silentlycontinue
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
	
    Switch-AzureMode AzureResourceManager
    #Write-Host $global:progressMessages

    #Write-Host "Preparing the Azure SQL Database with output tables/stored procedures and types"
    sqlcmd -S "$global:sqlserverName.database.windows.net" -U "$global:sqlServerLogin@$global:sqlserverName" -P $global:sqlServerPassword -i .\scripts\productrec\productrecommendationssqldb.sql -d $global:useCaseName 2>&1 3>&1 4>&1 1>>setup-log.txt
   
    
    #$scriptPath = (Join-Path -Path "." -ChildPath ".\src\deployFolder.ps1")
    #$scriptPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($scriptPath)
    $scriptPath = ".\src\deployFolder.ps1"
    $jsonPath = "`"temp\json`""

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


function ShowCustomerChurnRemainingTODOs {
   #Show remainining TODOs to get the demo running
    Write-Host "Azure SQL Database [ $global:sqlserverName ]. "
    Write-Host "Script customerchurnprepsqldb.sql found in .\scripts enables you to reset the database."
    Write-Host ""

}

function ShowProductRecommendationsRemainingTODOs {
   #Show remainining TODOs to get the demo running
    Write-Host "Remember to connect to the Azure SQL Database [ $global:sqlserverName ]. "
    Write-Host "Script productrecommendationssqldb.sql found in .\scripts\productrecommendaions enables you to reset the database."

}

function PopulateConnectedCar{
    Write-Host "Deploying use case content (scripts, sample data, etc) to the resources created..."

    #Remove files in temp\json
    $files = Get-ChildItem "temp\json\*" -Include *.json -Recurse -ErrorAction Stop
    foreach($file in $files)
    {
        remove-item  $file.FullName
    }

	#Write-Host 'Preparing Data Generator config file......' -NoNewline
	$datgenconfig = ($PSScriptRoot + "\src\\$global:useCaseName\\CarEventGenerator\\CarEventGenerator.exe.config")
	[xml] $doc = Get-Content $datgenconfig
	
	$doc.SelectSingleNode('//appSettings/add[@key="inputeventhub"]/@value').'#text' = $global:EventHubName
	$doc.SelectSingleNode('//appSettings/add[@key="inputservicebus"]/@value').'#text' = $global:ServiceBusNamespace 
	$doc.SelectSingleNode('//appSettings/add[@key="servicebusconnectionstring"]/@value').'#text' = $global:constring.ConnectionString 
	$doc.Save($datgenconfig)
	#Write-Host 'prepared.'
	
	#Upload the hive scripts to the container
    $global:storageAccountName
    switch-azureMode AzureServiceManagement
    #Write-Verbose   "Preparing the storage account - $global:storageAccountName "

    $destContext = New-AzureStorageContext  –StorageAccountName $global:dict["<account name>"] -StorageAccountKey $global:dict["<account key>"] -ea silentlycontinue
    If ($destContext -eq $Null) {
	    Write-Verbose "Invalid storage account name and/or storage key provided"
	    Exit
    }

    #check whether the Azure storage container already exists --not required
    $scriptcontainerName = "scripts"
    #Write-Verbose   "Preparing the container [$scriptcontainerName] storage account - $global:storageAccountName "
    $container = Get-AzureStorageContainer -Name $scriptcontainerName -context $destContext –ea silentlycontinue
    If ($container -eq $Null) {
	    echo "Creating storage container [$scriptcontainerName]" >> setup-log.txt
	    New-AzureStorageContainer -Name $scriptcontainerName -context $destContext  >> setup-log.txt
    }
    else {
	    echo "[$scriptcontainerName] exists." >> setup-log.txt
    }

    $files = Get-ChildItem "src\\$global:useCaseName\\scripts\\*" -Include *.hql -Recurse -ErrorAction Stop
    #Write-Host  'Uploading Hive scripts to the storage container ['$global:blobContainerName']'
    foreach($file in $files)
    {
       Set-AzureStorageBlobContent -File $file.FullName -Container $global:blobContainerName -Context $destContext -Blob ("scripts\" + $file.Name) -Force >> setup-log.txt
    }
    
	# Upload reference data
	#Write-Host  Uploading reference data to the storage container $global:blobContainerName3
	Set-AzureStorageBlobContent -File "src\\$global:useCaseName\\referencedata\\VINRefData.csv" -Container $global:blobContainerName -Context $destContext -Blob "referencedata\VINRefData.csv" -Force >> setup-log.txt
	
	# Upload cold path sample data generator package zip to azure blob storage
	#Write-Host  Uploading batch data generator package zip to the storage container $global:blobContainerName
	Set-AzureStorageBlobContent -File "src\\$global:useCaseName\\scripts\\connectedcar.zip" -Container $global:blobContainerName -Context $destContext -Blob "scripts\connectedcar.zip" -Force >> setup-log.txt
	
	#Write-Host "Preparing ADF JSON files" 
	copy -Path "src\\$global:useCaseName\\ADF\\*.json" -Destination temp\json -Force
    $files = Get-ChildItem "temp\json\*" -Include *.json -Recurse -ErrorAction Stop
	
    foreach($file in $files)
    {
       Update-JSONFile  $file.FullName
   
    }
	
   Switch-AzureMode AzureResourceManager
   #Write-Host $global:progressMessages
    
   
   
   #Write-Host "Preparing the Azure SQL Database with output tables/stored procedures and types"
   sqlcmd -S "$global:sqlserverName.database.windows.net" -U $global:sqlServerLogin@$global:sqlserverName -P $global:sqlServerPassword -i "src\\$global:useCaseName\\scripts\\connectedcarsqldb.sql" -d connectedcar 2>&1 3>&1 4>&1 1>>setup-log.txt

    
   #Write-Host Starting the ASA Job [$global:defaultResourceName]. This may take few minutes.....
   try{
   #$StartASAJob = Start-AzureStreamAnalyticsJob -Name $global:defaultResourceName -ResourceGroupName StreamAnalytics-Default-West-Europe
   $StartASAJob = Start-AzureStreamAnalyticsJob -Name $global:defaultResourceName -ResourceGroupName $global:resourceGroupName 2>&1 3>&1 4>&1 1>>setup-log.txt
   #if ($StartASAJob -eq "True")
   #{
		#Write-Host 'started.'
   #}
   }catch {
            #Write-Host 'error.'
            throw
   }
   
  
    #$scriptPath = (Join-Path -Path "." -ChildPath ".\src\deployFolder.ps1")
    #$scriptPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($scriptPath)
    $scriptPath = ".\src\deployFolder.ps1"
    $jsonPath = "`"temp\json`""

    $argumentList = @()
    $argumentList += ("-ResourceGroupName", $global:resourceGroupName )
    $argumentList += ("-DataFactoryName", $global:defaultResourceName)
    $argumentList += ("-JsonFilesFolder",  $jsonPath )    
    #Write-Host $argumentList
   
   #Deploy the pipelines/data sets and linked services
    Invoke-Expression "$scriptPath $argumentList 2>&1 3>&1 4>&1 1>>setup-log.txt" 
    
}

function writeAccountInformation {
   $accountFile = "$global:useCaseName-accounts.txt"
   copy -Path "src\\account-template.txt" -Destination ".\\$accountFile" -Force
   Update-JSONFile ".\\$accountFile"
}

#start of main script
$storePreference = $Global:VerbosePreference
ValidateParameters
SetGlobalParams
InitSubscription   

$Global:VerbosePreference = "SilentlyContinue"
$setupDate = [DateTimeoffset]::Now
echo "Setup Logs" > setup-log.txt
echo $setupDate.ToString()  >> setup-log.txt
echo "-------------------------------------------------------" >> setup-log.txt

try {
    switch($global:useCaseName){
        'customerchurn'{
            switch($global:mode){
                'deploy'{
                    CreateCustomerChurnResources
                    SetMappingDictionary
                    writeAccountInformation
                    PopulateCustomerChurn
                }
                'delete'{
                    DeleteCustomerChurnResources
                }
            }    
        }
    }
}
catch {
    if($error[0].Exception.Error.Code -eq 'MissingSubscriptionRegistration'){
        if ($global:useCaseName -eq 'connectedcar')
		{
			Write-Host 'Select a subscription that has Azure Stream Analytics (ASA) enabled. If you do not have access to the ASA preview email nrtpmteam@microsoft.com for assistance.'
		}
     }else{
        Write-Host 'Setup error. Contact datausecase@microsoft.com for help. '
        throw
     }   
}

$Global:VerbosePreference = $storePreference






