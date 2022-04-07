
Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force
Install-Module Winget  -Force -AllowClobber

Install-Package Git.Git -Provider Winget -Force