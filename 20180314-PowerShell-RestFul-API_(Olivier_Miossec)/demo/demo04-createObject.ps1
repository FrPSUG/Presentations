$token = 'zFsTONrelBxeHFXWkiCSvlfKQMhrdHLM'

$secureToken = ConvertTo-SecureString $token -AsPlainText -Force
$AuthentificationToken = New-Object System.Management.Automation.PSCredential("token", $secureToken)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ObjectIpHost = @{"name"="server2";"Ip"="10.34.2.12"}


<#
Json Schema
[
  {
    "address": IPv4,
    "address6": IPv6,
    "comment": "string",
    "duids": [],
    "hostnames": [],
    "interface": "",
    "macs": [],
    "name": "string",
    "resolved": false,
    "resolved6": false,
    "reverse_dns": false
  }
]

#>

$ObjectIpHost = @{
    "comment" = "Added by PowerShell"

    "name" = $ObjectIpHost.name

    "address"= $ObjectIpHost.Ip
}
$JsonObject = $ObjectIpHost | ConvertTo-Json

$headers = @{
    "X-Restd-Err-Ack"="all"
    "X-Restd-Lock-Override"="yes"
}


$token = 'zFsTONrelBxeHFXWkiCSvlfKQMhrdHLM'

$secureToken = ConvertTo-SecureString $token -AsPlainText -Force
$AuthentificationToken = New-Object System.Management.Automation.PSCredential("token", $secureToken)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$SophosSgApiUri = "https://sgdemo.omiossec.work:4444//api/objects/network/host/"

$SophosSgApiResult = Invoke-RestMethod -Method post -uri $SophosSgApiUri -Credential $AuthentificationToken  -Body $JsonObject -ContentType "application/json" -Headers $headers


write-host $SophosSgApiResult._type

write-host $SophosSgApiResult._ref