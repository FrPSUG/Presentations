# Using a Service Principal Name

$TokenEndpoint = "https://login.windows.net/$($TenantID)/oauth2/token"


$AuthenticateBody = @{
                    "resource"=  "https://management.azure.com/"
                    "client_id" = $ClientID
                    "grant_type" = "client_credentials"
                    "client_secret" = $ClientSecret
                }

 $token = Invoke-RestMethod -ContentType 'application/x-www-form-urlencoded' -Headers  @{'accept'='application/json'} -Body $AuthenticateBody -Method 'Post' -URI $TokenEndpoint

 

 $ARMResource = "https://management.azure.com/"