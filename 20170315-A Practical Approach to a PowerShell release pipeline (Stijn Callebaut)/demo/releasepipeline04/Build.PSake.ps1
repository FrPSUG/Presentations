# PSake makes variables declared here available in other scriptblocks
# Init some things
Properties {
    # Find the build folder based on build system
        $ProjectRoot = $ENV:BHProjectPath
        if(-not $ProjectRoot)
        {
            $ProjectRoot = $PSScriptRoot
        }

    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
    $lines = '----------------------------------------------------------------------'

    $Verbose = @{}
    if($ENV:BHCommitMessage -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }
    
    #VSTS specific: make variables task persistent
    
}

Task Default -Depends Deploy

Task Clean {
#clean all files
    #Remove-Item -Recurse -Force 
}

Task Init -Depends Clean {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}


Task Test -Depends Init  {
    $lines
    "`n`tSTATUS: Testing with PowerShell $PSVersion"

    # Gather test results. Store them in a variable and file
    $TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"
    # Failed tests?
    # Need to tell psake or it will proceed to the deployment. Danger!
    if($TestResults.FailedCount -gt 0)
    {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}

Task Build -Depends Test {
    $lines
    
    $scriptVersion = Test-ScriptFileInfo -Path $PSScriptRoot\script\script.ps1 
    # Bump the module version
    Try
    {
        $build = if($scriptVersion.version.Build -lt 0) {1} else {$scriptVersion.version.build + 1}
        $version = [version]::New($scriptVersion.version.Major, $scriptVersion.Version.Minor, $build)
        Update-ScriptFileInfo -Path $PSScriptRoot\script\script.ps1 -Version $version
    }
    Catch
    {
        "Failed to update version for '$env:BHProjectName': $_.`nContinuing with existing version"
    }
    
    Try {
        ## Update ChangeLog
        $Content = Get-Content "$ProjectRoot\CHANGELOG.md" | Select-Object -Skip 2
        $CommitMessage = git log --format=%B -n 1
        $NewContent = @('# Script Release History','',"## $($Version)", "### $(Get-Date -Format MM/dd/yyy)", @($CommitMessage),@($Content))
        $NewContent | Out-File -FilePath "$ProjectRoot\CHANGELOG.md" -Force -Encoding ascii
    
        # Update Release Notes
        update-scriptfileinfo -Path $PSScriptRoot\Script\script.ps1  -ReleaseNotes @(Get-Content -Path "$ProjectRoot\CHANGELOG.md") 
        
    }
    Catch {
        
        
    }
}

## todo: copy files to release folder
Task Deploy -Depends Build {
    
    
}