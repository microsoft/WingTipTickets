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
		[Parameter(Mandatory=$true, HelpMessage="Please specify the primary location for your WTT Environment ('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East')?")]
		[ValidateSet('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East', 'EastUS', 'WestUS', 'SouthCentralUS', 'NorthCentralUS', 'CentralUS', 'EastAsia', 'WestEurope', 'EastUS2', 'JapanEast', 'JapanWest', 'BrazilSouth', 'NorthEurope', 'SoutheastAsia', 'AustraliaEast', 'AustraliaSoutheast', 'CanadaCentral', 'CanadaEast', 'UKSouth', 'UKWest', 'WestUS2')]
		$wttASALocation,

        [Parameter(Mandatory=$true)]
        [String]
        $wttServiceBusName,

        # Event Hub Name
		[Parameter(Mandatory=$false)]
		$wttEventHubName,
        
        # DocumentDb Name
		[Parameter(Mandatory=$false)]
        $azureDocumentDbName,
        
        # Event Hub Connection String
		[Parameter(Mandatory=$false)]
        $eventHubConnectionString
	)

    try{
        $wttASAJobName = $wttASAJob
        if($wttASAJobName.Length -gt 24) { $wttASAJobName = $wttASAJobName.Remove(23) }

        $inputEventHubName = $wttEventHubName
        $servicebusnamespace = $wttServiceBusName
        $serviceBusAuth = $eventHubConnectionString.Split(';')
        $sharedaccesspolicykey = $serviceBusAuth[2].Substring(16)
        $sharedaccesspolicyname = $serviceBusAuth[1].Substring(20)
        $documentDBID = $azureDocumentDbName
        $documentDBAccountKey = (Invoke-AzureRmResourceAction -ResourceGroupName $azureResourceGroupName -ResourceName $azureDocumentDbName -ResourceType Microsoft.DocumentDb/databaseAccounts -Action listkeys -Force).primarymasterkey
        $documentDBDatabaseName = "iotdata"
        $collectionNamePattern = "iotdata"
        $consumerGroupName = "asajob"
        $asaJobFile = @{}
        $asaJobFile.Add('<wttASALocation>',$wttASALocation)
        $asaJobFile.Add('<inputEventHubName>',$inputEventHubName)
        $asaJobFile.Add('<servicebusnamespace>',$servicebusnamespace)
        $asaJobFile.Add('<sharedaccesspolicykey>',$sharedaccesspolicykey)
        $asaJobFile.Add('<sharedaccesspolicyname>',$sharedaccesspolicyname)
        $asaJobFile.Add('<azureDocumentDbName>',$azureDocumentDbName)
        $asaJobFile.Add('<documentDBID>',$documentDBID)
        $asaJobFile.Add('<documentDBAccountKey>',$documentDBAccountKey)
        $asaJobFile.Add('<documentDBDatabaseName>',$documentDBDatabaseName)
        $asaJobFile.Add('<collectionNamePattern>',$collectionNamePattern)
        $asaJobFile.Add('<consumerGroupName>',$consumerGroupName)

        #Check registration status of Azure Stream Analytics
        Do
        {
            $status = Get-AzureRmResourceProvider -ProviderNamespace Microsoft.StreamAnalytics
            if ($status.RegistrationState -ne "Registered")
            {
                $null = Register-AzureRmResourceProvider -ProviderNamespace Microsoft.StreamAnalytics
            }
        }until($status.RegistrationState -eq "Registered")
        
        $newASADirectory = New-Item -ItemType Directory -Name ASA -Path .\Temp\Json -Force
        $copyASAJob = Copy-Item .\Resources\AzureStreamAnalytics\ASAJob.json -Destination .\temp\json\asa\ -Force
        $files = Get-ChildItem ".\temp\json\asa\*" -Include ASAJob.json -Recurse -ErrorAction Stop

        foreach($file in $files){
            Update-ASAJSONFile  $file.FullName      
        }
        WriteLabel("Creating ASA Job")
        $newASAJob = New-AzureRmStreamAnalyticsJob -ResourceGroupName $azureResourceGroupName -Name $wttASAJobName -File ".\temp\json\asa\ASAjob.json"
        if($newASAJob.JobName -eq $wttASAJobName)
        {
            WriteValue("Success")
        }
    }
    catch
    {
        WriteValue("Failed")
		WriteError($Error)
    }
}
function Update-ASAJSONFile( $file ){
	Write-Host  -foreground green (Get-Date)   "Updating [$file]"

	(Get-Content $file ) | Foreach-Object {
		$_  -replace '<wttASALocation>', $asaJobFile["<wttASALocation>"] `
            -replace '<inputEventHubName>', $asaJobFile["<inputEventHubName>"] `
 		    -replace '<servicebusnamespace>', $asaJobFile["<servicebusnamespace>"] `
 		    -replace '<sharedaccesspolicykey>', $asaJobFile["<sharedaccesspolicykey>"] `
 		    -replace '<sharedaccesspolicyname>', $asaJobFile["<sharedaccesspolicyname>"] `
			-replace '<documentDBID>', $asaJobFile["<documentDBID>"] `
			-replace '<documentDBAccountKey>', $asaJobFile["<documentDBAccountKey>"] `
 		    -replace '<documentDBDatabaseName>', $asaJobFile["<documentDBDatabaseName>"] `
 		    -replace '<collectionNamePattern>', $asaJobFile["<collectionNamePattern>"] `
            -replace '<consumerGroupName>',$asaJobFile["<consumerGroupName>"]`
	} | Set-Content  $file

}