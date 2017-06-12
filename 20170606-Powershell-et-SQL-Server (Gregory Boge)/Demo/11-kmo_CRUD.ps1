cls
# Connexion au serveur avec SMO
Import-Module 'C:\sources\cbs\sql-server-projects\sql-server-projects\Build\Tools\NugetSQL\lib\net40\Microsoft.SqlServer.Smo.dll'
Import-Module "C:\Sources\KMO\bin\Release\KMO.dll"
$serverName = 'localhost'
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
$db = $myServer.Databases['AdventureWorks2014']
$myTable = $db.Tables['Person', 'Person']




# création des scripts des procédures stockées
[KMO.KTable]::ScriptProcedureSelect($myTable)

[KMO.KTable]::ScriptProcedureUpdate($myTable)

[KMO.KTable]::ScriptProcedureInsert($myTable)

[KMO.KTable]::ScriptProcedureDelete($myTable)

[KMO.KTable]::ScriptProcedureList($myTable)

[KMO.KTable]::ScriptProcedureSelectWithTVP($myTable)




# avec une entete
$header = '/* Procedure generated with KMO */'
[KMO.KTable]::ScriptProcedureSelect($myTable, $header)




# scriptons les procédures CRUD de toute la base
foreach($t in $db.Tables)
{
    [KMO.KTable]::ScriptProcedureSelect($myTable, $header)
}

# $db.Tables.Count pour avoir le nombre de procédure stockées créées



