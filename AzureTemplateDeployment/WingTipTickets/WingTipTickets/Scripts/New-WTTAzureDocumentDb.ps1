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
		[Parameter(Mandatory=$true, HelpMessage="Please specify the primary location for your WTT Environment ('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East')?")]
		[ValidateSet('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East', 'EastUS', 'WestUS', 'SouthCentralUS', 'NorthCentralUS', 'CentralUS', 'EastAsia', 'WestEurope', 'EastUS2', 'JapanEast', 'JapanWest', 'BrazilSouth', 'NorthEurope', 'SoutheastAsia', 'AustraliaEast', 'AustraliaSoutheast', 'CanadaCentral', 'CanadaEast', 'UKSouth', 'UKWest', 'WestUS2')]
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
        Write-Host("Creating DocumentDB")
        if($docDBDeployed -eq "Succeeded")
        {
            Write-Host("Successful")
        }
        Else
        {
            Write-Host("Failed")
        }
        $documentDBPrimaryKey = (Invoke-AzureRmResourceAction -ResourceGroupName $azureResourceGroupName -ResourceName $wttDocumentDbName -ResourceType Microsoft.DocumentDb/databaseAccounts -Action listkeys -Force).primarymasterkey
       
        #Create DocDB Database
        $iotArray = @("iotdata","iotrawdata")
        foreach($item in $iotArray)
        {

            # Check if DocDB Database exists
            Write-Host("Checking if DocDB Database $item exists")
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
            $newIOTDatabase = "https://$wttDocumentDbName.documents.azure.com:443/dbs"
            $getIOTDatabaseExist = Invoke-RestMethod -Uri $newIOTDatabase -Method Get -Headers $header -ContentType "application/json"

            if($getIOTDatabaseExist.databases.id -like $item)
            {
                Write-Host("Exists, Deleting")
                $method = "Delete"
                $resourceId = "dbs/$item"
                $resourceType = "dbs"
                $date = (Get-Date).ToUniversalTime()
                $xDate = $date.ToString('r',[System.Globalization.CultureInfo]::InvariantCulture)
                $masterKey = $documentDBPrimaryKey
                $docDBToken = createAuthToken $method $resourceId $resourceType $xDate $masterKey      
                $header = @{"Authorization" = "$docDBToken";`
                        "x-ms-date" = "$xDate";`
                        "x-ms-version" = "2015-08-06"
                        }
                $deleteIOTDatabase = "https://$wttDocumentDbName.documents.azure.com:443/dbs/$item"
                $deleteDocDB = Invoke-RestMethod -Uri $deleteIOTDatabase -Method Delete -Headers $header -ContentType "application/json"
            }
            else
            {
                Write-Host("Doesn't exist")
            }
            
            Write-Host("Creating DocDB Database $item")
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
                    Write-Host "Successful"
                }
            }
            
            Write-Host("Creating DocDB Database Collection $item")
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
                                ""indexingMode"": ""consistent"",
                                    ""automatic"": true,
                                    ""includedPaths"": [
                                        {
                                            ""path"": ""/*"",
                                            ""indexes"": [
                                                {
                                                    ""kind"": ""Range"",
                                                    ""dataType"": ""Number"",
                                                    ""precision"": -1
                                                },
                                                {
                                                    ""kind"": ""Range"",
                                                    ""dataType"": ""String"",
                                                    ""precision"": -1
                                                },
                                                {
                                                    ""kind"": ""Spatial"",
                                                    ""dataType"": ""Point""
                                                }
                                            ]
                                        }
                                    ],
                        ""excludedPaths"": []
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
                Write-Host("Successful")
            }
        }
	}
	Catch
	{
		Write-Host("Failed")
		Write-Host($Error)
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