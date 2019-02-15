cls
Import-Module 'C:\sources\cbs\sql-server-projects\sql-server-projects\Build\Tools\NugetSQL\lib\net40\Microsoft.SqlServer.Smo.dll'
$serverName = 'localhost'



# 1 - index reorg
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
$db = $myServer.Databases['AdventureWorks2014']
foreach($t in $db.Tables)
{
    foreach($i in $t.indexes)
    {
        Write-Host reorg $i.Name in progress...
        $i.Reorganize()
        #$i.EnumFragmentation()
    }
}


# autre exemple FileGroup Migrator de Kankuru



