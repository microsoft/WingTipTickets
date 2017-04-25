<#
.Synopsis
	WingtipTickets (WTT) Demo Environment.
.DESCRIPTION
	This script is used to create a new WingtipTickets (WTT) Azure Service Bus Event Hub Service.
.EXAMPLE
	New-WTTAzureEventHub -wttEventHubName <eventhubname> -wttEventHubLocation <location for service bus>
#>

function New-WTTAzureEventHub
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
		$wttEventHubName,

		# DocumentDb Location
		[Parameter(Mandatory=$true, HelpMessage="Please specify the primary location for your WTT Environment ('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East')?")]
		[ValidateSet('West US 2', 'UK West', 'UK South', 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'Canada Central', 'Canada East', 'EastUS', 'WestUS', 'SouthCentralUS', 'NorthCentralUS', 'CentralUS', 'EastAsia', 'WestEurope', 'EastUS2', 'JapanEast', 'JapanWest', 'BrazilSouth', 'NorthEurope', 'SoutheastAsia', 'AustraliaEast', 'AustraliaSoutheast', 'CanadaCentral', 'CanadaEast', 'UKSouth', 'UKWest', 'WestUS2')]
		$wttEventHubLocation,

        [Parameter(Mandatory=$true)]
        [String]
        $wttServiceBusName,

        [String]
        $consumerGroupName = "asajob"
	)

    try{
        $eventHubConnectionString = ""
        WriteLabel("Checking for Service Bus Provider")
	    $provider =  (Get-AzureRmResourceProvider -ProviderNamespace Microsoft.ServiceBus).RegistrationState

	    if ($provider -ne "Registered")
	    {
		    WriteValue("Not Found")
		    WriteLabel("Registering Service Bus Provider")
		    $null = Register-AzureRmResourceProvider -ProviderNamespace Microsoft.ServiceBus
		    WriteValue("Successful")
	    }
	    else
	    {
		    WriteValue("Found")
	    }
    	WriteLabel("Checking for Event Hub Provider")
	    $provider =  (Get-AzureRmResourceProvider -ProviderNamespace Microsoft.EventHub).RegistrationState

	    if ($provider -ne "Registered")
	    {
		    WriteValue("Not Found")
		    WriteLabel("Registering Event Hub Provider")
		    $null = Register-AzureRmResourceProvider -ProviderNamespace Microsoft.EventHub
		    WriteValue("Successful")
	    }
	    else
	    {
		    WriteValue("Found")
	    }
        WriteLabel("Deploying Azure Event Hub")
        $params = @{namespaceName = "$wttServiceBusName";eventHubName = "$wttEventHubName"; consumerGroupName = "$consumerGroupName";location = "$wttEventHubLocation"; }
        $newEventHub = New-AzureRmResourceGroupDeployment -ResourceGroupName $azureResourceGroupName -TemplateFile .\Resources\EventHub\azuredeploy.json -TemplateParameterObject $params
        Start-Sleep -Seconds 20
        if($newEventHub)
        {
            $eventHubConnectionString = $newEventHub.Outputs.Values.value[0]
            return $eventHubConnectionString
            WriteValue("Successful")
        }
        else
        {
            WriteError("Failed")
        }
    }
    catch{
        WriteError("Deployment Failed")
		WriteError($Error)
    }   
}