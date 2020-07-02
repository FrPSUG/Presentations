Import-module UniversalDashboard.Community -Force 

$TenantID = "xxxxxx"
$ClientID ="xxxxxx"
$ClientSecret = "xxxxxxx"
$SubscriptionID = "xxxxxx"

$TokenEndpoint = "https://login.windows.net/$($TenantID)/oauth2/token"


$AuthenticateBody = @{
                    "resource"=  "https://management.azure.com/"
                    "client_id" = $ClientID
                    "grant_type" = "client_credentials"
                    "client_secret" = $ClientSecret
                }

$token = Invoke-RestMethod -ContentType 'application/x-www-form-urlencoded' -Headers  @{'accept'='application/json'} -Body $AuthenticateBody -Method 'Post' -URI $TokenEndpoint


$body = @{
    "type"="Usage"
  "timeframe"="Custom"
    "timePeriod"= @{
        "from"="2019-06-18T00:00:00+00:00"
      "to"="2019-06-30T00:00:00+00:00"
   };
 "dataSet"=@{
     "granularity"="Daily"
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

 $Json = $body | convertto-json -Depth 10

 $headers = @{"authorization"="Bearer  $($token.access_token.ToString())"}

 $results = Invoke-RestMethod $uri -Headers $headers -ContentType "application/json" -Body $Json -Method Post

 $SubscriptionCostList = [System.Collections.ArrayList]::new()



 $YesterdayDate = get-date -Year 2019 -Month 6 -Day 29 
 $DMinus17 = (get-date -Year 2019 -Month 6 -Day 30 ).AddDays(-12)
 $DMinus17 = Get-Date -Year $DMinus17.Year -Month $DMinus17.Month -Day $DMinus17.Day -Hour "0" -Minute "0" -Second "00"


 foreach ($row in $results.properties.rows){
     $datecost = [datetime]::parseexact($row[1], 'yyyyMMdd', $null)
     $datecost = Get-Date -Year $datecost.Year -Month $datecost.Month -Day $datecost.Day -Hour "23" -Minute "59" -Second "00"
     
     [void]$SubscriptionCostList.Add([pscustomobject]@{ 
         ResourceGroup     =   $row[2]
         Cost              =   $row[0]
         Position          =  $datecost.Subtract($DMinus17).Days
         date              =  $row[1]
     })
 }


 [String]$APIversion = "2019-04-01-preview"

 [String]$Scope = "subscriptions/$($SubscriptionID)"

 [String]$uri =  "https://management.azure.com/$Scope/providers/Microsoft.CostManagement/query?api-version=2019-04-01-preview"

 $headers = @{"authorization"="Bearer  $($token.access_token.ToString())"}

 $Json = $body | convertto-json -Depth 10

 $results = Invoke-RestMethod $uri -Headers $headers -ContentType "application/json" -Body $Json -Method Post


 $rglist = $SubscriptionCostList | Select-Object -Property "ResourceGroup" -Unique

 $RgResult = [System.Collections.ArrayList]::new()

 foreach ($rg in $rglist) {

   $rgdata = $SubscriptionCostList | where-Object "ResourceGroup" -eq $rg.ResourceGroup

   $lastday = ($SubscriptionCostList | where-Object "ResourceGroup" -eq $rg.ResourceGroup | Measure-Object -Sum -Property cost).Count - 1
   
   $CostChange = @()
   $CostChangeTotal = 0
   for ($i = 1; $i -lt $lastday; $i++){
       [decimal]$CostDay = $rgdata[$i].cost
       [decimal]$CostDayMinus1 = $rgdata[$i-1].cost

       if ($CostDayMinus1 -eq 0) {
           $CurrentChange = 0
       }
       else {
           [decimal]$CurrentChange = (($CostDay - $CostDayMinus1)/ $CostDayMinus1) * 100
       }
       $CostChange += $CurrentChange
       $CostChangeTotal += $CurrentChange

   }
   
   $Mean = $CostChangeTotal / $CostChange.Count
   $StdVarCalc = 0
   for ($i = 0; $i -le $CostChange.Count; $i++){
       
       $StdVarCalc +=   [math]::Pow(($CostChange[$i] - $Mean),2)
   }
   
   $StdDeviation =    [math]::Sqrt($StdVarCalc / $CostChange.Count)

   $LastDayChange = (($rgdata[$i].cost - $rgdata[$i-1].cost)/ $rgdata[$i-1].cost) * 100
   
   [void]$RgResult.Add([pscustomobject]@{ 
    ResourceGroup     =   $rg.ResourceGroup
    MeanChange              =   $Mean
    LastDayChange = $LastDayChange
    StdDev    = $StdDeviation
    })
   

  

}


Import-module UniversalDashboard.Community -Force 

$Cache:Data = $RgResult

$UDDemoPage = New-UDDashboard -Title "Rg Stat Dashboard" -Theme $UdTheme -Content{
        
        New-UdGrid -Title "RG Change during Period" -Endpoint {
            $Cache:Data | Out-UDGridData
        }

    }
$UdTheme = Get-UDTheme -Name 'Azure'

Get-UDDashboard | Stop-UDDashboard
Start-UDDashboard -Port 8000 -Name webfront01 -Dashboard $UDDemoPage -wait