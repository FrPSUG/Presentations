$PsReposNetPath = "\\PESTER-DB01\repos"

Register-PSRepository -name "InternalRepos" -SourceLocation $PsReposNetPath -PublishLocation $PsReposNetPath -InstallationPolicy Trusted



Publish-Module -Name MeetupTests -Repository InternalRepos -Verbose