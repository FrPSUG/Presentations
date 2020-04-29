#List Registry value
Get-GPRegistryValue -Name "Laps_IT" -Key "HKLM\Software\Policies\Microsoft Services\AdmPwd"

#Add registry Value
<#Set-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\Task Scheduler5.0' -Name 'Allow Browse'
 -Value 1 -ea SilentlyContinue #>

 Set-GPRegistryValue -Name "LAPS_IT" -Key 'HKCU\Software\Policies\Microsoft\Windows\Task Scheduler5.0'`
 -ValueName 'Allow Browse' -Value 1 -Type Dword

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

Recurse-PolicyKeys -GPOName "Laps_IT" -Key "HKCU\Software"
