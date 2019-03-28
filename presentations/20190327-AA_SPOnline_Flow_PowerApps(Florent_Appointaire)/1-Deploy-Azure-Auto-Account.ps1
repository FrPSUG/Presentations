# Varibales
$rgName = "FRPSUG"
$location = "West Europe"
$runbookName = "Deploy-Windows-VM"
$svcAccount = "SvcAccountAdmin"
$User = "admin@tenant.onmicrosoft.com" # account that has access to deploy resources in the subscription
$secure_password = Read-Host "Enter the password for the account admin" -AsSecureString
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $secure_password

# Connect to Azure account
Connect-AzAccount -Credential $Credential

# Select the right subscription
Select-AzSubscription -SubscriptionName "Microsoft Azure Sponsorship - Others" # Your subscription where to deploy the AA account

# Create the RG
New-AzResourceGroup -Name $rgName -Location $location

# Create the Automation Account
New-AzAutomationAccount -ResourceGroupName $rgName -Name $rgName -Location $location

# Create the credential to deploy the template and that has rights on the subscription
New-AzAutomationCredential -AutomationAccountName $rgName -Name $svcAccount -Value $Credential -ResourceGroupName $rgName

# Import the script
Import-AzAutomationRunbook -Path .\2-Deploy-Azure-VM.ps1 -ResourceGroupName $rgName -AutomationAccountName $rgName `
    -Name $runbookName -Type PowerShell -Publish:$true

# Create a webhook
$Webhook = New-AzAutomationWebhook -Name "Webhook$rgName" -IsEnabled $True -ExpiryTime "10/2/2019" `
     -RunbookName $runbookName -ResourceGroup $rgName -AutomationAccountName $rgName -Force

# Importing modules in Azure Automation account
New-AzAutomationModule -AutomationAccountName $rgName -Name "Az.Accounts" `
    -ContentLink "https://devopsgallerystorage.blob.core.windows.net:443/packages/az.accounts.1.4.0.nupkg" -ResourceGroupName $rgName
New-AzAutomationModule -AutomationAccountName $rgName -Name "Az.Resources" `
    -ContentLink "https://devopsgallerystorage.blob.core.windows.net:443/packages/az.resources.1.2.1.nupkg" -ResourceGroupName $rgName

# Write the webhook URL
Write-Output $Webhook.WebhookURI