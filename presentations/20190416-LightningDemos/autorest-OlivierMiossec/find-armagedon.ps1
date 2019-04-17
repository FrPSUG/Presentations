Function find-armagedon
{
<#
.SYNOPSIS
    Function to potentially hazardous asteroid in NASA/JPL NEO API
.DESCRIPTION
    Function to potentially hazardous asteroid in NASA/JPL NEO API
    This function is par of a demo from Olivier Miossec (https://github.com/omiossec) to illustrate module creation with AutoRest PowerShell
    for the French PowerShell User Group (https://www.meetup.com/fr-FR/FrenchPSUG)
.EXAMPLE
    find-armagedon
    Return Call Bruce Willis if one or more dangerous asteroid is find 
.NOTES
    https://github.com/omiossec
    https://frpsug.com
#>

[CmdletBinding(DefaultParameterSetName='NeoStatistics')]
param(
    [Parameter(DontShow)]
    [System.Management.Automation.SwitchParameter]
    # Wait for .NET debugger to attach
    ${Break},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [frpsug.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be appended to the front of the pipeline
    ${HttpPipelineAppend},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [frpsug.Runtime.SendAsyncStep[]]
    # SendAsync Pipeline Steps to be prepended to the front of the pipeline
    ${HttpPipelinePrepend},

    [Parameter(DontShow)]
    [System.Uri]
    # The URI for the proxy server to use
    ${Proxy},

    [Parameter(DontShow)]
    [ValidateNotNull()]
    [System.Management.Automation.PSCredential]
    # Credentials for a proxy server to use for the remote call
    ${ProxyCredential},

    [Parameter(DontShow)]
    [System.Management.Automation.SwitchParameter]
    # Use the default credentials for the proxy
    ${ProxyUseDefaultCredentials}
)

$AsteroidList = (Invoke-BrowseNeoObject -Page 0 -Size 50).NearEarthObjects
$ArmagdonPresent = $false
$HazardousAsteroid  = New-Object System.Collections.ArrayList($null)

foreach ($asteroid in $AsteroidList) {
    if ($asteroid.IsPotentiallyHazardousAsteroid -eq $true) {
        $ArmagdonPresent = $true
        $null = $HazardousAsteroid.Add($asteroid.Designation) 
    }
}
    if ($ArmagdonPresent) {
        write-host "Call Bruce Willis, $($HazardousAsteroid.Count) are comming" -ForegroundColor Red
        $listOfAsteroid = $HazardousAsteroid -join ','
        write-host $listOfAsteroid
        Start-Process "https://www.youtube.com/watch?v=V0vy33Br_3s"
    }
    else {
        write-host "Bruce Willis can stay at home" -ForegroundColor Blue
    }

}