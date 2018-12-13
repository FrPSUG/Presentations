 

Given "A Web site" { 
    "http://www.paris.fr" | Should not be BeNullOrEmpty
 }

 When "You we call it"  {

   
 }

 Then "we got an OK Code" {
    $webresult =  Invoke-WebRequest -UseBasicParsing -Uri "http://www.paris.fr"
    $webresult.BaseResponse.StatusCode | Should Be "OK"
 }