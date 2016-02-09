param(
$csv
)
Import-Csv $csv | ForEach-Object `
{

Select-AzureSubscription -SubscriptionId $_.SubscriptionID

 $sourceStorageAccount = "wttdatacampvhd"
 $sourceStorageContainer = "wttdatacampnew"
 $sourceKey = "lOxj+6l0uXnS2dQ2ySKIpKKg+49aG80q1UUORbjDQRxpANN1zJ5Gt0Ovt9hbjyH42Y2+WqJb1+4hiqNu1UTscQ=="

 $sourceContext = New-AzureStorageContext -StorageAccountName $sourceStorageAccount -StorageAccountKey $sourceKey

$StorageAccountName = $_.UserName+'vhd'
$Location = 'Central US'
$ContainerName = "demovhd"
New-AzureStorageAccount –StorageAccountName $StorageAccountName -Location $Location
Set-AzureSubscription -CurrentStorageAccountName $StorageAccountName -SubscriptionID $_.SubscriptionID
New-AzureStorageContainer -Name $ContainerName -Permission Off
$destkey = (Get-AzureStorageKey -StorageAccountName $StorageAccountName).primary
$dest = [string]'https://'+$StorageAccountName+'.blob.core.windows.net/'+$ContainerName
$blob = "WTTBASE12172015.vhd"
$vhd = $dest+'/WTTBASE12172015.vhd' 
Start-Sleep -Seconds 30

$destContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $destkey

$blobcopy = Start-AzureStorageBlobCopy -DestContainer $ContainerName -DestContext $destContext -SrcBlob $blob -Context $sourceContext -SrcContainer $sourceStorageContainer
$blobcopy | Get-AzureStorageBlobCopyState -WaitForComplete


$rgName = $_.UserName+'vm'
$nicname = $_.Username+'vnic'
$subnet1Name = "subnet1"
$vnetName = $_.Username+'vnet'
$vnetAddressPrefix = "10.0.0.0/16"
$vnetSubnetAddressPrefix = "10.0.0.0/24"

## Compute
$vmName = $_.UserName
$vmSize = "Standard_D2"
$osDiskName = "WTTBASE12172015"

New-AzureResourceGroup -Name $rgName -Location $location

$pip = New-AzureRmPublicIpAddress -Name $nicname -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic
$subnetconfig = New-AzureRmVirtualNetworkSubnetConfig -Name $subnet1Name -AddressPrefix $vnetSubnetAddressPrefix
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix $vnetAddressPrefix -Subnet $subnetconfig
$nic = New-AzureRmNetworkInterface -Name $nicname -ResourceGroupName $rgName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id

## Setup local VM object

$vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

$vm | Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

$osDiskUri = $vhd
$vm | Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption attach -Windows

## Create the VM in Azure
New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm -DisableBginfoExtension -Verbose -Debug

#Add-AzureDisk -Diskname "WTTBASE12172015" -MediaLocation $vhd -label "WTTBASE12172015" -OS "Windows"

#new-azureservice -servicename $_.UserName -Location 'Central us'
#start-sleep -s 30

#new-azurevmconfig -name $_.UserName -instancesize "Standard_D2" -diskname "WTTBASE12172015" | set-azuresubnet "Subnet-1" | new-azurevm -servicename $_.UserName -vnetname $_.VirtualNetwork
#get-azurevm -servicename $_.UserName -name $_.UserName | add-azureendpoint -name "RDP" -protocol "TCP" -publicport 56902 -localport 3389 | update-azurevm
}
