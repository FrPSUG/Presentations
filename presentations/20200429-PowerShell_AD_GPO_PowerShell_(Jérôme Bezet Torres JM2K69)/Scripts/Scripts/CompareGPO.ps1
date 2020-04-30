[CmdletBinding()]
Param(
		[Parameter(Mandatory=$true)]	
        [string]$FirstGPO,
        [Parameter(Mandatory=$true)]	
		[string]$SecondGPO,
		[Parameter(Mandatory=$true)]	
        [string]$Output_Folder,
        [Parameter(Mandatory=$false)]	
        [switch]$Launch
    )	
## Check Powershell Module 
    $Getmodules = Get-Module -listavailable
    foreach ($m in @("GPRegistryPolicyParser","PSHTML"))
    {
        If (!($Getmodules | Where-Object {$_.name -like "*$m*"})) 
            { 
                Install-Module GPRegistryPolicyParser  -ErrorAction SilentlyContinue
                Install-Module PSHTML  -ErrorAction SilentlyContinue
            } 
        Else 
            { 
                Import-Module GPRegistryPolicyParser  -ErrorAction SilentlyContinue -DisableNameChecking	
                Import-Module PSHTML  -ErrorAction SilentlyContinue	
            } 
    }
    ## Test Path
if(!(Test-Path $Output_Folder))
{
    New-Item -Path $Output_Folder -ItemType Directory | Out-Null
} 

## Extract Data

        $ResolveGPO1 = Get-ChildItem -Path $FirstGPO -File 'registry.pol' -Recurse | % {$_.FullName}
        $FirtsGPOTitle = $($ResolveGPO1.split("\"))[2]
        $FirstGPODateFull = $($ResolveGPO1.split("\"))[3].split("_")
        $FirstGPODate = $($ResolveGPO1.split("\"))[3].split("_")[0]+"\"+$($ResolveGPO1.split("\"))[3].split("_")[1]+"\"+$($ResolveGPO1.split("\"))[3].split("_")[2]
        $FirstGPOTime = $($ResolveGPO1.split("\"))[3].split("_")[3]+"h"+$($ResolveGPO1.split("\"))[3].split("_")[4]+"min"+$($ResolveGPO1.split("\"))[3].split("_")[5]+"sec"

        if ($ResolveGPO1 -like "*Machine*")
        {
        $Script:FirstGPOScope = 'HKLM:\'
        }
        else
        {
            $Script:FirstGPOScope = 'HKCU:\'
        }
        $ResolveGPO2 = Get-ChildItem -Path $SecondGPO -File 'registry.pol' -Recurse | % {$_.FullName}
        $SecondGPOTitle = $($ResolveGPO2.split("\"))[2]
        $SecondGPODate = $($ResolveGPO2.split("\"))[3].split("_")[0]+"\"+$($ResolveGPO2.split("\"))[3].split("_")[1]+"\"+$($ResolveGPO2.split("\"))[3].split("_")[2]
        $SecondGPOTime = $($ResolveGPO2.split("\"))[3].split("_")[3]+"h"+$($ResolveGPO2.split("\"))[3].split("_")[4]+"min"+$($ResolveGPO2.split("\"))[3].split("_")[5]+"sec"
        if ($ResolveGPO2 -like "*Machine*")
        {
            $Script:SecondGPOScope = 'HKLM:\'
        }
        else
        {
            $Script:SecondGPOScope = 'HKCU:\'
        }
        if ($Script:FirstGPOScope -eq $Script:FirstGPOScope)
        {
            $Script:Scope = $Script:FirstGPOScope
        }
        else
        {
            Write-Warning "There is en error you try to compare two GPO with different scope or with multi Scope Computers and Users"
            break
        }
## End Extraction Data

## Parse GPO Files

        $ParseFirstGPO = Parse-PolFile $ResolveGPO1 |   Select-Object *,@{n='FullKey';e={'{0}{1}' -f "$Script:Scope",$_.KeyName +'\' +$_.ValueName}} 
        $ParseSecondGPO = Parse-PolFile $ResolveGPO2 |   Select-Object *,@{n='FullKey';e={'{0}{1}' -f "$Script:Scope",$_.KeyName +'\' +$_.ValueName}} 
        $ParseDiff = Compare-Object -ReferenceObject $ParseFirstGPO -DifferenceObject $ParseSecondGPO -Property KeyName, ValueData, ValueName, ValueType, ValueLength, ValueDate, FullKey | Where {$_.SideIndicator -eq "=>"}

## End Parse GPO Files

## HTML Report with PSHTML
$css = 'body{background:#dbdbdb;font:87.5%/1.5em Lato,sans-serif;padding:15px}table{border-spacing:2px;border-collapse:collapse;background:#F7F6F6;border-radius:6px;overflow:hidden;max-width:800px;width:100%;margin:0 auto;position:relative}td,th{padding-left:8px}thead tr{height:60px;background:#367AB1;color:#F5F6FA;font-size:1.2em;font-weight:700;text-transform:uppercase}tbody tr{height:48px;border-bottom:1px solid #367AB1;text-transform:capitalize;font-size:1em;&:last-child {;border:0}tr:nth-child(even){background-color:#E8E9E8}'
$filename = "Report_"+$FirtsGPOTitle+".html" 
html {
    head {
        Title "French Meetup FRPUG "
        Link -href "https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" -rel "stylesheet" 
        script -src "https://maxcdn.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" -type "text/javascript"
        style {
            $css
        }
    }
    body {
        div -Class "conatiner-fluid"{
            div -Class "row" {
                div -Class "col" {
                    img -Class "rounded float-left" -src "https://raw.githubusercontent.com/FrPSUG/media/master/frpsug/logo/Michael_Lopes/powershell-3.0.png" -height "100" -width "100" 
                    h1 -Class "text-right" 'Powershell report'
                }
                div -Class "col"{ h1 -Class "text-left" 'compare two GPO.'
                }
            }
        }
        p{" "}
        p{" "}
            div -Class "container-fluid" {
                div -Class "row"{
                        div -Class "col" {
                                                h4 -Class "text-center" "GPO $FirtsGPOTitle $FirstGPODate $FirstGPOTime"
                                                ConvertTo-PSHTMLtable -Object  $ParseFirstGPO  -properties FullKey,ValueType,ValueData -TableClass "table-primary"
                                                p{" "}
                                            }
                                            
                        div -Class "col" {
                                                p{" "}
                                                h4 -Class "text-center" "GPO $SecondGPOTitle $SecondGPODate $SecondGPOTime"
                                                ConvertTo-PSHTMLtable -Object $ParseSecondGPO -properties FullKey,ValueType,ValueData -TableClass "table-secondary" }
                                }
                        
                }
                If ($null -eq $ParseDiff){

                }
                else
                {
                    p{" "}
                    h2 -Class "text-center" 'The difference between two Group Policy Objects.'        
                    Div {

                    ConvertTo-PSHTMLtable -Object $ParseDiff  -properties FullKey,ValueType,ValueData -TableClass "table-danger"
                    }

                }
    }
    footer {
        $PSHTMLlink = a {"PSHTML"} -href "https://github.com/Stephanevg/PSHTML"
        $JM2K69 = a {"JM2K69"} -href "https://twitter.com/JM2K69"
        $Blog = a {"Blog"} -href "https://jm2k69.github.io/"
        p{" "}
        p{
            h6  "Generated with &#x2764 using $($PSHTMLlink) by $JM2K69 $(Get-Date) Copyright 2019 - $Blog "
        }
    }
    
}  | Out-File -FilePath "$Output_Folder\$filename" -Encoding utf8 -Force

if ($Launch)
{
    Start-Process $Output_Folder\$filename
}
