cls
Import-Module 'C:\sources\cbs\sql-server-projects\sql-server-projects\Build\Tools\NugetSQL\lib\net40\Microsoft.SqlServer.Smo.dll'
$serverName = 'localhost'



# 1 - /!\ Démarrer le profiler


# 2 nom des bases et createDate
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
$myServer.Databases | Select-Object Name, CreateDate



# 2.1 nom des bases et createDate V2 - Je recrée la connexion au server pour éviter le cache
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
foreach($d in $myServer.Databases)
{
    Write-Host $d.Name : $d.CreateDate
}



# 2.2 nom des bases et createDate optimisé
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
$myServer.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], 'CreateDate')
$myServer.Databases | Select-Object Name, CreateDate




# 3 nom des bases et createDate + Collation
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
$myServer.Databases | Select-Object Name, CreateDate, Collation



# 3.1 nom des bases et createDate + Collation optimisé
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
$myServer.SetDefaultInitFields([Microsoft.SqlServer.Management.Smo.Database], 'CreateDate', 'Collation')
$myServer.Databases | Select-Object Name, CreateDate, Collation
