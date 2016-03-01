Function Deploy-WTTEnvironment
{
    [CmdletBinding()]
	Param
	(
		# WTT Environment Application Name
		[Parameter(Mandatory=$false)]
		[String]
		$WTTEnvironmentApplicationName,

		# Primary Server Location
		[Parameter(Mandatory=$false, HelpMessage="Please specify the primary location for your WTT Environment ('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast')?")]
		[ValidateSet('East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast', 'EastUS', 'WestUS', 'SouthCentralUS', 'NorthCentralUS', 'CentralUS', 'EastAsia', 'WestEurope', 'EastUS2', 'JapanEast', 'JapanWest', 'BrazilSouth', 'NorthEurope', 'SoutheastAsia', 'AustraliaEast', 'AustraliaSoutheast')]
		[String]
		$WTTEnvironmentPrimaryServerLocation

	)

    Clear
	$Error.Clear()

	# Print Heading
	WriteLine("==============================================")
	WriteLine("Preparing to Deploy WingTipTickets to Azure   ")
	WriteLine("==============================================")
	LineBreak

    # Silence Verbose Output
	WriteLabel("Silencing Verbose Output")
    $global:VerbosePreference = "SilentlyContinue"
	WriteValue("Done")

	# Unblock Script Files
	WriteLabel("Unblocking Scripts")
	Get-ChildItem -Path $localPath -Filter *.ps1 | Unblock-File
	WriteValue("Done")

	# Load Script Files
	WriteLabel("Loading Scripts")
	Get-ChildItem -Path $localPath -Filter *.ps1 | ForEach { . $_.FullName }
	WriteValue("Done")

    #set up parameters to deploy ADF or DW
    $deployADF = ""
    $deployDW = ""

    # Select a subscription to use for deployment. Calls the initsubscription function at the end of this script.
    WriteLabel("Initializing Azure Subscription")
    LineBreak
    InitSubscription
    LineBreak
    
    WriteLabel("Checking for Azure PowerShell Version 1.0.1 or later") 
	#$installedAzurePowerShellVersion = CheckInstalledPowerShellVersion
	if((CheckInstalledPowerShellVersion) -gt -1)
	    {
		    WriteValue("Done")
	    }
	else
		{
            WriteValue("Failed")
			WriteError("Make sure that you are signed in and that PowerShell is not older than version 1.0.1.")
			WriteError("Please install from: http://azure.microsoft.com/en-us/downloads/, under Command-line tools, under Windows PowerShell, click Install")
			break
		}

    if (!$WTTEnvironmentApplicationName)
        {
            Write-Host "Please enter your unique WTT Environment Name:" -ForegroundColor Green
            $WTTEnvironmentApplicationName = Read-Host 
        }
        
        if (!$WTTEnvironmentPrimaryServerLocation)
        {
            $locationList = 'East US', 'West US', 'South Central US', 'North Central US', 'Central US', 'East Asia', 'West Europe', 'East US 2', 'Japan East', 'Japan West', 'Brazil South', 'North Europe', 'Southeast Asia', 'Australia East', 'Australia Southeast'
            Write-Host "Available Azure Data Center Locations" -ForegroundColor Green
            $locationList | Format-Table
            Write-Host "Please enter the primary location to deploy WTT Services:" -ForegroundColor Green
            $WTTEnvironmentPrimaryServerLocation = Read-Host

        }
        
    [int]$xMenuChoiceA = 0
    while ( $xMenuChoiceA -lt 1 -or $xMenuChoiceA -gt 4 ){
        Write-host "1. Base WingTip Tickets" -ForegroundColor Green
        Write-host "2. WingTip Tickets with Azure Data Factory" -ForegroundColor Green
        Write-host "3. WingTip Tickets with Azure Data Warehouse" -ForegroundColor Green
        Write-host "4. All of the WingTip Tickets Services" -ForegroundColor Green
    [Int]$xMenuChoiceA = read-host "Please enter an option 1 to 4..." }
        Switch( $xMenuChoiceA ){
            1{new-wttenvironment -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -WTTEnvironmentPrimaryServerLocation $WTTEnvironmentPrimaryServerLocation -deployADF 0 -deployDW 1}
            2{new-wttenvironment -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -WTTEnvironmentPrimaryServerLocation $WTTEnvironmentPrimaryServerLocation -deployADF 1 -deployDW 0}
            3{new-wttenvironment -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -WTTEnvironmentPrimaryServerLocation $WTTEnvironmentPrimaryServerLocation -deployADF 0 -deployDW 1}
            4{new-wttenvironment -WTTEnvironmentApplicationName $WTTEnvironmentApplicationName -WTTEnvironmentPrimaryServerLocation $WTTEnvironmentPrimaryServerLocation -deployADF 1 -deployDW 1}
        }
}

function InitSubscription()
{
    $global:subscriptionID = ""
    try
        {
            $account = (Get-AzureRmContext -ErrorAction SilentlyContinue).Account
	        WriteLabel("Azure Account")
            WriteLine("You are signed-in with $account")
	    }
    catch
        {
            $account  = Login-AzureRmAccount -WarningAction SilentlyContinue | out-null
        }
    if($global:subscriptionID -eq $null -or $global:subscriptionID -eq '')
        {
            $subList = Get-AzureRMSubscription

            if($subList.Length -lt 1)
                {
                    throw 'Your azure account does not have any subscriptions.  A subscription is required to run this tool'
                } 

            $subCount = 0
            foreach($sub in $subList)
                {
                    $subCount++
                    $sub | Add-Member -type NoteProperty -name RowNumber -value $subCount
                }

        LineBreak
        WriteValue("Your Azure Subscriptions: ")
        $subList | Format-Table RowNumber,SubscriptionId,SubscriptionName -AutoSize
        $rowNum = Read-Host 'Enter the row number (1 -'$subCount') of a subscription'

        while( ([int]$rowNum -lt 1) -or ([int]$rowNum -gt [int]$subCount))
            {
                WriteValue("Invalid subscription row number. Please enter a row number from the list above")
                $rowNum = Read-Host 'Enter subscription row number'                     
            }
        $global:subscriptionID = $subList[$rowNum-1].SubscriptionId;
        }
    #switch to appropriate subscription
    try
        {
            Select-AzureRMSubscription -SubscriptionId $global:subscriptionID
        } 
    catch 
        {
            throw 'Subscription ID provided is invalid: ' + $global:subscriptionID 
        }
}

function IIf($If, $Right, $Wrong) 
{
	If ($If) 
	{
		return $Right
	} 
	Else 
	{
		return $Wrong
	}
}

function LineBreak()
{
	Write-Host ""
}

function WriteLine($label)
{
	Write-Host $label
}

function WriteLabel($label)
{
	Write-Host $label": " -nonewline -foregroundcolor "yellow"
}

function WriteValue($value)
{
	Write-Host $value
}

function WriteError($error)
{
	Write-Host "Error:" $error -foregroundcolor "red"
}

function Lsh([UInt32] $n, [Byte] $bits) 
{
    $n * [Math]::Pow(2, $bits)
}

# Returns a version number "a.b.c.d" as a two-element numeric
# array. The first array element is the most significant 32 bits,
# and the second element is the least significant 32 bits.
function GetVersionStringAsArray([String] $version) 
{
    $parts = $version.Split(".")
    if ($parts.Count -lt 3) 
    {
        for ($n = $parts.Count; $n -lt 3; $n++) 
        {
            $parts += "0"
        }
    }
    [UInt32] ((Lsh $parts[0] 16))
    [UInt32] ((Lsh $parts[1] 16))
    [UInt32] ((Lsh $parts[2] 16))
}

# Compares two version numbers "a.b.c.d". If $version1 < $version2,
# returns -1. If $version1 = $version2, returns 0. If
# $version1 > $version2, returns 1.
function CheckInstalledPowerShellVersion
{
    #$context = (Get-AzureRmContext).Subscription.SubscriptionId
    #$null = Set-AzureRmContext -SubscriptionId $context
    #$installedVersion = ((Get-Module AzureRM.profile).Version -replace '\s','')
    $installedVersion = Get-Module AzureRM.profile
    $installedVersionVersion = $installedVersion.Version
    $installedVersionVersion = $installedVersionVersion -replace '\s',''
    $minimumRequiredVersion = '1.0.1'
    $ver1 = GetVersionStringAsArray $installedVersionVersion
    $ver2 = GetVersionStringAsArray $minimumRequiredVersion
    if ($ver1[0] -lt $ver2[0]) 
    {
        $out = -1
    }
    elseif ($ver1[0] -eq $ver2[0]) 
    {
        if ($ver1[1] -lt $ver2[1]) 
        {
            $out = -1
        }
        elseif ($ver1[1] -ge $ver2[1]) 
        {
            $out = 1
        }
    } 
    elseif ($ver1[2] -gt $ver2[2])
    {
        $out = 1
    }    
    else 
    {
        $out = 1
    }
    return $out
    $installedAzurePowerShellVersion = $out

}