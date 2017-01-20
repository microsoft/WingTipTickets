function Deploy-WTTWebApplication
{
	[CmdletBinding()]
	Param
	(
		# Storage Account Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureStorageAccountName,

		# Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureResourceGroupName,

		# WTT Environment Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$Websitename,

		# Path to Azure Web Site WebDeploy Package
		[Parameter(Mandatory = $false)] 
		[String]$WebAppPackagePath,


		# Path to Azure Web Site WebDeploy Package
		[Parameter(Mandatory = $false)] 
		[String]$webAppPackageName
		
	)
	Try
	{
		$containerName = "deployment-files"

		$storageAccountKey = (Get-AzureRmStorageAccountKey -StorageAccountName $azureStorageAccountName -ResourceGroupName $azureResourceGroupName).Value[0]

		# Get the storage account context
		$context = New-AzureStorageContext –StorageAccountName $azureStorageAccountName -StorageAccountKey $storageAccountKey -ea silentlycontinue
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
		$null = Set-AzureStorageBlobContent -File "$WebAppPackagePath\$webAppPackageName" -Container $containerName -Context $context -Blob $webAppPackageName -Force
		WriteValue("Successful")

		# Build Paths
		$templateFilePath = (Get-Item -Path ".\" -Verbose).FullName + "\Resources\Website\Deployment.json"
		$packageUri = "https://$azureStorageAccountName.blob.core.windows.net/deployment-files/$webAppPackageName"

		WriteLabel("Deploying Web Application '$Websitename'")
		$webSiteExist = Get-AzureRmResource -ResourceName $Websitename -ResourceType Microsoft.Web/sites -ExpandProperties -ResourceGroupName $azureResourceGroupName
		if($webSiteExist -ne $null)
		{
            $siteExists = $false
            Do
            {
			    # Deploy application
			    $webDeployment = New-AzureRmResourceGroupDeployment -ResourceGroupName $azureResourceGroupName -Name $Websitename -TemplateFile $templateFilePath -siteName $Websitename -Mode Incremental -hostingPlanName $Websitename -packageUri $packageUri -sitelocation $webSiteExist.Location -sku $webSiteExist.Properties.sku
			    if($webDeployment.ProvisioningState -eq "Failed")
			    {
				    WriteValue("Unsuccessful, Retrying")
                    $siteExists = $false
    			}
			    Else
			    {
			        WriteValue("Successful")
                    $siteExists = $true
			    }
            }Until($siteExists = $true)
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