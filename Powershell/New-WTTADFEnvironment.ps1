<#
.Synopsis
	Azure DataFactory operations.
.DESCRIPTION
	This script is used to create an Azure Data Factory.
.EXAMPLE
	New-WTTADFEnvironment -ApplicationName <string> -ResourceGroupName <string> -Location <string> -WebsiteHostingPlanName <string> -DatabaseServerName <string> -DatabaseName <string> -DatabaseEdition <string> -DatabaseUserName <string> -DatabasePassword <string>
#>
function New-WTTADFEnvironment
{
	[CmdletBinding()]
	Param
	(
		# Application Name
		[Parameter(Mandatory=$true)]
		[String]
		$ApplicationName,

		# Resource Group Name
		[Parameter(Mandatory=$true)]
		[String]
		$azureResourceGroupName
	)

	Process
	{
		# Check if DataFactory exists
		LineBreak
		WriteLabel("Checking for DataFactory '$ApplicationName")
		$azureDataFactory = Find-AzureRmResource -ResourceType "Microsoft.DataFactory/dataFactories" -ResourceNameContains $ApplicationName -ResourceGroupNameContains $azureResourceGroupName

	    If($azureDataFactory -ne $null)
	    {
		    WriteValue("Found")
            RemoveDataFactory
	    }
        $azureDataFactory = Find-AzureRmResource -ResourceType "Microsoft.DataFactory/dataFactories" -ResourceNameContains $ApplicationName -ResourceGroupNameContains $azureResourceGroupName
	    if($azureDataFactory -eq $null)
	    {
		    WriteValue("Not Found")

		    try 
		    {
			    # Register DataFactory Provider
			    RegisterProvider		    
     		    # Create DataFactory
			    CreateDataFactory
		    }
		    Catch
		    {
			    WriteError($Error)
		    }
        }
	}
}

function RegisterProvider()
{
	WriteLabel("Checking for DataFactory Provider")
	$provider =  (Get-AzureRmResourceProvider -ProviderNamespace Microsoft.DataFactory).RegistrationState

	if ($provider -ne "Registered")
	{
		WriteValue("Not Found")
		WriteLabel("Registering DataFactory Provider")
		$null = Register-AzureRmResourceProvider -ProviderNamespace Microsoft.DataFactory
		WriteValue("Successful")
	}
	else
	{
		WriteValue("Found")
	}
}

function CreateDataFactory()
{
	Try
	{
        $adf = (Get-AzureRmResourceProvider -ProviderNamespace Microsoft.DataFactory).ResourceTypes
        $adfLocation = ($adf | Where-Object {$_.ResourceTypeName -eq "dataFactories"}).locations
		# Create DataFactory
		WriteLabel("Creating Data Factory '$ApplicationName'")
        foreach($location in $adfLocation)
        {
		    $dataFactory = New-AzureRMDataFactory -Name $ApplicationName -location $location -ResourceGroupName $azureResourceGroupName -Force -ErrorAction SilentlyContinue
            $adfExists = (Find-AzureRmResource -ResourceNameContains $ApplicationName -ResourceGroupNameContains $azureResourceGroupName -ResourceType Microsoft.DataFactory/dataFactories -ExpandProperties).Properties.provisioningstate
            $adfExistsNow = $false
            if($adfExists -eq "Succeeded")
            {          
                $adfExistsNow = $true
                WriteValue("Successful")
                return $dataFactory
            }
            else
            {
		        WriteValue("Failed")
            }
        }
	}
	Catch 
	{
		WriteValue("Failed")
		throw $Error
	}
}

function RemoveDataFactory()
{
    Try
    {
        WriteLabel("Checking data factory '$ApplicationName' status")
        $dataFactory = Get-AzureRmDataFactory -Name $ApplicationName -ResourceGroupName $azureResourceGroupName -ErrorAction SilentlyContinue
        if($dataFactory.ProvisioningState -eq "Succeeded")
        {
            WriteValue("Found")
            $azureDataFactoryRemove = Remove-AzureRmDataFactory -Name $ApplicationName -ResourceGroupName $azureResourceGroupName -Force -ErrorAction SilentlyContinue
        }
        else
        {
            WriteValue("Not Deployed")
        }
    }
    Catch
    {
        WriteValue("Failed")
		throw $Error
    }
}