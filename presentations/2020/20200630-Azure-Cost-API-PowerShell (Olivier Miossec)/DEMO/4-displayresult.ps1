$body = @{
    "type"="Usage"
  "timeframe"="Custom"
    "timePeriod"= @{
        "from"="2019-01-01T00:00:00+00:00"
      "to"="2019-06-30T00:00:00+00:00"
   };
 "dataSet"=@{
     "granularity"="none"
       "aggregation"=@{
           "totalCost"=@{
              "name"="PreTaxCost"
              "function"="Sum"
                }
            }
            "grouping" = @(
                    @{
                    "type" = "Dimension"
                    "name"= "ResourceGroup"
                    }   
            )
          "sorting"=@(
              @{
                  "direction"="ascending"
                  "name"="UsageDate"
                }
            )
     }
 }




 [String]$APIversion = "2019-04-01-preview"

 [String]$Scope = "subscriptions/$($SubscriptionID)"

 [String]$uri =  "https://management.azure.com/$Scope/providers/Microsoft.CostManagement/query?api-version=2019-04-01-preview"

 $headers = @{"authorization"="Bearer  $($token.access_token.ToString())"}

 $Json = $body | convertto-json -Depth 10

 $results = Invoke-RestMethod $uri -Headers $headers -ContentType "application/json" -Body $Json -Method Post




 Import-module UniversalDashboard.Community -Force 
 $SubscriptionCostList = [System.Collections.ArrayList]::new()
 foreach ($row in $results.properties.rows){ 
    [void]$SubscriptionCostList.Add([pscustomobject]@{ 
        ResourceGroup     =   $row[1]
        Cost              =   $row[0]
    })
 }
 $Cache:Data = $SubscriptionCostList

 $UdTheme = Get-UDTheme -Name 'Azure'

$UDDemoPage = New-UDDashboard -Title "Demo Dashboard" -Theme $UdTheme -Content{
        
        New-UdGrid -Title "RG Cost" -Endpoint {
            $Cache:Data| Out-UDGridData
        }

    }


Get-UDDashboard | Stop-UDDashboard
Start-UDDashboard -Port 8000 -Name webfront01 -Dashboard $UDDemoPage 


