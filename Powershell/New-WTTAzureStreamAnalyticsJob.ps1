function New-WTTAzureStreamAnalyticsJob
{
	[CmdletBinding()]
	Param
	(
		# Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureResourceGroupName,

		# DocumentDb Name
		[Parameter(Mandatory=$false)]
		$wttASAJob,

		# DocumentDb Location
		[Parameter(Mandatory=$false, HelpMessage="Please specify the datacenter location for your Azure DocumentDb Service ('Central US', 'West Europe', 'East US 2', 'North Europe', 'Japan East', 'West US', 'Southeast Asia', 'South Central US', 'East Asia', 'Japan West', 'North Central US', 'East US', 'Brazil South')?")]
		[ValidateSet('Central US', 'West Europe', 'East US 2', 'North Europe', 'Japan East', 'West US', 'Southeast Asia', 'South Central US', 'East Asia', 'Japan West', 'North Central US', 'East US', 'Brazil South')]
		$wttASALocation,

        [Parameter(Mandatory=$true)]
        [String]
        $wttServiceBusName,

        # Event Hub Name
		[Parameter(Mandatory=$false)]
		$wttEventHubName,
        
        # DocumentDb Name
		[Parameter(Mandatory=$false)]
        $azureDocumentDbName
	)

    try{

    $wttASAJobName = $wttASAJob
    if($wttASAJobName.Length -gt 24) { $wttASAJobName = $wttASAJobName.Remove(23) }

    $inputEventHubName = 
    $currentNamespace = Get-AzureSBNamespace -Name $wttServiceBusName
    $namespaceManager = [Microsoft.ServiceBus.NamespaceManager]::CreateFromConnectionString($CurrentNamespace.ConnectionString)
    $serviceBusAuth = (Get-AzureSBAuthorizationRule -Namespace $wttServiceBusName).ConnectionString.Split(';')
    $sharedaccesspolicykey = $serviceBusAuth[2].Substring(16)
    $sharedaccesspolicyname = $serviceBusAuth[1].Substring(20)
    $documentDBID = $azureDocumentDbName
    $documentDBAccountKey = (Invoke-AzureRmResourceAction -ResourceGroupName $azureResourceGroupName -ResourceName $azureDocumentDbName -ResourceType Microsoft.DocumentDb/databaseAccounts -Action listkeys -Force).primarymasterkey
    $asaJobFile = @{}
    $asaJobFile.Add($wttEventHubName)
    $asaJobFile.Add($wttServiceBusName)
    $asaJobFile.Add($sharedaccesspolicykey)
    $asaJobFile.Add($sharedaccesspolicyname)
    $asaJobFile.Add($azureDocumentDbName)
    $asaJobFile.Add($documentDBID)
    $asaJobFile.Add($documentDBAccountKey)

        #Check registration status of Azure Stream Analytics
        Do
        {
            $status = Get-AzureRmResourceProvider -ProviderNamespace Microsoft.StreamAnalytics
            if ($status.RegistrationState -ne "Registered")
            {
                $null = Register-AzureRmResourceProvider -ProviderNamespace Microsoft.StreamAnalytics
            }
        }until($status.RegistrationState -eq "Registered")


    New-AzureRmStreamAnalyticsJob -ResourceGroupName $azureResourceGroupName -Name $wttASAJob
    }
    catch
    {
        WriteValue("Failed")
		WriteError($Error)
    }

function Update-ASAJSONFile( $file ){
	Write-Host  -foreground green (Get-Date)   "Updating [$file]"

	(Get-Content $file ) | Foreach-Object {
		$_  -replace '<inputEventHubName>', $global:dict["<inputEventHubName>"] `
            -replace '<outputEventHubName>', $global:dict["<outputEventHubName>"] `
 		    -replace '<servicebusnamespace>', $global:dict["<servicebusnamespace>"] `
 		    -replace '<sharedaccesspolicykey>', $global:dict["<sharedaccesspolicykey>"] `
 		    -replace '<sharedaccesspolicyname>', $global:dict["<sharedaccesspolicyname>"] `
			-replace '<sqlserver>', $global:dict["<azuredbname>"] `
			-replace '<dbname>', $global:dict["<dbname>"] `
 		    -replace '<userid>', $global:dict["<userid>"] `
 		    -replace '<password>', $global:dict["<password>"] `
		
	} | Set-Content  $file

}
function SetGlobalParams {
    #this function must be called after ValidateParams
    


    $global:defaultResourceName = $output 
	$global:inputEventHubName = $output+'input'
    $global:outputEventHubName = $output+'output'
	$global:ServiceBusNamespace = $output
    
    $global:configPath = ($PSScriptRoot+'\temp\setup\' + $global:useCaseName + '.txt')

    $global:dict = @{}    



}
function SetMappingDictionary {
    #map the global vars to the dictionary  used for string substitution

    $global:dict.Add('<azuredbname>',$global:sqlserverName)
    $global:dict.Add('<userid>', $global:sqlServerLogin)
    $global:dict.Add('<password>', $global:sqlServerPassword)
    $global:dict.Add('<dbname>',$global:sqlDBName)
	$global:dict.Add('<usecase>',$global:useCaseName)
	$global:dict.Add('<inputEventHubName>',$global:inputEventHubName)
    $global:dict.Add('<outputEventHubName>',$global:outputEventHubName)
	$global:dict.Add('<servicebusnamespace>',$global:ServiceBusNamespace)
	$global:dict.Add('<sharedaccesspolicyname>',$global:sharedaccesskeyname)
	$global:dict.Add('<sharedaccesspolicykey>',$global:sharedaccesskey)


}
function CreateASAJob{
    Write-Host "Preparing ASA job config file......" -NoNewline
	copy -Path "src\\$global:useCaseName\\ASAJob\\ASAJob.json" -Destination temp\json\asa\ -Force
    $files = Get-ChildItem "temp\json\asa\*" -Include ASAJob.json -Recurse -ErrorAction Stop
	
    foreach($file in $files){
        Update-ASAJSONFile  $file.FullName      
    }
	Write-Host 'Prepared.'
	
	Write-Host "Creating the ASA Job......" -NoNewline
	try{
        Switch-AzureMode AzureResourceManager
        $ASAJob = New-AzureStreamAnalyticsJob -File "temp\json\asa\ASAjob.json" -Name $global:defaultResourceName -ResourceGroupName $global:resourceGroupName -ErrorAction Stop
	    if ($ASAJob.JobName -eq $global:defaultResourceName){
            Write-Host 'Created.'
	    }
    }
    catch{
        Write-Host 'Error.'
        throw
    }
}
}