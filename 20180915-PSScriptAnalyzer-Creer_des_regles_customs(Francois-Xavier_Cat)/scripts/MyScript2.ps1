<#
.SYNOPSIS
    Test script for PSScriptAnalyzer
#>
[CmdletBinding()]
param($File,$credential)
Try{
function QuickInventory{
param([string[]]$Computers)
$Computers|% -Proc {
if(Test-Connection $Comp -Quiet){
    gwmi `
    -class win32_ComputerSystem `
    -Cred $credential
}
}
}

function TestSomething{
Param()
#does nothing
}


QuickInventory -Comp (gc $File)
}catch{throw $_}