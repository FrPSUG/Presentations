cls
Import-Module 'C:\sources\cbs\sql-server-projects\sql-server-projects\Build\Tools\NugetSQL\lib\net40\Microsoft.SqlServer.Smo.dll'
Import-Module "C:\Sources\KMO\bin\Release\KMO.dll"

# Connexion au serveur avec SMO
$serverName = 'localhost'
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername


# on commence à travailler avec kmo pour comparer le schema de 2 tables
$db1 = $myServer.Databases['AdventureWorks2014']
$table1 = $db1.Tables['Demo', 'dbo']
$db2 = $myServer.Databases['AdventureWorksMeetup']
$table2 = $db2.Tables['Demo', 'dbo']
[KMO.KTable]::CompareSchema($table1, $table2) | Out-GridView






# on peut aussi travailler sur les données. Calcul d'un checksum
$db1 = $myServer.Databases['AdventureWorks2014']
$table1 = $db1.Tables['person', 'person']
[KMO.KTable]::DataChecksum($table1)





# Si on arrive à calculer un checksum des données d'une table, on peut comparer les données de 2 tables
$db1 = $myServer.Databases['AdventureWorks2014']
$table1 = $db1.Tables['demoData', 'dbo']
$db2 = $myServer.Databases['AdventureWorksMeetup']
$table2 = $db2.Tables['demoData', 'dbo']
[KMO.KTable]::CompareDataLight($table1, $table2)





# On peut meme avoir le détail
$db1 = $myServer.Databases['AdventureWorks2014']
$table1 = $db1.Tables['demoData', 'dbo']
$db2 = $myServer.Databases['AdventureWorksMeetup']
$table2 = $db2.Tables['demoData', 'dbo']
$dtRowAdded = New-Object system.Data.DataTable
$dtRowDeleted = New-Object system.Data.DataTable
$dtRowUpdated = New-Object system.Data.DataTable
[KMO.KTable]::CompareData($table1, $table2, [ref]$dtRowAdded, [ref]$dtRowDeleted, [ref]$dtRowUpdated, $true)
#$dtRowAdded
#$dtRowDeleted
$dtRowUpdated


# Verification 
$db1.ExecuteWithResults('SELECT * FROM dbo.demoData').tables[0] | Out-GridView
$db2.ExecuteWithResults('SELECT * FROM dbo.demoData').tables[0] | Out-GridView

