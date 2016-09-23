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
		[Parameter(Mandatory=$false, HelpMessage="Please specify the datacenter location for your Azure Event Hub Service ('Central US', 'East US', 'East US 2', 'West US 2', 'West US', 'North Central US', 'South Central US', 'West Central US', 'East Asia', 'Southeast Asia', 'Brazil South', 'Japan East', 'Japan West', 'North Europe', 'West Europe', 'Canada Central', 'Canada East')?")]
		[ValidateSet('Central US', 'East US', 'East US 2', 'West US 2', 'West US', 'North Central US', 'South Central US', 'West Central US', 'East Asia', 'Southeast Asia', 'Brazil South', 'Japan East', 'Japan West', 'North Europe', 'West Europe', 'Canada Central', 'Canada East')]
		$wttEventHubLocation,

        [Parameter(Mandatory=$true)]
        [String]
        $wttServiceBusName,

        [String]
        $consumerGroupName = "asajob"
	)

    WriteLabel("Creating Azure Service Bus")
    
    try{
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

        $params = @{namespaceName = "$wttServiceBusName";eventHubName = "$wttEventHubName"; consumerGroupName = "$consumerGroupName";location = "$wttEventHubLocation"; }
        $newEventHub = New-AzureRmResourceGroupDeployment -ResourceGroupName $azureResourceGroupName -TemplateFile .\Resources\EventHub\azuredeploy.json -TemplateParameterObject $params
        if($newEventHub)
        {
            $eventHubConnectionString = $newEventHub.Outputs.Values.value[0]
            WriteValue("Successful")
            return $eventHubConnectionString
        }        
    }
    catch{
        WriteValue("Failed")
		WriteError($Error)
    }   
}
