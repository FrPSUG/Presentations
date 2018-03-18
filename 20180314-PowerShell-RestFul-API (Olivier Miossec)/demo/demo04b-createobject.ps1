$token = 'zFsTONrelBxeHFXWkiCSvlfKQMhrdHLM'

$secureToken = ConvertTo-SecureString $token -AsPlainText -Force
$AuthentificationToken = New-Object System.Management.Automation.PSCredential("token", $secureToken)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ObjectServices = @("REF_CiclNPzuFU","REF_zbCXCkAONs")
$ServiceType = @("tcp")




$NewService = @{
    "comment" = "Added by PowerShell"
    "members" = $ObjectServices
    "name" = "webapp"
    "types" = $ServiceType
}
$JsonObject = $NewService | ConvertTo-Json
$JsonObject

<#
Les entêtes suivante gèrent comment sont gérer les erreur
X-Restd-Err-Ack évite les situations où la création d'un object 2 implique l'utilisation d'un object 1 qui aurait été supprimé
X-Restd-Lock-Override permet d'ajout un lock à un object lors de l'opération
#>
$headers = @{
    "X-Restd-Err-Ack"="all"
    "X-Restd-Lock-Override"="yes"
}


 

$SophosSgApiUri = "https://sgdemo.omiossec.work:4444/api/objects/service/group/"

$SophosSgApiResult = Invoke-RestMethod -Method post -uri $SophosSgApiUri -Credential $AuthentificationToken  -Body $JsonObject -ContentType "application/json" -Headers $headers


write-host $SophosSgApiResult._type

write-host $SophosSgApiResult._ref