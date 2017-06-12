#import de ScriptDom
Import-Module "C:\Sources\cbs\sql-server-projects\sql-server-projects\Build\Tools\dac\130\Microsoft.SqlServer.TransactSql.ScriptDom.dll"

# Parsing de la requête
# /!\ Scriptdom n'a aucune connaissance du modèle de base de données ni des données
$query = 'SELECT colonne1 , colonne2 FROM dbo.ErrorLogs WHERE errId = 1'
$reader = New-Object System.IO.StringReader($query)
$parser = new-object Microsoft.SqlServer.TransactSql.ScriptDom.TSql120Parser -ArgumentList $reader
[System.Collections.Generic.IList[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]]$parseErrors = New-Object -TypeName 'System.Collections.Generic.List[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]'
[Microsoft.SqlServer.TransactSql.ScriptDom.TSqlScript] $script = $parser.Parse($reader, [ref] $parseErrors)
$script


# et maintenant, on va naviguer dans les objets
$script.Batches
$script.Batches[0].Statements[0]
$script.Batches[0].Statements[0].GetType()

$script.Batches[0].Statements[0].QueryExpression

# SELECT
$script.Batches[0].Statements[0].QueryExpression.SelectElements
$script.Batches[0].Statements[0].QueryExpression.SelectElements[0].Expression.MultiPartIdentifier.Identifiers.value


# FROM
$script.Batches[0].Statements[0].QueryExpression.FromClause
$script.Batches[0].Statements[0].QueryExpression.FromClause.TableReferences
$script.Batches[0].Statements[0].QueryExpression.FromClause.TableReferences[0].SchemaObject.Identifiers


# WHERE
$script.Batches[0].Statements[0].QueryExpression.WhereClause.SearchCondition





# erreur de parsing
$query = 'SELECT colonne1 , colonne2 FROM dbo.ErrorLogs INNER JOIN table2 WHERE errId = 1'  # J'ai oublié volontairement la clause de jointure
$reader = New-Object System.IO.StringReader($query)
$parser = new-object Microsoft.SqlServer.TransactSql.ScriptDom.TSql120Parser -ArgumentList $reader
[System.Collections.Generic.IList[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]]$parseErrors = New-Object -TypeName 'System.Collections.Generic.List[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]'
[Microsoft.SqlServer.TransactSql.ScriptDom.TSqlScript] $script = $parser.Parse($reader, [ref] $parseErrors)
$parseErrors







# et si on reformattait du code sql ?
$query = 'WITH [BOM_cte] ( [ProductAssemblyID] , [ComponentID] , [ComponentDesc] , [PerAssemblyQty] , [StandardCost] , [ListPrice] , [BOMLevel] , [RecursionLevel] ) AS ( SELECT b.[ProductAssemblyID] , b.[ComponentID] , p.[Name] , b.[PerAssemblyQty] , p.[StandardCost] , p.[ListPrice] , b.[BOMLevel] , 0 FROM [Production].[BillOfMaterials] b INNER JOIN [Production].[Product] p ON b.[ComponentID] = p.[ProductID] WHERE b.[ProductAssemblyID] = @StartProductID AND @CheckDate >= b.[StartDate] AND @CheckDate <= ISNULL ( b.[EndDate] , @CheckDate ) UNION ALL SELECT b.[ProductAssemblyID] , b.[ComponentID] , p.[Name] , b.[PerAssemblyQty] , p.[StandardCost] , p.[ListPrice] , b.[BOMLevel] , [RecursionLevel] + 1 FROM [BOM_cte] cte INNER JOIN [Production].[BillOfMaterials] b ON b.[ProductAssemblyID] = cte.[ComponentID] INNER JOIN [Production].[Product] p ON b.[ComponentID] = p.[ProductID] WHERE @CheckDate >= b.[StartDate] AND @CheckDate <= ISNULL ( b.[EndDate] , @CheckDate ) ) SELECT b.[ProductAssemblyID] , b.[ComponentID] , b.[ComponentDesc] , SUM ( b.[PerAssemblyQty] ) AS [TotalQuantity] , b.[StandardCost] , b.[ListPrice] , b.[BOMLevel] , b.[RecursionLevel] FROM [BOM_cte] b GROUP BY b.[ComponentID] , b.[ComponentDesc] , b.[ProductAssemblyID] , b.[BOMLevel] , b.[RecursionLevel] , b.[StandardCost] , b.[ListPrice] ORDER BY b.[BOMLevel] , b.[ProductAssemblyID] , b.[ComponentID] OPTION ( MAXRECURSION 25 ) '
$reader = New-Object System.IO.StringReader($query)
$parser = new-object Microsoft.SqlServer.TransactSql.ScriptDom.TSql120Parser -ArgumentList $reader
[System.Collections.Generic.IList[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]]$parseErrors = New-Object -TypeName 'System.Collections.Generic.List[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]'
[Microsoft.SqlServer.TransactSql.ScriptDom.TSqlFragment] $script = $parser.Parse($reader, [ref] $parseErrors)
[Microsoft.SqlServer.TransactSql.ScriptDom.Sql120ScriptGenerator] $srcGen = New-Object -TypeName 'Microsoft.SqlServer.TransactSql.ScriptDom.Sql120ScriptGenerator'
$formattedSQL = ''
$srcGen.GenerateScript($script, [ref] $formattedSQL)
cls
$formattedSQL

# options
$srcGen.Options

