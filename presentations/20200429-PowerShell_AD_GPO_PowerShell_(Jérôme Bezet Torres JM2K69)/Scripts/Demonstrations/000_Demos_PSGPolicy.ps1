Import-Module E:\PsGPotools\PSGPOTools\PsGPotools.psm1

#List all commands 

get-command -Module PsGPotools

Initialize-PSGPOAdmx -UICulture 'en-US'

(Get-PSGPOPolicy -Scope Machine).count
(Get-PSGPOPolicy -Scope User).count

$Defender = Get-PSGPOPolicy -Scope Machine | ? {$_.Name -like "*Windows Defender*" -and $_.Registry.Key -like 'DisableAntispyware'}
$Defender.Registry
$Defender.Registry.Value
$Defender.Registry.Path

Get-Command -Module GroupPolicy
