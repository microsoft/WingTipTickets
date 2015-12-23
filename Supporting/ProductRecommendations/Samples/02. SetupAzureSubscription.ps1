# Check to see that there are no Azure subscriptions on the system
# Should come back empty or with your subscription
Get-AzureSubscription

# You can skip the rest of these steps if you see a subscription
# First, log into the Azure portal with your credentials
# The next command will launch the browser to retrieve your publishsettings file
# Save it in the C:\HOLs\Cortana Analytics directory/
Add-AzureAccount

# You might need to set the PowerShell Execution for running scripts. This is what you run if .ps1 files are not signed
Set-ExecutionPolicy Unrestricted -Force

# Remove subscription when done
Remove-AzureSubscription -SubscriptionName "Free Trial"