cls
Import-Module 'C:\sources\cbs\sql-server-projects\sql-server-projects\Build\Tools\NugetSQL\lib\net40\Microsoft.SqlServer.Smo.dll'
$serverName = 'localhost'



# 1 - Execution d'une requete
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
$db = $myServer.Databases['AdventureWorks2014']

$dataSet = $db.ExecuteWithResults('select top 10 BusinessEntityId, Name, SalesPersonId, ModifiedDate from Sales.Store')
$dataSet.Tables[0]





# 2 - Execution d'une requete + Out-GridView
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
$db = $myServer.Databases['AdventureWorks2014']

$dataSet = $db.ExecuteWithResults('select top 100 * from Sales.Store')
$dataSet.Tables[0] | Out-GridView








# 3 - Execution d'une requete + Out-GridView
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
$db = $myServer.Databases['AdventureWorks2014']

$db.ExecuteNonQuery("INSERT INTO [dbo].[ErrorLog]
           ([ErrorTime]
           ,[UserName]
           ,[ErrorNumber]
           ,[ErrorSeverity]
           ,[ErrorState]
           ,[ErrorProcedure]
           ,[ErrorLine]
           ,[ErrorMessage])
     VALUES
           (GETDATE()
           ,'moi'
           ,666
           ,18
           ,5
           ,'procedure demo'
           ,12
           ,'c''est just un test!')")




# les problèmes

# 1 je n'ai pas trouvé comment récupérer le message de sortie alors que c'est simple en C#

# maConn.InfoMessage += new System.Data.SqlClient.SqlInfoMessageEventHandler(MaConnection_InfoMessage);
# $myServer.ConnectionContext.InfoMessage



# 2 le message d'erreur est plus chiant à remonter qu'avec d'autres systèmes d'accès aux données
$Error.Clear()
$myServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
$db = $myServer.Databases['AdventureWorks2014']
$db.ExecuteNonQuery("insert into Sales.Store(BusinessEntityId, Name, SalesPersonId, ModifiedDate) values (9999999, 'test', 3, GETDATE())")

$Error[0]
$Error[0].Exception.InnerException.InnerException.InnerException

# cette requete devrait me retourner le message d'erreur suivant :
# Msg 547, Level 16, State 0, Line 1
# The INSERT statement conflicted with the FOREIGN KEY constraint "FK_Store_BusinessEntity_BusinessEntityID". The conflict occurred in database "AdventureWorks2014", table "Person.BusinessEntity", column 'BusinessEntityID'.



