function new-psSatWebApp {

    [cmdletbinding()]
    Param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty]
        [string]
        $ApplicationName

    )

    copy-item F:\tpl\tpl  "f:\Exploitation\www\$($ApplicationName)" -Recurse

    $AppPoolName = "App01"

    New-WebApplication -Site "Default Web Site" -Name $ApplicationName -PhysicalPath "f:\www\$($ApplicationName)" -ApplicationPool $AppPoolName

}

function start-PsSatServices {

    start-service W32Time
    
    }

    function stop-pssatServices {

        Stop-Service W32Time
        
        }