   <#
    .SYNOPSIS
        Return the Time for the time Zone
    .DESCRIPTION
        Return the Time for the time Zone
    .PARAMETER TimeZoneCode
        The Name of the Time Zone
    .EXAMPLE

    .NOTES
        Oliver Miossec
        @omiossec_med
        https://www.linkedin.com/in/omiossec/
    .OUTPUTS
        datatime
    #>
function get-psmWorldClock {

    [Cmdletbinding()]
    Param(

            [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
            [ValidateSet("CET","RET","PR","ET","GMT","WIT","UTC")]
            [String]
            $TimeZone
    )


        $WebServiceApi = "http://worldclockapi.com/api/json/$($TimeZone)/now"


        try {

            $WorlClockJsonResult = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $WebServiceApi
            #Change this
            #return [datetime]::parseexact($WorlClockJsonResult.currentDateTime, 'yyyy-MM-ddTHH:mm+ss:ff', $null)
            return $WorlClockJsonResult.currentDateTime
        }
        catch [System.Net.WebException] {

            if ($_.Exception.Response.StatusCode -eq "NotFound")
            {
                # nothing found send a $null instead of error
                Write-Error "Page not found check the url $($WebServiceApi)"
            }
            else {

                Write-Error "Receive a http exception StatusCode " + $_.Exception.Response.StatusCode

            }

        }
        catch {

            Write-Error "Receive a general error " +  $_.Exception
        }

}