$token = 'zFsTONrelBxeHFXWkiCSvlfKQMhrdHLM'

function invoke-sophossgapi {
    <#
    .SYNOPSIS
        Function to send request to the sophos api
    .DESCRIPTION
        Function to send request to the sophos api
    .PARAMETER token
        Specifies the token credential 
    .PARAMETER URI
        Specifies the URI with the port
    .PARAMETER Methode
        Specifies the HTTP method, GET, POST, DELETE, PATCH, PUT
    .PARAMETER BODY
        Hashtable 
    .EXAMPLE
        
       invoke-sophossgapi -token xxxxxxx -uri "https://firewallsg:4444/object/network/host" -methode GET
        retreive a pscostumobject 

    .NOTES
        Oliver Miossec 
        @omiossec_med
        https://www.linkedin.com/in/omiossec/
    .OUTPUTS
        PsCustumObject 

#>


    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)]
        [string]
        $token,

        [parameter(Mandatory=$true)]
        [string]
        $uri,

        [parameter(Mandatory=$true)]
        [ValidateSet("Get","Post","Delete","Patch","Put")]
        [string]
        $method,

        [parameter(Mandatory=$false)]
        $body
    )

    begin {

  
        # use .net to use TLS 1.2 used in Sophos SG web server
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $secureToken = ConvertTo-SecureString $token -AsPlainText -Force
        $AuthentificationToken = New-Object System.Management.Automation.PSCredential("token", $secureToken)
        
    }

    process {

        try {


            $headers = @{
               "X-Restd-Err-Ack"="all"
               "X-Restd-Lock-Override"="yes"
            }


           if ($PSBoundParameters.ContainsKey('body'))
           {
               
               $result = Invoke-RestMethod -Method $method -uri $uri -body $body -Credential $AuthentificationToken -ContentType "application/json" -Headers $headers
   
           }
           elseif ($method -ne "Get") {

               $result = Invoke-RestMethod -Method $method -uri $uri -Credential $AuthentificationToken -Headers $headers
   
           }
           else {
               $result = Invoke-RestMethod -Method $method -uri $uri -Credential $AuthentificationToken
           }
           
           return $result

        }
        catch [System.Net.WebException] {
            
            if ($_.Exception.Response.StatusCode -eq "NotFound")
            {
                # nothing found send a $null instead of error
                return $null
            }
            else {

                throw "Receive a http exception StatusCode " +  $_.Exception.Response.StatusCode
                write-debug $_.Exception
            }
        
        }
        catch {
            write-debug $_.Exception
            throw "Receive a general error " +  $_.Exception
        }

       
    }

    end {
    }


}











$VMjsonPath =  join-path  -path $PSScriptRoot  -childpath 'vmlist.json' -Resolve

$VmObjects = (Get-Content $VMjsonPath -Raw | ConvertFrom-Json) 

$HostObjectUri = "https://sgdemo.omiossec.work:4444//api/objects/network/host/"


$VmListByRoleNode = new-object System.Collections.ArrayList

$vmHashByRoleGroup = @{}


foreach ($group in $VmObjects.AllGroups) {


        

        foreach ($vm in $group.vms) {
            

            $ObjectIpHost = @{
                "comment" = $group.groupeName 
                "name" = $vm.VMName
                "resolved" = $false
                "resolved6" = $false
                "address"= $vm.Ip
            }

            $JsonIpHost = $ObjectIpHost | ConvertTo-Json
            
            $SophosSgApiResult = invoke-sophossgapi -token $token -uri $HostObjectUri  -method Post -body $JsonIpHost

            
            write-host $SophosSgApiResult._Ref

            $InsterdObject = @{

                "group" = $group.groupeName
                "vmname" = $vm.VMName
                "IP" = $vm.Ip
                "Role" = $vm.role
                "_ref" = $SophosSgApiResult._ref

            }

            $VmListByRoleNode.Add($InsterdObject)
            $VmListByRoleNode = new-object System.Collections.ArrayList

                

            if ($vmHashByRoleGroup[$vm.role] -eq $null) {

                $vmHashByRoleGroup.add($vm.role, @{$group.groupeName= @{ip=$vm.ip;name=$vm.vmname;ref=$vm._ref}})

            }
            else {
                #$vmHashByRoleGroup[$vm.role].add($group.groupeName)
                if ($vmHashByRoleGroup[$vm.role][$group.groupeName] -eq $null){
                    
                    $vmHashByRoleGroup[$vm.role].add($group.groupeName, @{ip=$vm.ip;name=$vm.vmname;ref=$vm._ref})
                }
                

          }

        }
}

 $vmHashByRoleGroup | ConvertTo-Json

 


