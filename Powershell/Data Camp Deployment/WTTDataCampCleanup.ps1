param(
$csv
)
Import-Csv $csv | ForEach-Object `
{
$global:VerbosePreference = "SilentlyContinue"
Select-AzureSubscription -SubscriptionId $_.SubscriptionID
Switch-AzureMode AzureServiceManagement
Get-AzureVM | Stop-AzureVM -Force
Remove-AzureTrafficManagerProfile -Name $_.UserName -Force

Switch-AzureMode AzureResourceManager
Get-AzureResourcegroup | Remove-AzureResourceGroup -force

}
