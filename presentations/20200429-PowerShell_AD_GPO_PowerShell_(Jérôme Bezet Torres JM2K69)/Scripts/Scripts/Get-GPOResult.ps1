[CmdletBinding()]
Param(
		[Parameter(Mandatory=$true)]	
        [string]$GPOName,
		[Parameter(Mandatory=$true)]	
        [string]$Output_Folder,
        [Parameter(Mandatory=$false)]	
        [switch]$Launch,
        [Parameter(Mandatory=$False,
        ParameterSetName='Backup')]	
        [switch]$CheckBackup,
        [Parameter(Mandatory=$false,
        ParameterSetName='Backup')]	
		[String]$BackupPath
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
    
    ## Test output Path
if(!(Test-Path $Output_Folder))
{
    New-Item -Path $Output_Folder -ItemType Directory | Out-Null
} 

## Extract Data
$GPOInfo= get-GPO -Name $GPOName
$Path = "\\" + $(Get-ADDomain).PDCEmulator.split(".")[0] + "\" + "SYSVOL\"+ $(Get-ADDomain).Forest + "\"+ "Policies\{" + $GPOInfo.Id+"}\"
$file=Get-ChildItem -path $path -File registry.pol -Recurse| ForEach-Object { $_.FullName }

        $ResolveGPO1 = Split-Path $file -Resolve
        $ResolveGPO1 = $ResolveGPO1.replace("Microsoft.PowerShell.Core\FileSystem::","")
        $GPOTitle = $GPOInfo.DisplayName
        $GPOCreate = $GPOInfo.CreationTime
        $GPOLastModif = $GPOInfo.ModificationTime
        $GPOStatus = $GPOInfo.GpoStatus

        if ($file -like "*Machine*")
        {
        $Script:FirstGPOScope = 'HKLM:\'
        }
        else
        {
            $Script:FirstGPOScope = 'HKCU:\'
        }

## End Extraction Data

## Parse GPO 

$ParseFirstGPO = Parse-PolFile $file |   Select-Object *,@{n='FullKey';e={'{0}{1}' -f "$Script:Scope",$_.KeyName +'\' +$_.ValueName}} 

## End Parse GPO 

## HTML Report with PSHTML
$css = 'body{background:#fcfcfc;font:87.5%/1.5em Lato,sans-serif;padding:15px}table{border-spacing:2px;border-collapse:collapse;background:#F7F6F6;border-radius:6px;overflow:hidden;max-width:800px;width:100%;margin:0 auto;position:relative}td,th{padding-left:8px}thead tr{height:32px;background:#33374e;color:#F5F6FA;font-size:1.1em;font-weight:700;text-transform:uppercase}tbody tr{height:48px;border-bottom:1px solid #367AB1;text-transform:capitalize;font-size:1em;&:last-child {;border:0}tr:nth-child(even){background-color:#E8E9E8}'
$filename = "Settings_"+$GPOName+".html" 
html {
    head {
        meta -charset 'UTF-8'
        meta -name 'author' -content "Jerome Bezet-Torres"
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
                div -Class "col"{ h1 -Class "text-left" "for $GPOName."
                }
            }
        }
        br{" "}
        div -class "container-fluid" {
            div -class "row" {
                div -Class "col"{}
                div -Class "col-8"{
                    div -Class "card border-dark mb-3" -Style "max-width: 55rem; margin-left:3rem; float: none;"{
            div -Class "card-header" -Style "font: 155% Lato,sans-serif;" {"Summary"}
            div -Class "card-body text-dark" {
                h5 -Class "card-title" {"Group Policy details"}
                p -Class "card-text" {
                    ul -Class "list-group list-group-flush" { 
                        li -Class "list-group-item d-flex justify-content-between align-items-center" {p -Style "margin-bottom: 0rem" {
                            b {"Name : "}
                            $GPOTitle}}
                        li -Class "list-group-item" { p -Style "margin-bottom: 0rem"{
                            b {"Description : "}
                            $($GPOInfo.Description)}}         
                        li -Class "list-group-item" { p -Style "margin-bottom: 0rem"{
                            b {"GPO was created the : "}
                            $GPOCreate }}
                        li -Class "list-group-item" { p -Style "margin-bottom: 0rem" {
                            b{"GPO lastmodified time : "} 
                            $GPOLastModif}}
                        li -Class "list-group-item" { p -Style "margin-bottom: 0rem"{
                            b{"GPO is located here :"} 
                            $ResolveGPO1}}
                        li -Class "list-group-item" { p -Style "margin-bottom: 0rem"{
                            b{"Setting are : "} 
                            $GPOStatus}}
                        li -Class "list-group-item" { p -Style "margin-bottom: 0rem"{ b{"Group Policy Container :"} 
                        $($GPOinfo.Path)}}
                        li -Class "list-group-item" { p -Style "margin-bottom: 0rem"{ b{"User version - Active Directory :"}
                        span -Class "badge badge-primary badge-pill"  -Style "margin-left: 0.5rem " { $($GPOInfo.User.DSVersion)}}}
                        li -Class "list-group-item" { p -Style "margin-bottom: 0rem"{ b{"User version - SYSVOL :"}
                        span -class  "badge badge-primary badge-pill" -Style "margin-left: 0.5rem " { $($GPOInfo.User.SysvolVersion)}}}
                        li -Class "list-group-item" { p -Style "margin-bottom: 0rem"{ b{"Computer version - Active Directory :"}
                        span -class  "badge badge-primary badge-pill" -Style "margin-left: 0.5rem " { $($GPOInfo.Computer.DSVersion)}}}
                        li -Class "list-group-item" { p -Style "margin-bottom: 0rem"{ b{"Computer version - SYSVOL :"}
                        span -class "badge badge-primary badge-pill" -Style "margin-left: 0.5rem " { $($GPOInfo.Computer.SysvolVersion)}}}
                        li -Class "list-group-item" {p -Style "margin-bottom: 0rem" {
                            b {"WMI : "}
                            $GPOInfo.WmiFilter}}
                        if ($CheckBackup){
                            
                            if(!(Test-Path $BackupPath))
                            {
                                Write-Warning "The backup path doesn't exist ! ! "
                            }
                            else{
                                $GPOName = $GPOTitle -replace " " ,"_"

                                $Subfolders = Get-ChildItem -Path $BackupPath\$GPOName -Directory
                                $BackupCount = $Subfolders.Count

                                $BackupDate =@()

                                foreach ($folder in $Subfolders.Name) {
                                
                                
                                    $Folder1  = $folder.Split("_")
                                    $NewFolder = $Folder1[0]+"\"+$Folder1[1]+"\"+$Folder1[2]
                                    
                                    $BackupDate += $NewFolder
                                }
                            }
                            
                            
                            li -Class "list-group-item" { p -Style "margin-bottom: 0rem"{ b{"Backup count :"}
                            span -class "badge badge-primary badge-pill" -Style "margin-left: 0.5rem " { $BackupCount}}}
                            li -Class "list-group-item" { p -Style "margin-bottom: 0rem"{
                                b{"Backup date : "} 
                                foreach ($date in $BackupDate){
                                    span -Style "margin-left: 0.5rem "  { "$date "}
                                }}}

                        }                     
                    }

                }
                small -Class "text-muted" -Style "margin-top: 1em;" { $(Get-Date)}
            }

        }
                }
                div -Class "col"{}
            }


        }
        
            div -Class "container-fluid" {

                div {
                    h5 -Class "text-center" "Registry key for the Group Policy Object $GPOTitle"
                    ConvertTo-PSHTMLtable -Object  $ParseFirstGPO  -properties FullKey,ValueType,ValueData -TableClass "table-primary"
                
                    }

                        
            }
    }
    footer {
        $PSHTMLlink = a {"PSHTML"} -href "https://github.com/Stephanevg/PSHTML"
        $JM2K69 = a {"JM2K69"} -href "https://twitter.com/JM2K69"
        $Blog = a {"Blog"} -href "https://jm2k69.github.io/"
        p{
            h6  "Generated with &#x2764 using $($PSHTMLlink) by $JM2K69 $(Get-Date) Copyright 2019 - $Blog "
        }
    }
    
}  | Out-File -FilePath "$Output_Folder\$filename" -Encoding utf8 -Force

if ($Launch)
{

    Start-Process $Output_Folder\$filename

}
