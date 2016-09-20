<#
    Parsing Data Using PowerShell \ Analyse syntaxique de données avec PowerShell
    -Francois-Xavier Cat-
#>

<##########################
#  DEMO 3 - Legacy Tools  #
##########################>
# Legacy tool - Example 1 (whoami.exe)

Whoami /?
# Groups
Whoami /groups /FO CSV | ConvertFrom-CSV | Ogv
#Privileges
Whoami /priv /FO CSV | ConvertFrom-CSV


# Legacy tools - Example 2 (Netstat)

# Gather the data
$netstat = netstat -n

# Parsing
$netstat[4..$netstat.count] |
ForEach-Object {

    # Current Line: Trim and split on whitespaces
    $NetStatLine = $_.trim() -split '\s+'
    
    # output powershell object
    new-object -TypeName Psobject -prop @{
        Protocol = $NetStatLine[0]
        LocalAddress = $NetStatLine[1]
        ForeignAddress = $NetStatLine[2]
        State = $NetStatLine[3]
    }
} | Out-Gridview


$netstat = netstat -no
$netstat[4..$netstat.count] |
ForEach-Object {

    # Current Line: Trim and split on whitespaces
    $NetStatLine = $_.trim() -split '\s+'
    
    # Process
    $Proc = (Get-process -id $NetStatLine[4] -IncludeUserName)

    # output powershell object
    new-object -TypeName Psobject -prop @{
        Protocol = $NetStatLine[0]
        LocalAddress = $NetStatLine[1]
        ForeignAddress = $NetStatLine[2]
        State = $NetStatLine[3]
        PID = $NetStatLine[4]
        ProcessName = $Proc.ProcessName
        UserName = $Proc.Username
    }
} | Out-Gridview