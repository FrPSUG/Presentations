# chaque type de données se script différement. KMO permet de le faire de façon simple
# https://github.com/KankuruSQL/KMO/blob/master/KDataType.cs

cls
# Connexion au serveur avec SMO
Import-Module 'C:\sources\cbs\sql-server-projects\sql-server-projects\Build\Tools\NugetSQL\lib\net40\Microsoft.SqlServer.Smo.dll'
Import-Module "C:\Sources\KMO\bin\Release\KMO.dll"
$serverName = 'localhost'
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
$db = $myServer.Databases['AdventureWorks2014']
$myTable = $db.Tables['ErrorLog', 'dbo']
$myTable



# selection d'une colonne
$myColumn = $myTable.Columns[6]
$myColumn

$myColumn.DataType


# scripting avec KMO
[KMO.KDataType]::ScriptToSql($myColumn.DataType)

