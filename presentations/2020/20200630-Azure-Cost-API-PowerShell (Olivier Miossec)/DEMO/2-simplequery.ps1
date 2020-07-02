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

 $results.properties.rows 