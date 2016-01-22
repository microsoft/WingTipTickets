param(
$csv
)
Import-Csv $csv | ForEach-Object `
{

    Select-AzureRmSubscription -subscriptionID $_.SubscriptionID

    $server = $_.Username+'primary'
    $database = Get-AzureRmSqlDatabase -resourcegroup $_.UserName -servername $server -databasename Customer1


    $rep = $database | Get-AzureRmSqlDatabaseReplicationLink -PartnerResourceGroupName $_.UserName

    #Remove Customer1 database if it is in a GeoReplication link. Delete the database on the secondary server
    if ($rep.PartnerRole -ne $null)
    {
        $serverName = "$server.database.windows.net"
        $rep | Remove-AzureRmSqlDatabaseSecondary 
        $command = "ALTER DATABASE Customer1 MODIFY ( SERVICE_OBJECTIVE = 'Basic' )"
        Invoke-Sqlcmd -Database Customer1 -ServerInstance $serverName -Username developer -Password P@ssword1 -OutputSqlErrors $True -Query $command
        Remove-AzureRmSqlDatabase -DatabaseName Customer1 -ServerName $rep.PartnerServerName -ResourceGroup $_.UserName -Force
    }

    #Set the database to Basic if it is not in a GeoRepliction link.
    if ($database.Edition -ne "Basic")
    {
        $serverName = "$server.database.windows.net"
        $command = "ALTER DATABASE Customer1 MODIFY ( SERVICE_OBJECTIVE = 'Basic' )"
        Invoke-Sqlcmd -Database Customer1 -ServerInstance $serverName -Username developer -Password P@ssword1 -OutputSqlErrors $True -Query $command
    }
}