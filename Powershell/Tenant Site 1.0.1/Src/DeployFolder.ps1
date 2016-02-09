<#
* Copyright (c) Microsoft Corporation. All rights reserved.
* Licensed under MIT License. See license file.
#>

param(
    [Parameter(Mandatory=$true)][string]$JsonFilesFolder,
    [Parameter(Mandatory=$false)][string]$SubscriptionName="Current",
    [Parameter(Mandatory=$false)][string]$ResourceGroupName="ADF",
    [Parameter(Mandatory=$true)][string]$DataFactoryName,
    [Parameter(Mandatory=$false)][string]$Location="WestUS",
    [Parameter(Mandatory=$false)][string]$StartTime,
    [Parameter(Mandatory=$false)][string]$EndTime
)

function Extract-Name {
	param(
	    [string]$FileContent,
	    [string]$Target
	)

	$index = $fileContent.ToLower().IndexOf($target.ToLower())
	$str = $fileContent.Substring($index, $target.Length)
    $str
} 

$setupDate = [DateTimeoffset]::Now
echo "Setup Logs" > adfdeploy-log.txt
echo $setupDate.ToString()  >> adfdeploy-log.txt
echo "-------------------------------------------------------" >> adfdeploy-log.txt


$oldErrors = $Error.Count

[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")
$ser = New-Object System.Web.Script.Serialization.JavaScriptSerializer -ErrorAction Stop

<#if($SubscriptionName.CompareTo("Current"))
{
    Select-AzureSubscription $SubscriptionName -ErrorAction Stop
} else {
    Get-AzureSubscription -Current
}#>

# Get the Azure Data Factory
#$df = Get-AzureDataFactory -ResourceGroupName $ResourceGroupName -Name $DataFactoryName
$df =  Get-AzureRmDataFactory -ResourceGroupName $ResourceGroupName -Name $DataFactoryName
$df 

$JsonFilesFolder = ".\temp\json"

#Write-Host "Reading files from $JsonFilesFolder..." -ForegroundColor Green

$files = Get-ChildItem "$JsonFilesFolder\Linked\*" -Include *.json -Recurse -ErrorAction Stop

if($files.Count -eq 0)
{
    Throw "No files are found in the location specified. Please double-check the folder."
}

#Write-Host "Creating Data Factory (update if exists)..."  -ForegroundColor Green
#New-AzureDataFactory -ResourceGroupName $ResourceGroupName -Name $DataFactoryName -Location $Location -Force -ErrorAction Stop

#Write-Host "Creating ADF LinkedServices..." -ForegroundColor Green
$files2 = @()

foreach($file in $files)
{
    $file.FullName
    $json = Get-Content $file.FullName -Raw -ErrorAction Stop
    $obj = ""
    $obj = $ser.DeserializeObject($json.ToLower()) 

    if(-not $obj)
    {
            Throw "Json file not valid, please double check using a validator on file: $file"
    }

    <#
    if(-not $obj.properties.Keys.Contains('Type'.ToLower()))
    {
        continue;
    }

    if($obj.properties.Keys.Contains('LinkedServiceName'.ToLower()))
    {#>
        #$files2 += $file
        #continue;
    #}
    #-ErrorAction Stop
    #New-AzureDataFactoryLinkedService -DataFactory $df -File $file.FullName  -Force 2>&1 3>&1 4>&1 1>>adfdeploy-log.txt
    New-AzureRmDataFactoryLinkedService -DataFactory $df -File $file.FullName  -Force 2>&1 3>&1 4>&1 1>>adfdeploy-log.txt
    
    Start-Sleep -Seconds 60
}

<#foreach($file in $files2)
{
    $json = Get-Content $file.FullName -Raw
    $obj = $ser.DeserializeObject($json.ToLower())
    #-ErrorAction Stop
    New-AzureDataFactoryLinkedService -DataFactory $df -File $file.FullName -Force 2>&1 3>&1 4>&1 1>>adfdeploy-log.txt
}
#>
#Write-Host "Creating ADF DataSets..."  -ForegroundColor Green
$files = Get-ChildItem "$JsonFilesFolder\DataSets\*" -Include *.json -Recurse -ErrorAction Stop

if($files.Count -eq 0)
{
    Throw "No files are found in the location specified. Please double-check the folder."
}

#Write-Host "Creating Data Factory (update if exists)..."  -ForegroundColor Green
#New-AzureDataFactory -ResourceGroupName $ResourceGroupName -Name $DataFactoryName -Location $Location -Force -ErrorAction Stop

#Write-Host "Creating ADF LinkedServices..." -ForegroundColor Green
$files2 = @()
foreach($file in $files)
{
    $json = Get-Content $file.FullName -Raw
    $obj = $ser.DeserializeObject($json.ToLower())

    <#if(-not $obj.properties.Keys.Contains('Location'.ToLower()) -or $obj.properties.Keys.Contains('Type'.ToLower()))
    {
        continue;
    }
    #>
    #-ErrorAction Stop
     #New-AzureDataFactoryDataset -DataFactory $df -File $file.FullName  -Force 2>&1 3>&1 4>&1 1>>adfdeploy-log.txt
     New-AzureRmDataFactoryDataset -DataFactory $df -File $file.FullName  -Force 2>&1 3>&1 4>&1 1>>adfdeploy-log.txt

     Start-Sleep -Seconds 60
}

#Write-Host "Creating ADF Pipelines..."  -ForegroundColor Green
$files = Get-ChildItem "$JsonFilesFolder\Pipelines\*" -Include *.json -Recurse -ErrorAction Stop

if($files.Count -eq 0)
{
    Throw "No files are found in the location specified. Please double-check the folder."
}

#Write-Host "Creating Data Factory (update if exists)..."  -ForegroundColor Green
#New-AzureDataFactory -ResourceGroupName $ResourceGroupName -Name $DataFactoryName -Location $Location -Force -ErrorAction Stop

#Write-Host "Creating ADF LinkedServices..." -ForegroundColor Green
$files2 = @()
foreach($file in $files)
{
    $json = Get-Content $file.FullName -Raw
    $obj = $ser.DeserializeObject($json.ToLower())

    <#if(-not $obj.properties.Keys.Contains('Activities'.ToLower()))
    {
        continue;
    }
    #>
    #New-AzureDataFactoryPipeline -DataFactory $df -File $file.FullName -Force 2>&1 3>&1 4>&1 1>>adfdeploy-log.txt
    New-AzureRmDataFactoryPipeline -DataFactory $df -File $file.FullName -Force 2>&1 3>&1 4>&1 1>>adfdeploy-log.txt

    if($StartTime -and $EndTime)
    {
        $name = Extract-Name -FileContent $json -Target $obj.name
        Write-Host "Setting Pipeline Active Period from [$StartTime] to [$EndTime]..."  -ForegroundColor Green
        #Set-AzureDataFactoryPipelineActivePeriod -DataFactory $df -Name $name -StartDateTime $StartTime -EndDateTime $EndTime -Force 
        Set-AzureRmDataFactoryPipelineActivePeriod -DataFactory $df -Name $name -StartDateTime $StartTime -EndDateTime $EndTime -Force 
    }
    Start-Sleep -Seconds 60
}

#Write-Verbose "Note: You are currently in the AzureResourceManager Azure Mode." 
#Write-Verbose "If you need to use other Azure Services (e.g. storage, HDInsight), you will need to Switch-AzureMode AzureServiceManagement."

Write-Host "---------------------------------"   
Write-Host "Use Case: $ResourceGroupName  "  
$numErrors =  $Error.Count - $oldErrors
if ( $numErrors -gt 0 )
{
  Write-Host "Deployment failed. ($numErrors errors occured during deployment) "
  Write-Host "Refer to adfdeploy-log.txt to investigate the errors"
}
else {
  Write-Host "Successfully deployed." 
}
Write-Host "---------------------------------"   