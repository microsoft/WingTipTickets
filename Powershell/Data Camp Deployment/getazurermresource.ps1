$date = get-date -f yyyy-MM-dd
Import-Csv "C:\WTTDailyReport\azuresubs.csv" | foreach ($_.subscriptionID) `
{
 Select-AzureRmSubscription -SubscriptionId $_.subscriptionID

$ResourceGroup = Get-AzureRmResourceGroup
If ($ResourceGroup -ne $null)
{
    Get-AzureRmResource -ExpandProperties | select Name, ResourceType, Sku | Export-Csv ("C:\WTTDailyReport\$_.SubscriptionID_($date).csv")

}

}