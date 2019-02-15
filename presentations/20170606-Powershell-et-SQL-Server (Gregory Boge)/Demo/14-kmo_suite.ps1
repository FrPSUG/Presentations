cls
Import-Module 'C:\sources\cbs\sql-server-projects\sql-server-projects\Build\Tools\NugetSQL\lib\net40\Microsoft.SqlServer.Smo.dll'
Import-Module "C:\Sources\KMO\bin\Release\KMO.dll"
$serverName = 'localhost'
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername


# les versions
$myServer.Version
[KMO.KServer]::VersionName($myServer)
[KMO.KServer]::VersionFull($myServer)


# les historiques de backups
[KMO.KServer]::GetBackupHistory($myServer) | Out-GridView
$db = $myServer.Databases['AdventureWorks2014']
[KMO.KDatabase]::GetBackupHistory($db) | Out-GridView


# Wait statistics
[KMO.KServer]::GetWaitStatistics($myServer) | Out-GridView


# Mémoire buffer
[KMO.KServer]::GetBufferByDatabase($myServer) | Out-GridView
$db = $myServer.Databases['AdventureWorks2014']
[KMO.KDatabase]::GetBufferStats($db) | Out-GridView


# CPU
[KMO.KServer]::GetCPUbyDatabase($myServer) | Out-GridView
[KMO.KServer]::GetCPUFromRing($myServer) | Out-GridView
# /!\ dm_os_ring_buffers n'est plus supporté



# Disks space and usage
[KMO.KServer]::GetIOStatistics($myServer) | Out-GridView
[KMO.KServer]::GetFileTreeMaps($myServer) | Out-GridView



# securité
[KMO.KServer]::GetWhoIsSa($myServer) | Out-GridView



# Audits 
[KMO.KDatabase]::GetLastAccessByTable($db) | Out-GridView
[KMO.KDatabase]::GetFKWithoutIndex($db) | Out-GridView
[KMO.KDatabase]::GetDuplicatedIndex($db) | Out-GridView    # exécution un peu plus longue
[KMO.KDatabase]::GetHeapIndex($db) | Out-GridView
[KMO.KDatabase]::GetTableWithoutPK($db) | Out-GridView
[KMO.KDatabase]::GetTableWithoutClusteredIndex($db) | Out-GridView
