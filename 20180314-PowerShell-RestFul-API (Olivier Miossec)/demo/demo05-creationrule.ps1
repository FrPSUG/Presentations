##DEMO CREATION D'UN OBJECT##
$token = 'zFsTONrelBxeHFXWkiCSvlfKQMhrdHLM'

$secureToken = ConvertTo-SecureString $token -AsPlainText -Force
$AuthentificationToken = New-Object System.Management.Automation.PSCredential("token", $secureToken)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$SophosSgApiUri = "https://sgdemo.omiossec.work:4444/api/"

# Services 
#MS SQL & HTTP

$ServicesTCPUrl = $SophosSgApiUri + "objects/service/tcp/"
$ServicesUDPUrl = $SophosSgApiUri + "objects/service/udp/" 
$ServicesTCPUDPUrl = $SophosSgApiUri + "objects/service/tcpudp/"
$ServicesGroupUrl = $SophosSgApiUri + "objects/service/group/"

$ServicesTcpList = Invoke-RestMethod -Method get -uri $ServicesTCPUrl -Credential $AuthentificationToken 
$ServicesUdpList = Invoke-RestMethod -Method get -uri $ServicesUDPUrl -Credential $AuthentificationToken 
$ServicesTcpUdpList = Invoke-RestMethod -Method get -uri $ServicesTCPUDPUrl -Credential $AuthentificationToken
$ServicesGroupList = Invoke-RestMethod -Method get -uri $ServicesGroupUrl -Credential $AuthentificationToken

$ServicesList = $ServicesTcpList + $ServicesUdpList + $ServicesTcpUdpList + $ServicesGroupList

$MSSqlServiceRef = ""
$HTTPServiceRef = ""
$WebAppServiceRef = ""

foreach ($objService in $ServicesList)
{
    
        switch ($objService.name) {
            "MS SQL" {  
                $MSSqlServiceRef = $objService._ref
            }
            "HTTP" {  
                $HTTPServiceRef = $objService._ref    
            }
            "webapp" {  
                $WebAppServiceRef = $objService._ref
            }
        }
}

write-host "MS SQL REF $($MSSqlServiceRef)" 
write-host "HTTP REF $($HTTPServiceRef)"
write-host "WebApp REF $($WebAppServiceRef)"

# creation des hosts 

$ObjectIpSQL = @{
    "comment" = "Added by PowerShell"
    "name" = "vm-SQL03"
    "address"= "10.10.0.203"
}
$ObjectIpWeb = @{
    "comment" = "Added by PowerShell"
    "name" = "vm-front03"
    "address"= "10.12.0.203"
}

$ObjectIpBS = @{
    "comment" = "Added by PowerShell"
    "name" = "vm-bs02"
    "address"= "10.11.0.203"
}

$JsonIpSQL = $ObjectIpSQL | ConvertTo-Json
$JsonIpWeb= $ObjectIpWeb | ConvertTo-Json
$JsonIpBS= $ObjectIpBS | ConvertTo-Json

$headers = @{
    "X-Restd-Err-Ack"="all"
    "X-Restd-Lock-Override"="yes"
}

$SophosSgApiUri = "https://sgdemo.omiossec.work:4444//api/objects/network/host/"

$SophosIpSQLResult = Invoke-RestMethod -Method post -uri $SophosSgApiUri -Credential $AuthentificationToken  -Body $JsonIpSQL -ContentType "application/json" -Headers $headers
$SophosIpWebResult = Invoke-RestMethod -Method post -uri $SophosSgApiUri -Credential $AuthentificationToken  -Body $JsonIpWeb -ContentType "application/json" -Headers $headers
$SophosIpBSResult = Invoke-RestMethod -Method post -uri $SophosSgApiUri -Credential $AuthentificationToken  -Body $JsonIpBS -ContentType "application/json" -Headers $headers


$refSql = $SophosIpSQLResult._ref
$refWeb = $SophosIpWebResult._ref
$refBS = $SophosIpBSResult._ref


write-host "SQL REF $($refSql)" 
write-host "Web REF $($refWeb)"
write-host "BS REF $($refBS)"


#Creation des Regles
<#

{
    "action": "accept",
    "comment": "string",
    "destinations": [],
    "direction": "in",
    "log": true,
    "name": "string",
    "services": [],
    "sources": [],
    "status": true
  }

#>
$RulesApiUri = "https://sgdemo.omiossec.work:4444/api/objects/packetfilter/packetfilter/"
#Regle 1 ANY HTTP TO WEB
$RefAny = @("REF_NetworkAny")
$RefHttp = @($HTTPServiceRef)
$RefDestinationHTTP = @($refWeb)

$RuleAnytoWeb = @{
    "action" = "accept"
    "comment"= "Added By PowerShell"
    "destinations"= $RefDestinationHTTP
    "log" = $true
    "services"= $RefHttp 
    "sources"= $RefAny
    "status"= $true
}
$RuleAnytoWebJson = $RuleAnytoWeb | ConvertTo-Json

invoke-RestMethod -Method post -uri $RulesApiUri -Credential $AuthentificationToken  -Body $RuleAnytoWebJson -ContentType "application/json" -Headers $headers

#Rule 2 BS to SQL
$RefService = @($MSSqlServiceRef)
$RefFrom = @($refBS)
$RefTo = @($refSql)

$RuleSql = @{
    "action" = "accept"
    "comment"= "Added By PowerShell"
    "destinations"= $RefTo
    "log" = $true
    "services"= $RefService
    "sources"= $RefFrom
    "status"= $true
}
$RuleSQLJson = $RuleSql | ConvertTo-Json

invoke-RestMethod -Method post -uri $RulesApiUri -Credential $AuthentificationToken  -Body $RuleSQLJson -ContentType "application/json" -Headers $headers


#Rule 3 web to bs
$RefService = @($WebAppServiceRef)
$RefFrom = @($refWeb)
$RefTo = @($refBS)

$RuleBs= @{
    "action" = "accept"
    "comment"= "Added By PowerShell"
    "destinations"=  $RefTo
    "log" = $true
    "services"= $RefService
    "sources"= $RefFrom
    "status"= $true
}
$RuleBSJson = $RuleBs | ConvertTo-Json

invoke-RestMethod -Method post -uri $RulesApiUri -Credential $AuthentificationToken  -Body $RuleBSJson -ContentType "application/json" -Headers $headers
