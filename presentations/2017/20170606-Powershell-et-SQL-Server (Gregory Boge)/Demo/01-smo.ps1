# 0 - Import DLL. 
# Il existe des nugets non officiel mais je n'en ai pas trouvé de Microsoft
# pensez à regarder les liens en commentaire dans le powerpoint
Import-Module 'C:\sources\cbs\sql-server-projects\sql-server-projects\Build\Tools\NugetSQL\lib\net40\Microsoft.SqlServer.Smo.dll'


# 1 - Connexion standard
$serverName = 'localhost'
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername



# 2 - Connexion SQL auth
$serverName = 'localhost'
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
$myServer.ConnectionContext.LoginSecure = $false
$myServer.ConnectionContext.Login = 'xxx'
$myServer.ConnectionContext.Password = 'xxx'



# 3 - informations du server (peut être long)
$myServer



# 4 Affichage bases de données
$myServer.Databases



# 5 Affichage noms bases de données
$myServer.Databases | Select-Object Name, CreateDate, Collation, DataSpaceUsage



# 6 navigation AdventureWorks
$myServer.Databases["AdventureWorks2014"].Tables | select-object Schema, Name, RowCount, DataSpaceUsed
$myServer.Databases["AdventureWorks2014"].Tables['Store', 'Sales']
$myServer.Databases["AdventureWorks2014"].Tables['Store', 'Sales'].Columns | Select-Object Name, DataType



# 7 Jobs
$myServer.JobServer.Jobs



# 8 Logins
cls
$myServer.Logins['sa']


