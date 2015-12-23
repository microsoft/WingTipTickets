function Get-WindowsAzurePowerShellVersion
{
[CmdletBinding()]
Param ()
 
## - Section to query local system for Windows Azure PowerShell version already installed:
Write-Host "`r`nMicrosoft Azure PowerShell Installed version: " -ForegroundColor 'Yellow';
(Get-Module -ListAvailable | Where-Object{ $_.Name -eq 'AzureResourceManager' }) `
| Select Version, Name, Author | Format-List;
 
## - Section to query web Platform installer for the latest available Windows Azure PowerShell version:
Write-Host "Windows Azure PowerShell available download version: " -ForegroundColor 'Green';
[reflection.assembly]::LoadWithPartialName("Microsoft.Web.PlatformInstaller") | Out-Null;
$ProductManager = New-Object Microsoft.Web.PlatformInstaller.ProductManager;
$ProductManager.Load(); $ProductManager.Products `
| Where-object{
($_.Title -match "Microsoft Azure PowerShell") `
-and ($_.Author -eq 'Microsoft Corporation')
} `
| Select-Object Version, Title, Published, Author | Format-List;
};
#start of main script
Get-WindowsAzurePowerShellVersion