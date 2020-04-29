[CmdletBinding()]
Param(
		[Parameter(Mandatory=$true)]	
        [string]$BackupFolder
    )	
$AllGPOs = Get-GPO -All
foreach ($GPO in $AllGPOs) {
        $pattern = '[^a-zA-Z0-9\s]'
        $DisplayName = $GPO.DisplayName -replace " " ,"_"
        $ModificationTime = $GPO.ModificationTime -replace '[/:]','_'
        $ModificationTime = $ModificationTime -replace ' ','_'
        $BackupDestination = $BackupFolder+'\' + $DisplayName + '\' + $ModificationTime + '\'
        if (-Not (Test-Path $BackupDestination)) {
            New-Item -Path $BackupDestination -ItemType directory | Out-Null
            Backup-GPO -Name $GPO.DisplayName -Path $BackupDestination

        }
    }

