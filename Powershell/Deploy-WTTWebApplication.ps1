function Deploy-WTTWebApplication
{

	[CmdletBinding()]
	Param
	(
		# WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$WTTEnvironmentApplicationName,

		# Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$ResourceGroupName,

		# WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$Websitename,

		# Path to Azure Web Site WebDeploy Package
		[Parameter(Mandatory = $false)] 
		[String]$AzureWebSiteWebDeployPackagePath,


		# Path to Azure Web Site WebDeploy Package
		[Parameter(Mandatory = $false)] 
		[String]$AzureWebSiteWebDeployPackageName
		
	)
	Try
	{
		$containerName = "deployment-files"
        
        $storageAccountKey = (Get-AzureRmStorageAccountKey -StorageAccountName $resourceGroupName -ResourceGroupName $resourceGroupName).Key1

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
		Set-AzureStorageBlobContent -File $AzureWebSiteWebDeployPackagePath -Container $containerName -Context $context -Blob $AzureWebSiteWebDeployPackageName -Force
		WriteValue("Successful")

		# Build Paths
		$templateFilePath = (Get-Item -Path ".\" -Verbose).FullName + "\Resources\DataFactory\Website\Deployment.json"
		$packageUri = "https://$ApplicationName.blob.core.windows.net/deployment-files/$AzureWebSiteWebDeployPackageName"
        
        WriteLabel("Deploying Web Application '$DatabaseName'")
        $webSiteExist = Get-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $Websitename
        if($webSiteExist -eq $true)
            {
		        # Deploy application
		        $null = New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $DatabaseName -Mode "Incremental" -TemplateFile $templateFilePath -siteName $Websitename -hostingPlanName $WebsiteHostingPlanName -siteLocation $Location -packageUri $packageUri
		        WriteValue("Successful")
            }
        else
            {
                WriteValue("Unsuccessful")
            }
	}
	Catch
	{
		WriteValue("Failed")
		throw $Error
	}
}