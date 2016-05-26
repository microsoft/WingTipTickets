<#
* Copyright (c) Microsoft Corporation. All rights reserved.
* Licensed under MIT License. See license file.
#>

param(
    [Parameter(Mandatory=$true)][string]$JsonFilesFolder,
    [Parameter(Mandatory=$false)][string]$SubscriptionName="Current",
    [Parameter(Mandatory=$false)][string]$ResourceGroupName,
    [Parameter(Mandatory=$true)][string]$DataFactoryName,
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

# Get the Azure Data Factory
$df =  Get-AzureRmDataFactory -ResourceGroupName $ResourceGroupName -Name $DataFactoryName
$df 

$JsonFilesFolder = ".\temp\json"

WriteLabel("Reading files from $JsonFilesFolder...")

$files = Get-ChildItem "$JsonFilesFolder\Linked\*" -Include *.json -Recurse -ErrorAction Stop

if($files.Count -eq 0)
{
    Throw "No files are found in the location specified. Please double-check the folder."
}
WriteValue("Successful")

WriteLabel("Creating ADF LinkedServices...")
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

    New-AzureRmDataFactoryLinkedService -DataFactory $df -File $file.FullName  -Force 2>&1 3>&1 4>&1 1>>adfdeploy-log.txt
    
    Start-Sleep -Seconds 60
}
WriteValue("Successful")

$files = Get-ChildItem "$JsonFilesFolder\DataSets\*" -Include *.json -Recurse -ErrorAction Stop

if($files.Count -eq 0)
{
    Throw "No files are found in the location specified. Please double-check the folder."
}

WriteLabel("Creating ADF Data Set...")
$files2 = @()
foreach($file in $files)
{
    $json = Get-Content $file.FullName -Raw
    $obj = $ser.DeserializeObject($json.ToLower())

     New-AzureRmDataFactoryDataset -DataFactory $df -File $file.FullName  -Force 2>&1 3>&1 4>&1 1>>adfdeploy-log.txt

     Start-Sleep -Seconds 60
}
WriteValue("Successful")

$files = Get-ChildItem "$JsonFilesFolder\Pipelines\*" -Include *.json -Recurse -ErrorAction Stop

if($files.Count -eq 0)
{
    Throw "No files are found in the location specified. Please double-check the folder."
}

WriteLabel("Creating ADF Pipelines...")
$files2 = @()
foreach($file in $files)
{
    $json = Get-Content $file.FullName -Raw
    $obj = $ser.DeserializeObject($json.ToLower())

    New-AzureRmDataFactoryPipeline -DataFactory $df -File $file.FullName -Force 2>&1 3>&1 4>&1 1>>adfdeploy-log.txt

    if($StartTime -and $EndTime)
    {
        $name = Extract-Name -FileContent $json -Target $obj.name
        Set-AzureRmDataFactoryPipelineActivePeriod -DataFactory $df -Name $name -StartDateTime $StartTime -EndDateTime $EndTime -Force 
    }
    Start-Sleep -Seconds 60
}
WriteValue("Successful")

LineBreak
WriteLabel("ADF $ResourceGroupName Deployment")
$numErrors =  $Error.Count - $oldErrors
if ( $numErrors -gt 0 )
{
  WriteError("Deployment failed. ($numErrors errors occured during deployment) ")
  WriteError("Refer to adfdeploy-log.txt to investigate the errors")
}
else {
  WriteValue("Successful")
}
LineBreak