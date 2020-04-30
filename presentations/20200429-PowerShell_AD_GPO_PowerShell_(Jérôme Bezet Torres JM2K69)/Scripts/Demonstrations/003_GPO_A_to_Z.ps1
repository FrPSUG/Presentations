#Create One GPO with only Powershell

<#To facilitate the creation of group strategies with PowerShell an open source project 
created by Roger Zander [MVP] is available it is based on the ADMX administration 
files of the version of Windows 10 1903. The address is https://pspeditor.azurewebsites.net/#>

Start-Process https://pspeditor.azurewebsites.net/

New-GPO -Name "Disable Store" -Comment "Disable Store"

<#
Turn off the Store application

Description : Denies or allows access to the Store application.

If you enable this setting, access to the Store application is denied. Access to the Store is required for installing app updates.

If you disable or don't configure this setting, access to the Store application is allowed.

Set-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\WindowsStore' -Name 'RemoveWindowsStore' -Value 1 -ea SilentlyContinue 
#>


Set-GPRegistryValue -Name "Disable Store" -Key "HKCU\Software\Policies\Microsoft\WindowsStore" `
-ValueName "RemoveWindowsStore" -Value 1 -Type DWord

Get-GPRegistryValue -Name "Disable Store" -Key "HKCU\Software"

function Recurse-PolicyKeys{
    [CmdletBinding()]
    param(
      [Parameter(Mandatory=$true)]
      [string]$GPOName,
   
      [Parameter(Mandatory=$true)]
      [string]$Key
    )
    $current = Get-GPRegistryValue -Name $gpoName -Key $key
    foreach ($item in $current){
      if ($item.ValueName -ne $null){
      [array]$returnVal += $item 
    }
      else{
        Recurse-PolicyKeys -Key $item.fullkeypath -gpoName $gpoName
      }
    }
    return $returnVal
   }

Recurse-PolicyKeys -GPOName "Disable Store" -Key "HKCU\Software"

get-GPO -name "Disable Store" | New-GPLink "OU=London,OU=Sites,DC=PwSh,DC=loc" -LinkEnabled Yes

#Backup GPO

Backup-GPO -Name "Disable Store" -Path C:\backupGPO
Start-Process C:\backupGPO

#Backup with history

.\Scripts\BackupGPO.ps1 -BackupFolder C:\GPO_Backup
