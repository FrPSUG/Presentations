Get-PackageProvider -Name Nuget  -ForceBootstrap | Out-Null

Install-Module -Name Psake, PSDeploy, Pester, BuildHelpers -scope CurrentUser
install-Module -Name PsscriptAnalyzer -MaximumVersion 1.6.0 -Scope CurrentUser
Import-Module -Name Psake, PSDeploy, Pester, BuildHelpers, PsscriptAnalyzer

Set-BuildEnvironment -ErrorAction SilentlyContinue

Invoke-psake .\build.Psake.ps1
exit ( [int]( -not $psake.build_success))
