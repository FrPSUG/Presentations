Param
(
    [object]$WebhookData
)

if ($WebhookData){

    $WebhookName = $WebHookData.WebhookName
    $WebhookHeaders = $WebHookData.RequestHeader
    $WebhookBody = $WebHookData.RequestBody

    $From = $WebhookHeaders.From
    $All = (ConvertFrom-Json -InputObject $WebhookBody)
    $automationAccount = Get-AutomationPSCredential -Name 'SvcAccountAdmin'

    $rgName = $All.rgName
    $adminName = $All.adminName
    $PasswordProfile = $All.PasswordProfile
    $dnsLabelPrefix = $All.dnsLabelPrefix
    $windowsOSVersion = $All.windowsOSVersion
    $location = "West Europe"
    $SecurePassword = ConvertTo-SecureString $PasswordProfile -asplaintext -force

    Connect-AzAccount -Credential $automationAccount
    New-AzResourceGroup -Name $rgName -Location $location
    New-AzResourceGroupDeployment -ResourceGroupName $rgName `
        -TemplateUri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/101-vm-simple-windows/azuredeploy.json `
        -adminUsername $adminName -adminPassword $SecurePassword `
        -dnsLabelPrefix $dnsLabelPrefix -windowsOSVersion $windowsOSVersion -location $location

}

#Test
<# $webhookurl = 'https://s2events.azure-automation.net/webhooks?token=SISOwyGHYCPedmmW%2fLF%2fgPLKB%2bUtySyv4QZQLWzn%2bG8%3d'

$body = @{"rgName" = "TestFRPSUG"; "adminName" = "florent"; "PasswordProfile" = "TestFR2019!"; "dnsLabelPrefix" = "testflorentapp2"; "windowsOSVersion" = "2016-Datacenter"}

$params = @{
    ContentType = 'application/json'
    Body = ($body | convertto-json)
    Method = 'Post'
    URI = $webhookurl
}

Invoke-RestMethod @params -Verbose #>