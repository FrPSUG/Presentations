function Set-MrVar {
    $PsProcess = Get-Process -Name PowerShell
}
function Set-MrVarLocal {
    $Local:PsProcess = Get-Process -Name PowerShell
}
function Set-MrVarScript {
    $Script:PsProcess = Get-Process -Name PowerShell
}
function Set-MrVarGlobal {
    $Global:PsProcess = Get-Process -Name PowerShell
}
function Test-MrVarScoping {
    if ($PsProcess) {
        Write-Output $PsProcess
    }
    else {
        Write-Warning -Message 'Variable $PsProcess not found!'
    }
}