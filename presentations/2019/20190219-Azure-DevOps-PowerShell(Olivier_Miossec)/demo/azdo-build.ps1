# Fill in custom build functions.
[cmdletbinding()]
param (
    [Parameter(Mandatory=$false)]
    [String]
    $SourceFolder = [Environment]::GetEnvironmentVariable('BUILD_SOURCESDIRECTORY'),

    [Parameter(Mandatory=$false)]
    [String]
    $ModuleName=[Environment]::GetEnvironmentVariable('ModuleName'),

    [Parameter(Mandatory=$false)]
    [String]
    $ModuleVersion=[Environment]::GetEnvironmentVariable('ModuleVersion')
    )

write-host "Where are we ? : Here $($SourceFolder)"

$moduleKey = [Environment]::GetEnvironmentVariable('ModuleKey')




write-host "ModuleKey value $($moduleKey) and reposkey is $($reposkey)"

write-host "Hi, I am your build agent. I will build the module $($ModuleName) version $($ModuleVersion)"



if ($modulename.Length -lt 1) {

    Exit-PSHostProcess
}

$BuildFolder = join-path -path $SourceFolder  -childpath "Build"

$BuildModulePath =  join-path -path $BuildFolder -ChildPath $ModuleName


$SourceFolder = join-path -path $SourceFolder  -childpath "$($ModuleName)"

write-host "Build path $($BuildFolder) and module path $($BuildModulePath)"

$PathSeparator = [IO.Path]::DirectorySeparatorChar


if (Test-Path $BuildFolder) {
    Remove-Item -Path $BuildFolder -Force -Recurse -Confirm:$false
}

new-item -Path $BuildFolder -ItemType Directory

new-item -Path $BuildModulePath -ItemType Directory



# Creating Modle path
$BuildModuleFile = Join-Path -Path $BuildModulePath -ChildPath "$($ModuleName).psm1"
$BuildModuleManifest = Join-Path -Path $BuildModulePath -ChildPath "$($ModuleName).psd1"
$SourceMouduleManifest = Join-Path -Path $SourceFolder -ChildPath "$($ModuleName).psd1"


Copy-Item -Path $SourceMouduleManifest -Destination $BuildModuleManifest -Force



$PublicFunctionsList = Get-ChildItem -Path "$($ModuleName)$($PathSeparator)Public" -Filter *.ps1

$AllFunctions = Get-ChildItem -Path $SourceFolder -Include 'Public', 'External' -Recurse -Directory | Get-ChildItem -Include *.ps1 -File

new-item -Path $BuildModuleFile -ItemType File

if ($AllFunctions) {
    Foreach ($Function in $AllFunctions) {
        Get-Content -Path $AllFunctions.FullName | Add-Content -Path $BuildModuleFile
    }
}


Update-ModuleManifest -Path $BuildModuleManifest -FunctionsToExport $PublicFunctionsList.BaseName

Update-ModuleManifest -Path $BuildModuleManifest -ModuleVersion $ModuleVersion

install-module -name pester -force -AllowClobber -Scope CurrentUser


