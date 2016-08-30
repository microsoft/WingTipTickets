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
		# DocumentDb Name
		[Parameter(Mandatory=$false)]
		$wttEventHubName,

		# DocumentDb Location
		[Parameter(Mandatory=$false, HelpMessage="Please specify the datacenter location for your Azure DocumentDb Service ('Central US', 'East US', 'East US 2', 'West US 2', 'West US', 'North Central US', 'South Central US', 'West Central US', 'East Asia', 'Southeast Asia', 'Brazil South', 'Japan East', 'Japan West', 'North Europe', 'West Europe', 'Canada Central', 'Canada East')?")]
		[ValidateSet('Central US', 'East US', 'East US 2', 'West US 2', 'West US', 'North Central US', 'South Central US', 'West Central US', 'East Asia', 'Southeast Asia', 'Brazil South', 'Japan East', 'Japan West', 'North Europe', 'West Europe', 'Canada Central', 'Canada East')]
		$wttEventHubLocation,

        [Parameter(Mandatory=$true)]
        [String]
        $wttServiceBusName,

        [String]
        $consumerGroupUserMetadata = $null, 
        
        [int]
        $partitionCount = "4",

        [int]
        $messageRetentionInDays = "7",

        [string]
        $userMetadata = $null,

        [String]
        $consumerGroupName = "asajob",

        [Bool]
        $createACSNamespace = $False,

        [string]
        $EventHubsKeyName = "iotdevice"
	)

    WriteLabel("Creating Azure Service Bus")
    
    try{
        $ehExist = $false
        Do{
            $eventHubExist = Get-AzureSBNamespace -Name $wttServiceBusName
            if($eventHubExist)
            {
                Remove-AzureSBNamespace -Name $wttServiceBusName
                WriteError("$wttServiceBusName exists. Deleting")
                $ehExist = $false
            }
            else
            {
                $null = New-AzureSBNamespace -Name $wttServiceBusName -NamespaceType Messaging -Location $wttEventHubLocation -CreateACSNamespace $true -InformationAction SilentlyContinue
                WriteValue("Success")
                $ehExist = $true
            }
        }Until($ehExist -eq $true)
        
        $serviceBusDLL = Get-ChildItem -Recurse ".\Nuget\packages\*ServiceBus*" -Include *.dll
        add-type -path $serviceBusDLL

        WriteLabel("Get Azure Service Bus Name")
        $currentNameSpace = Get-AzureSBNamespace -Name $wttServiceBusName
        If ($currentNameSpace)
        {
            WriteValue("Success")
        }
        Else
        {
            WriteError("Cannot find Azure Service Bus")
        }
        
        WriteLabel("Get Azure Service Bus Connection String")
        $namespaceManager = [Microsoft.ServiceBus.NamespaceManager]::CreateFromConnectionString($CurrentNamespace.ConnectionString)
        If($namespaceManager)
        {
            WriteValue("Success")
        }
        Else
        {
            WriteError("Cannot find Azure Service Bus")
        }

        WriteLabel("Creating Event Hub")
        $eventHubDescription = New-Object -TypeName Microsoft.ServiceBus.Messaging.EventHubDescription -ArgumentList $wttEventHubName
        $eventHubDescription.PartitionCount = $partitionCount
        $eventHubDescription.MessageRetentionInDays = $messageRetentionInDays
        $eventHubDescription.UserMetadata = $userMetadata
        $eventHubAccessRights = [Microsoft.ServiceBus.Messaging.AccessRights[]]([Microsoft.ServiceBus.Messaging.AccessRights]::Manage,[Microsoft.ServiceBus.Messaging.AccessRights]::Send,[Microsoft.ServiceBus.Messaging.AccessRights]::Listen)
        $eventHubsPassword = [Microsoft.ServiceBus.Messaging.SharedAccessAuthorizationRule]::GenerateRandomKey()
        $Rule = New-Object -TypeName Microsoft.ServiceBus.Messaging.SharedAccessAuthorizationRule -ArgumentList $EventHubsKeyName,$EventHubsPassword,$eventHubAccessRights
        $EventHubDescription.Authorization.Add($Rule)
        $null = $namespaceManager.CreateEventHub($eventHubDescription)
        Start-Sleep -s 10
        If($namespaceManager.EventHubExists($wttEventHubName))
        {
            WriteValue("Success")
        }
        Else
        {
            WriteError("Cannot find Event Hub")
        }

        WriteLabel("Creating Event Hub Consumer Group")
        $consumerGroupDescription = New-Object -TypeName Microsoft.ServiceBus.Messaging.ConsumerGroupDescription -ArgumentList $wttEventHubName, $consumerGroupName
        $consumerGroupDescription.UserMetadata = $consumerGroupUserMetadata
        $null = $NamespaceManager.CreateConsumerGroupIfNotExists($consumerGroupDescription)
        Start-Sleep -s 10
        If($namespaceManager.GetConsumerGroup($wttEventHubName,$consumerGroupName))
        {
            WriteValue("Success")
        }
        Else
        {
            WriteError("Cannot find Event Hub Consumer Group")
        }  

        WriteLabel("Retrieving Event Hub authorization information")
        $eventHubSASKeyName = ($NamespaceManager.GetEventHub($wttEventHubName)).authorization.KeyName
        $eventHubSASKey = ($NamespaceManager.GetEventHub($wttEventHubName)).authorization.primarykey
        if($eventHubSASKeyName -and $EventHubsKeyName)
        {
            WriteValue("Success")
            
        }
        Else
        {
            WriteError("Cannot find Event Hub authorization policy")
        } 
    }
    catch{
        WriteValue("Failed")
		WriteError($Error)
    }   
}