
import-module PoshSpec
Describe "MyRegistry" {
    Registry "HKLM:\SOFTWARE\HitmanPro.Alert\chrome.exe" { Should Exist }
}


Describe "Site Paris.fr" {

    Http "http://www.paris.fr" StatusCode { Should Be 200 }

    Http "http://www.paris.fr" RawContent { Should not Match 'X-Powered-By: ASP.NET' }

}