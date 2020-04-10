Clear-Host
#region <Admin or Not>
function IsAdmin
{
    $CurrentUser =
    [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.principal.windowsprincipal($CurrentUser)
    $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Personalized greeting
#
if (isAdmin)
{
    $ElevationMode = 'Administrator mode'
    $host.UI.RawUI.ForeGroundColor = 'DarkRed'
    $Host.UI.RawUI.WindowTitle = 'Administrator mode'
}
else
{
    $ElevationMode = 'Normal mode'
    #$host.UI.RawUI.BackGroundColor = 'DarkMagenta'
    $Host.UI.RawUI.WindowTitle = 'Normal mode'
}

$CurrentUser =
[System.Security.Principal.WindowsIdentity]::GetCurrent()

Write-Host '+---------------------------------------------------+'
Write-Host ("+- Hello {0} " -f ($CurrentUser.Name).split('\')[1])
Write-Host "+- You are logged in $ElevationMode"
Write-Host '+---------------------------------------------------+'
#endregion <Admin or Not>

$CredPath = $env:LOCALAPPDATA + "\Creds\" + $env:COMPUTERNAME + "\"

$private:AutoLoad = @{
    Modules = @(
        'ActiveDirectory',
        'AzureAD',
        'Plaster',
        'Psake',
        'PSDepend',
        'PSDeploy',
        'PANSIES',
        'PowerLine'
    )
    Creds   = @(
        @{
            name = 'CredUser';
            path = $($CredPath) + 'user.xml'
        },
        @{
            name = 'CredAdmin';
            path = $($CredPath) + 'admin.xml'
        },
        @{
            name = 'CredAdminO365';
            path = $($CredPath) + 'AdminO365.xml'
        }
    )
}

Foreach ($private:M in $AutoLoad.Modules)
{
    if (!(Get-Module -ListAvailable -Name $m))
    {
        Write-Warning "$($m) not found => installation launch "
        Install-Module -Name $m -AllowClobber -Force -ErrorAction SilentlyContinue -Scope CurrentUser
    }
}

#region <PsReadline>
#Automatically add the closing pair (the 4 works on PowerShell Core but not Windows PowerShell)
Set-PSReadLineKeyHandler -Chord '(', '{', '[', '"'  `
    -BriefDescription InsertPairedBraces `
    -LongDescription "Insert matching braces" `
    -ScriptBlock {
    param($key, $arg)

    $CloseChar = switch ($key.KeyChar)
    {
        '('
        {
            [char]')'; break
        }
        '{'
        {
            [char]'}'; break
        }
        '['
        {
            [char]']'; break
        }
        '"'
        {
            [char]'"'; break
        }

    }

    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($Key.KeyChar)$CloseChar")
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
}

#Following the above rule if manual closing of the closing pair does nothing is moved the cursor after
Set-PSReadLineKeyHandler -key ')', '}', ']' `
    -BriefDescription SmartClosesBraces `
    -LongDescription "Insert closing brace or skip" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null

    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -eq $key.KeyChar)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
    }
}
#endregion <PSReadLine>

if (!(Test-Path $CredPath))
{
    New-Item -Path $CredPath -ItemType Directory -Force -Confirm:$false
}

Foreach ($private:C in $AutoLoad.Creds)
{
    try
    {
        Set-Variable -Name $c.name -Value (Import-Clixml $c.Path) -Scope Global -Force
    }
    catch
    {
        Get-Credential -message "Compte et mot de passe utilisateur $($c.Name) ?" | Export-Clixml -Path $c.Path -Force
        Set-Variable -Name $c.name -Value (Import-Clixml $c.Path) -Scope Global -Force
    }
}

#region <Function>
function Connect-ExchangeOnline
{
    Write-Host "Connecting to Exchange Online..."

    $global:SessionEXO = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $CredAdminO365 -Authentication Basic -AllowRedirection

    Import-PSSession $global:SessionEXO -Prefix o365 -AllowClobber | Out-Null

    Write-Host ""
}

function Pop-GH
{
    [Alias('pgh')]
    [cmdletbinding()]
    param (
        [ValidateSet("Laurent", "FrPSUG", "lazywinadmin", "stephanevg", "omiossec")][string]$Account = "Laurent"
    )

    switch ($Account)
    {
        "laurent"
        {
            $uri = "https://github.com/LaurentLienhard"
        }
        "FrPSUG"
        {
            $uri = "https://github.com/FrPSUG"
        }
        "lazywinadmin"
        {
            $uri = "https://github.com/lazywinadmin"
        }
        "stephanevg"
        {
            $uri = "https://github.com/stephanevg"
        }
        "omiossec"
        {
            $uri = "https://github.com/omiossec"
        }
    }

    Start-Process $uri

}

function Open-Here
{
    [Alias('oph')]
    [CmdletBinding()]
    param (
    )

    explorer $pwd
}
#endregion <Function>

function prompt
{
    $fullpath = $ExecutionContext.SessionState.Path.CurrentLocation -split ('\\')
    $currentDirectory = $fullpath | Select-Object -Last 1
    $runTime = '[00:00:000]'
    $LastCmd = get-history -count 1
    if ($LastCmd)
    {
        $runTime = '[{0:mm\:ss\.fff}]' -f ($LastCmd.EndExecutionTime - $LastCmd.StartExecutionTime)
    }

    $arrows = '>'
    if ($NestedPromptLevel -gt 0)
    {
        $arrows = $arrows * $NestedPromptLevel
    }

    #Write-Host "$((get-Date).ToShortTimeString()) | " -ForegroundColor Yellow -NoNewline
    Write-Host "$runTime" -ForegroundColor Yellow -NoNewline
    Write-Host " | $currentDirectory$arrows" -NoNewline
    ' '
}