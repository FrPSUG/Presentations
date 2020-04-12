# Deploy Script

install-module -name  PowerShellGet -force -ErrorAction SilentlyContinue

import-module -name PowerShellGet

$StorageAccount = [Environment]::GetEnvironmentVariable('StorageAccount')
$ShareName = [Environment]::GetEnvironmentVariable('ShareName')

$ModuleName = [Environment]::GetEnvironmentVariable('ModuleName')

$SourceFolder = [Environment]::GetEnvironmentVariable('BUILD_SOURCESDIRECTORY')

$password = ConvertTo-SecureString -String $reposkey -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList "AZURE\$($StorageAccount)", $password
New-PSDrive -Name Z -PSProvider FileSystem -Root "\\$($StorageAccount).file.core.windows.net\$($ShareName)" -Credential $credential -Persist

$BuildFolder = join-path -path $SourceFolder  -childpath "Build"
$BuildModule = join-path -path $BuildFolder  -childpath $ModuleName



$repo = @{
    Name = 'AzureDevOpsRepos'
    SourceLocation = "z:"
    PublishLocation = "z:"
    InstallationPolicy = 'Trusted'
}
Register-PSRepository @repo


Publish-Module -Path $BuildModule -Repository AzureDevOpsRepos -Verbose