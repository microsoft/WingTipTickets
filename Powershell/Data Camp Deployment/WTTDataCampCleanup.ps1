param(
$csv
)
Import-Csv $csv | ForEach-Object `
{
$global:VerbosePreference = "SilentlyContinue"
Select-AzureRMSubscription -SubscriptionId $_.SubscriptionID

Get-AzureRMVM | Stop-AzureRMVM -Force

Get-AzureRMResourcegroup | Remove-AzureRMResourceGroup -force

}
