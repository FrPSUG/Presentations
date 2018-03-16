
$token = 'zFsTONrelBxeHFXWkiCSvlfKQMhrdHLM'

$secureToken = ConvertTo-SecureString $token -AsPlainText -Force
$AuthentificationToken = New-Object System.Management.Automation.PSCredential("token", $secureToken)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Invoke-RestMethod -Method get -uri "https://sgdemo.omiossec.work:4444//api/objects/network/host/" -Credential $AuthentificationToken 