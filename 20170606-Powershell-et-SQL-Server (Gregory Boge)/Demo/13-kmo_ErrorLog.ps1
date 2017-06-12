
cls
# ErrorLog avec SMO
Import-Module 'C:\sources\cbs\sql-server-projects\sql-server-projects\Build\Tools\NugetSQL\lib\net40\Microsoft.SqlServer.Smo.dll'
Import-Module "C:\Sources\KMO\bin\Release\KMO.dll"
$serverName = 'localhost'
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
$myServer.ReadErrorLog() 
$myServer.ReadErrorLog(2)



# ErrorLog avec KMO
[KMO.KServer]::ReadErrorLog($myServer, [datetime]::Today.AddDays(-3), [datetime]::Now)
[KMO.KServer]::GetLoginFailed($myServer, [datetime]::Today.AddDays(-1), [datetime]::Now)



# ErrorLog complet avec les message d'informations avec KMO
# on peut aussi changer de fichier
[KMO.KServer]::ReadErrorLog($myServer, [datetime]::Today.AddDays(-3), [datetime]::Now, 0, $false) | Out-GridView

