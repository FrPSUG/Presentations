# Par Login / Mot de Passe 

$SophosSgAccount = Get-Credential -Message "Sophos Admin User"


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Invoke-RestMethod -Method get -uri "https://sgdemo.omiossec.work:4444/api/objects/network/host/" -Credential $SophosSgAccount 


# avec une Web session


$SophosSgAccount = Get-Credential -Message "Sophos Admin User"


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Invoke-RestMethod -Method get -uri "https://sgdemo.omiossec.work:4444/api/objects/network/host/" -Credential $SophosSgAccount  -SessionVariable MySophosSession


Invoke-RestMethod -Method get -uri "https://sgdemo.omiossec.work:4444/api/objects/network/interface_address/" -WebSession $MySophosSession

write-host $MySophosSession