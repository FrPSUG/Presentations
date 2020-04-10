properties {
    $DeployType
}

task default -depends test


task Deploy -depends test {
    if ($null -eq $DeployType) {
        $DeployType = "DEV"
    }
    $ModuleName = "<%= $PLASTER_PARAM_ModuleName %>"
    Import-Module PSDeploy

    $source  =   $PSScriptRoot +'\..\Deploy\'+ $ModuleName +'.PSDeploy.ps1'

    Invoke-PSDeploy -Path $source -tag $DeployType -Force
}

task Test -depends compile {
    Write-Output "[TEST][START]"
    import-module pester
    start-sleep -seconds 2

    #Pester Tests
    write-verbose "invoking pester"
    $res = Invoke-Pester -Path "..\UnitTests" -OutputFormat NUnitXml -OutputFile ..\UnitTests\TestsResults.xml -PassThru #-CodeCoverage $TestFiles

    if ($res.FailedCount -gt 0 -or $res.PassedCount -eq 0) {
        throw "$($res.FailedCount) tests failed - $($res.PassedCount) successfully passed"
    };

    Write-Output "[TEST][END]"
}

task Compile -depends install,Clean {
    $ModuleName = "<%= $PLASTER_PARAM_ModuleName %>"
    $Author = "<%= $PLASTER_PARAM_AuthorName %>"
    $Manifest = ($ModuleName + ".psd1")

    Write-Output "[BUILD][START] Launching Build Process : $($ModuleName)"

    # Retrieve parent folder
    $Current = $PSScriptRoot
    $Root = ((Get-Item $Current).Parent).FullName
    $ModuleFolderPath = Join-Path -Path $Root -ChildPath $ModuleName
    $CodeSourcePath = Join-Path -Path $Root -ChildPath "Sources"
    $ExportPath = Join-Path -Path $ModuleFolderPath -ChildPath ($ModuleName + ".psm1")

    if (Test-Path $ExportPath) {
        Write-Output "[BUILD][PSM1] PSM1 file detected. Deleting..."
        Remove-Item -Path $ExportPath -Force
    }
    $DAte = Get-DAte
    "#Generated at $($Date) by $($Author)" | out-File -FilePath $ExportPath -Encoding utf8 -Append

    Write-Output "[BUILD][Code] Loading Enums, Class, public and private functions"

    $PublicEnums = Get-ChildItem -Path "$CodeSourcePath\Enums\" -Filter *.ps1 | sort-object Name
    $PublicClasses = Get-ChildItem -Path "$CodeSourcePath\Classes\" -Filter *.ps1 | sort-object Name
    $PrivateFunctions = Get-ChildItem -Path "$CodeSourcePath\Functions\Private" -Filter *.ps1
    $PublicFunctions = Get-ChildItem -Path "$CodeSourcePath\Functions\Public" -Filter *.ps1

    $MainPSM1Contents = @()
    $MainPSM1Contents += $PublicEnums
    $MainPSM1Contents += $PublicClasses
    $MainPSM1Contents += $PrivateFunctions
    $MainPSM1Contents += $PublicFunctions



    #Creating PSM1
    Write-Output "[BUILD][START][MAIN PSM1] Building main PSM1"
    Foreach ($file in $MainPSM1Contents) {
        Get-Content $File.FullName | out-File -FilePath $ExportPath -Encoding utf8 -Append

    }

    Write-Output "[BUILD][START][PSD1] Adding functions to export"

    $FunctionsToExport = $PublicFunctions.BaseName
    Copy-Item -Path $root\$Manifest -Destination $ModuleFolderPath\$Manifest
    $Manifest = Join-Path -Path $ModuleFolderPath -ChildPath $Manifest
    if ($FunctionsToExport -ne $null) {
        Update-ModuleManifest -Path $Manifest -FunctionsToExport $FunctionsToExport
    }

    Write-Output "[BUILD][END][MAIN PSM1] building main PSM1 "

    Write-Output "[BUILD][END]End of Build Process"
}

task Clean {
    Write-output "[CLEAN] START"
    Write-Output "[CLEAN] Suppress build module if exist"
    $ModuleName = "<%= $PLASTER_PARAM_ModuleName %>"
    $Current = $PSScriptRoot
    $Root = ((Get-Item $Current).Parent).FullName
    $ModuleFolderPath = Join-Path -Path $Root -ChildPath $ModuleName
    if (test-path -Path $ModuleFolderPath) {
        Write-Output "[CLEAN] Pre-build module find => Suppress"
        Remove-item -Path $ModuleFolderPath -force -recurse -confirm:$false
    }
    $null = New-Item -Path $ModuleFolderPath -ItemType Directory -Force -Confirm:$false
    Write-Output "[CLEAN] END"
}

task Install {
    Write-Output "[INSTALL] Start"
    Write-Output "[INSTALL] Install core modules"

    $listModule = "PSdeploy","Pester","PSake","PSScriptAnalyzer"
    foreach ($module in $ListModule) {
        if (!(Get-Module -ListAvailable -Name $module)) {
            Install-Module -Name $module -Scope CurrentUser -Confirm:$false -AllowClobber -Force
        }

    }
    Write-Output "[INSTALL] End"
}
