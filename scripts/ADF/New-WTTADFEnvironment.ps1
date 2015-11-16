Function New-WTTADFEnvironment
{
[CmdletBinding()]
Param(
   [Parameter()]
   [Alias("subscriptionID")]
   [string]$global:subscriptionID,

   [Parameter()]
   [Alias("mode")]
   [string]$global:mode,

   [Parameter()]
   [Alias("sqllogin")]
   [string]$global:sqlServerLogin = 'mylogin',

   [Parameter()]
   [Alias("sqlpassword")]
   [string]$global:sqlServerPassword = 'pass@word1',
           
   #WTT Environment Application Name
   [Parameter()]
   [String]$WTTEnvironmentApplicationName,
           
   #Azure Active Directory Tenant Name
   [Parameter(Mandatory=$false)]
   [String]
   $AzureActiveDirectoryTenantName
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
}

function DisplayMode {
    Write-Host
    Write-Host '------------------------------------------'
    Write-Host 'Mode: ' $global:mode
    Write-Host 'Use Case: ' $global:useCaseName   
    Write-Host '------------------------------------------'
}

function SetGlobalParams {
    #this function must be called after ValidateParams
    

    [string]$global:location = 'CentralUS'
    [string]$global:locationMultiWord = 'Central US'


    $output = ($global:useCaseName + $WTTEnvironmentApplicationName).ToLower()
    if($output.Length -gt 14) { $output = $output.Remove(15) }

	if ($global:mode -eq 'deploy')
	{
		$global:ServiceBusNamespace = $output
		$global:ServiceBusNamespace | out-file -filepath "temp\sbnamespace.txt"
	}
	
    $global:useCaseName = $output.ToLower()
    $global:useCaseName = $global:useCaseName

    $global:defaultResourceName = $output 
    $global:storageAccountName = $output
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
    if ($global:subscriptionID -eq $null -or $global:subscriptionID -eq ''){
        $subList = Get-AzureSubscription

        if($subList.Count -lt 1){
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

function registerDataFactoryProvider
{
	        #Switch Azure Powershell Mode
			Switch-AzureMode AzureResourceManager
            
            # Load ADAL Assemblies
            $adal = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
            $adalforms = "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
            $null = [System.Reflection.Assembly]::LoadFrom($adal)
            $null = [System.Reflection.Assembly]::LoadFrom($adalforms)

            # Get Service Admin Live Email Id since we don't have native access to the Azure Active Directory Tenant Name from within Azure PowerShell
            [string]$adTenantAdminEmailId = (Get-AzureSubscription -Current -ExtendedDetails).AccountAdminLiveEmailId
            $AzureActiveDirectoryTenantName = ""
            $userid = (Get-AzureSubscription -Current -ExtendedDetails).Accounts
            $id = $userid.id
            $user = $id.Split('@')[-1] 
         
            if ($AzureActiveDirectoryTenantName -eq "")
            {
                if ($adTenantAdminEmailId.Contains("@microsoft.com"))
                {                
                    $adTenantName = "microsoft"
                    $adTenant = "$adTenantName.onmicrosoft.com"
                }
                else
                {
                    [string]$adTenantNameNoAtSign = ($adTenantAdminEmailId).Replace("@","")
                    $adTenantNameIndexofLastPeriod = $adTenantNameNoAtSign.LastIndexOf(".")
                    $adTenantNameTemp = $adTenantNameNoAtSign.Substring(0,$adTenantNameIndexofLastPeriod)
                    $adTenantName = ($adTenantNameTemp).Replace(".","")
                    $adTenant = "$adTenantName.onmicrosoft.com"
                }
            }
            else
            {
                $adTenantName = $AzureActiveDirectoryTenantName
                $adTenant = $adTenantName
            }
            
            if ($adTenant -ne $user)
            {
                    $adTenant = $user
            } 
    
            # Get subscription information
            $azureSubscription = (Get-AzureSubscription -Current -ExtendedDetails)
            $azureSubscriptionID = $azureSubscription.SubscriptionID
            # Set Azure AD Tenant name
            #$adTenant = "$adTenantName.onmicrosoft.com" 
            # Set well-known client ID for AzurePowerShell
            $clientId = "1950a258-227b-4e31-a9cf-717495945fc2" 
            # Set redirect URI for Azure PowerShell
            $redirectUri = "urn:ietf:wg:oauth:2.0:oob"
            $resourceClientID = "00000002-0000-0000-c000-000000000000"
            # Set Resource URI to Azure Service Management API
            $resourceAppIdURI = "https://management.core.windows.net/"
            # Set Authority to Azure AD Tenant
            $authority = "https://login.windows.net/$adTenant"
            # Create Authentication Context tied to Azure AD Tenant
            $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authority
            # Acquire token
            $authResult = $authContext.AcquireToken($resourceAppIdURI, $clientId, $redirectUri, "Auto")
            
            # API header
            $authHeader = $authResult.CreateAuthorizationHeader()
            $tenants = Invoke-RestMethod -Method GET -Uri "https://management.azure.com/tenants?api-version=2014-04-01" -Headers @{"Authorization"=$authheader} -ContentType "application/json"
            # Set HTTP request headers to include Authorization header
            #$tenant = $tenants.value.tenantId
            #$authority = [System.String]::Format("https://login.windows.net/$tenant")
            # Register subscription with DocDB provider
			$registerProviderUrl = [System.String]::Format("https://management.azure.com/subscriptions/$azureSubscriptionID/providers/Microsoft.DataFactory/register?api-version=2015-04-08")
			#Invoke-RestMethod -Method "POST" -ContentType "application/json" -Uri $registerProviderUrl -Headers $headers
            Invoke-RestMethod -Method POST -Uri $registerProviderUrl -Headers @{"Authorization"=$authHeader} -ContentType "application/json"

}

function CreateAffinityGroup{
    #create affinity group
    Switch-AzureMode AzureServiceManagement
    $affinityGroup = $null
    try {
			Write-Host 'Creating Affinity Group [' $global:affinityGroupName ']......' -NoNewline
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
            $container = New-AzureStorageContainer -Name 'productrec' -Context $context -ErrorAction Stop        
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
			Start-Sleep -s 20
            $adfsqlsvrname = get-AzureSqlDatabaseServer -ServerName $global:sqlserverName
            $adfsqlservername = [string]$adfsqlsvrname.ServerName
        } catch{        
            Write-Host 'error.'
            throw
        }

        if($createdNew){
            Start-Sleep -Seconds 30
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
            $adf = New-AzureDataFactory -Name $global:defaultResourceName -location 'West US' -ResourceGroupName $resourceGroupName -Force  | out-null
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
				DeleteProductRecommendationResources
				Write-Host 'An error occured during setup; it was repaired. :) Please, run script again.'
				throw
			}
		 }catch{
                Write-Host 'created.'
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
    #Write-Host "Updated "  $files.Length  " ADF JSON files that will be used in deployment. JSON files are stored in temp\json"
	
	#copy -Path "src\productrec\*.config" -Destination "temp\config" -Force	
	#$files = Get-ChildItem "temp\config\*" -Include *.config -Recurse -ErrorAction Stop
 
	#Update the WebConfig file with the genrated sql server name
    #foreach($file in $files)
    #{
    #    Update-JSONFile  $file.FullName
    #}
	
	#copy -Path "temp\config\*.config" -Destination "website\Promotions\Promotions" -Force
	    
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

function ShowProductRecommendationsRemainingTODOs {
   #Show remainining TODOs to get the demo running
    Write-Host "Remember to connect to the Azure SQL Database [ $global:sqlserverName ]. "
    Write-Host "Script productrecommendationssqldb.sql found in .\scripts\productrecommendaions enables you to reset the database."

}

function Set-ADFWebsiteWebConfig
{
            $azureADFWebSiteWebDeployPackagePath = (Get-Item -Path ".\" -Verbose).FullName + "\Packages\productrecommendations.zip"
			[string]$sqlsvrname = Get-Content -Path $global:configPath -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            $sqlsvrconnection = "$sqlsvrname.database.windows.net" 
            # Open zip and find the particular file (assumes only one inside the Zip file)
            $fileToEdit = "web.config"
            Add-Type -assembly  System.IO.Compression.FileSystem            
            $webDeployPackage = [System.IO.Compression.ZipFile]::Open($azureADFWebSiteWebDeployPackagePath,"Update")
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
            
            # Set the appSetttings values 


            $obj = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'SqlServer'}
            $obj.value = $sqlsvrconnection

            $obj = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'SqlDB'}
            $obj.value = $global:sqlDBName       
        
            $obj = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'SqlUserID'}
            $obj.value = $global:sqlServerLogin

            $obj = $webConfig.configuration.appSettings.add | where {$_.Key -eq 'SqlPassword'}
            $obj.value = $global:sqlServerPassword

                        
            $formattedXml = Format-XML -xml $webConfig.OuterXml
            
            # Write the changes and close the zip file
            $webConfigFileFinal = [System.IO.StreamWriter]($desiredWebConfigFile).Open()            
            $webConfigFileFinal.BaseStream.SetLength(0)
            $webConfigFileFinal.Write($formattedXml)            
            $webConfigFileFinal.Close()
            $webDeployPackage.Dispose()
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
    }#>
}



function writeAccountInformation {
   $accountFile = "$global:useCaseName-accounts.txt"
   copy -Path "src\\account-template.txt" -Destination ".\\$accountFile" -Force
   Update-JSONFile ".\\$accountFile"
}

#start of main script
$uniqueSuffix = $WTTEnvironmentApplicationName
$global:useCaseName = 'productrec' + $uniqueSuffix
$output = ($global:useCaseName).ToLower()
if($output.Length -gt 14) { $output = $output.Remove(15) }
$global:useCaseName = $output
$storePreference = $Global:VerbosePreference
ValidateParameters
SetGlobalParams
InitSubscription
registerDataFactoryProvider   

$Global:VerbosePreference = "SilentlyContinue"
$setupDate = [DateTimeoffset]::Now
echo "Setup Logs" > setup-log.txt
echo $setupDate.ToString()  >> setup-log.txt
echo "-------------------------------------------------------" >> setup-log.txt

try {
    switch($global:mode){
        'deploy'{
			DisplayMode
            CreateProductRecommendationResources
		    SetMappingDictionary
            writeAccountInformation
            PopulateProductRecommendation
            Set-ADFWebsiteWebConfig
            Start-Sleep -s 10
            Write-Host "### Deploying ADF Website $global:azureWebsiteName. ###" -foregroundcolor Yellow
            Switch-AzureMode AzureServiceManagement -WarningVariable null -WarningAction SilentlyContinue
			$azureADFWebSiteWebDeployPackagePath = (Get-Item -Path ".\" -Verbose).FullName + "\Packages\ProductRecommendations.zip"
            Publish-AzureWebsiteProject -Name $global:azureWebsiteName -Package $azureADFWebSiteWebDeployPackagePath                            
        }
        'delete'{
			$source = ".\temp\setup"
			$filter = [regex] "productrec"
			$bin = Get-ChildItem -Path $source | Where-Object {$_.Name -match $filter}
			foreach ($item in $bin){
				$item.name -match "productrec(?<content>.*).txt" | Out-Null
				$global:useCaseName = 'productrec' + $matches['content']
				DisplayMode
				SetGlobalParams
				try{
					DeleteProductRecommendationResources
				}
				catch{
					Write-Host "The example was already deleted."
				}
			}               
        }
    } 
}
catch {
        Write-Host 'Setup error.'
        throw  
}

$Global:VerbosePreference = $storePreference
}