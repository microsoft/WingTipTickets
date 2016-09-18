<#
.Synopsis
	WingtipTickets (WTT) Demo Environment.
.DESCRIPTION
	This script is used to create a new WingtipTickets (WTT) Azure DocumentDb Service.
.EXAMPLE
	New-WTTAzureDocumentDb -WTTResourceGroupName <string> -WTTDocumentDbName <string> -WTTDocumentDbLocation <string>
#>

function New-WTTAzureDocumentDb
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
		$wttDocumentDbName,

		# DocumentDb Location
		[Parameter(Mandatory=$false, HelpMessage="Please specify the datacenter location for your Azure DocumentDb Service ('East Asia', 'Southeast Asia', 'East US', 'West US', 'North Europe', 'West Europe', 'Central US', 'South Central US', 'North Europe', 'West Europe', 'Japan East', 'Japan West', 'Australia East', 'Australia Southeast', 'Central India', 'South India', 'West India')?")]
		[ValidateSet('East Asia', 'Southeast Asia', 'East US', 'West US', 'North Europe', 'West Europe', 'Central US', 'South Central US', 'North Europe', 'West Europe', 'Japan East', 'Japan West', 'Australia East', 'Australia Southeast', 'Central India', 'South India', 'West India')]
		$wttDocumentDbLocation
	)

	try
	{
        #load System.Web Assembly
        $systemWebAssembly = [reflection.assembly]::loadwithpartialname("system.web")

		#Register DocumentDB provider service
		Do{
            $status = (Get-AzureRmResourceProvider -ProviderNamespace Microsoft.DocumentDb).RegistrationState
		    if ($status -ne "Registered")
		    {
			    Register-AzureRmResourceProvider -ProviderNamespace Microsoft.DocumentDb
		    }
        }until($status -eq "Registered")

		# Create DocumentDb Account
        New-AzureRmResource -resourceName $WTTDocumentDbName -Location $WTTDocumentDbLocation -ResourceGroupName $azureResourceGroupName -ResourceType "Microsoft.DocumentDb/databaseAccounts" -ApiVersion 2015-04-08 -PropertyObject @{"name" = $WTTDocumentDbName; "databaseAccountOfferType" = "Standard"} -force
		$docDBDeployed = (Get-AzureRmResource -ResourceName $WTTDocumentDbName -ResourceGroupName $azureResourceGroupName -ExpandProperties -ResourceType "Microsoft.DocumentDb/databaseAccounts").Properties.provisioningstate
        WriteLabel("Creating DocumentDB")
        if($docDBDeployed -eq "Succeeded")
        {
            WriteValue("Successful")
        }
        Else
        {
            WriteError("Failed")
        }
        $documentDBPrimaryKey = (Invoke-AzureRmResourceAction -ResourceGroupName $azureResourceGroupName -ResourceName $wttDocumentDbName -ResourceType Microsoft.DocumentDb/databaseAccounts -Action listkeys -Force).primarymasterkey
       
        #Create DocDB Database
        $iotArray = @("iotdata","iotrawdata")
        foreach($item in $iotArray)
        {
            WriteLabel("Creating DocDB Database $item")
            $method = "Post"
            $resourceId = ""
            $resourceType = "dbs"
            $date = (Get-Date).ToUniversalTime()
            $xDate = $date.ToString('r',[System.Globalization.CultureInfo]::InvariantCulture)
            $masterKey = $documentDBPrimaryKey
            $docDBToken = createAuthToken $method $resourceId $resourceType $xDate $masterKey
            $header = @{"Authorization" = "$docDBToken";`
                        "x-ms-date" = "$xDate";`
                        "x-ms-version" = "2015-08-06"
                        }
            $newIOTDatabase = "https://$wttDocumentDbName.documents.azure.com:443/dbs"
            $body = "{""id"": ""$item""}"
            $newIOTDatabasePost = Invoke-RestMethod -Uri $newIOTDatabase -Body $body -Method Post -Headers $header -ContentType "application/json"
        
            #Get DocDB Database
            $method = "Get"
            $resourceId = ""
            $resourceType = "dbs"
            $date = (Get-Date).ToUniversalTime()
            $xDate = $date.ToString('r',[System.Globalization.CultureInfo]::InvariantCulture)
            $masterKey = $documentDBPrimaryKey
            $docDBToken = createAuthToken $method $resourceId $resourceType $xDate $masterKey      
            $header = @{"Authorization" = "$docDBToken";`
                        "x-ms-date" = "$xDate";`
                        "x-ms-version" = "2015-08-06"
                        }
            $getIOTDatabase = Invoke-RestMethod -Uri $newIOTDatabase -Method Get -Headers $header -ContentType "application/json"
            $dbs = @($getIOTDatabase.Databases.id)
            foreach($db in $dbs)
            {
                if($db -like $item)
                {
                    WriteValue "Successful"
                }
            }
            
            WriteLabel("Creating DocDB Database Collection $item")
            #Create DocDB Database Collection       
            $method = "Post"
            $resourceId = "dbs/$item"
            $resourceType = "colls"
            $date = (Get-Date).ToUniversalTime()
            $xDate = $date.ToString('r',[System.Globalization.CultureInfo]::InvariantCulture)
            $masterKey = $documentDBPrimaryKey
            $docDBToken = createAuthToken $method $resourceId $resourceType $xDate $masterKey
            $header = @{"Authorization" = "$docDBToken";`
                        "x-ms-date" = "$xDate";`
                        "x-ms-version" = "2015-08-06";`
                        "x-ms-offer-throughput" = "400"
                        }
            $newIOTDatabaseCollection = "https://$wttDocumentDbName.documents.azure.com/dbs/$item/colls"
            $body = "{
                        ""id"": ""$item"",
                                ""indexingPolicy"": {
                                    ""automatic"": true,
                                    ""indexingMode"": ""Consistent"",
                                    ""includedPaths"": [
                                    {
                                        ""path"": ""/*"",
                                        ""indexes"": [
                                         {
                                            ""dataType"": ""String"",
                                            ""precision"": -1,
                                            ""kind"": ""Range""
                                         }
                                       ]
                                    }
                                  ]
                                }
                     }"
            $newIOTDatabaseCollectionPost = Invoke-RestMethod -Uri $newIOTDatabaseCollection -Method Post -Body $body -Headers $header -ContentType "application/json"
        
            #Get DocDB Database Collection
            $method = "Get"
            $resourceId = "dbs/$item"
            $resourceType = "colls"
            $date = (Get-Date).ToUniversalTime()
            $xDate = $date.ToString('r',[System.Globalization.CultureInfo]::InvariantCulture)
            $masterKey = $documentDBPrimaryKey
            $docDBToken = createAuthToken $method $resourceId $resourceType $xDate $masterKey
            $header = @{"Authorization" = "$docDBToken";`
                        "x-ms-date" = "$xDate";`
                        "x-ms-version" = "2015-08-06"
                        }
            $getIOTDatabaseCollectionURL = "https://$wttDocumentDbName.documents.azure.com/dbs/$item/colls"
            $getIOTDatabaseCollection = Invoke-RestMethod -Uri $getIOTDatabaseCollectionURL -Method Get -Headers $header
            if($getIOTDatabaseCollection.DocumentCollections.id -like $item)
            {
                WriteValue("Successful")
            }            
        }

	}
	Catch
	{
		WriteValue("Failed")
		WriteError($Error)
	}
}
function createAuthToken ($method, $resourceId, $resourceType, $xdate, $masterKey)
{
  $keyBytes = [System.Convert]::FromBase64String($masterKey)
  $sigCleartext = @($method.ToLower() + "`n" + $resourceType.ToLower() + "`n" + $resourceId + "`n" + $xdate.ToLowerInvariant() + "`n" + "" + "`n")
  $bytesSigClear =[Text.Encoding]::UTF8.GetBytes($sigCleartext)
  $hmacsha = new-object -TypeName System.Security.Cryptography.HMACSHA256 -ArgumentList (,$keyBytes) 
  $hash = $hmacsha.ComputeHash($bytesSigClear)  
  $signature = [System.Convert]::ToBase64String($hash)
  $key  = [System.Web.HttpUtility]::UrlEncode($('type=master&ver=1.0&sig=' + $signature))
  return $key
}