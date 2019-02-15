#import de ScriptDom
Import-Module "C:\Sources\cbs\sql-server-projects\sql-server-projects\Build\Tools\dac\130\Microsoft.SqlServer.TransactSql.ScriptDom.dll"
Import-Module "C:\Users\g.boge\OneDrive - CRITEO\meetup powershell\Demo\ScriptDomMeetupExtension\ScriptDomMeetupExtension\bin\Debug\ScriptDomMeetupExtension.dll"
Import-Module 'C:\sources\cbs\sql-server-projects\sql-server-projects\Build\Tools\NugetSQL\lib\net40\Microsoft.SqlServer.Smo.dll'
Import-Module "C:\Sources\KMO\bin\Release\KMO.dll"


Function Get-AllChecksum{
  [CmdletBinding()]
  Param(
  [Parameter (Mandatory=$True)] [string] $servername
  , [Parameter (Mandatory=$True)] [string] $database
  , [Parameter (Mandatory=$True)] $listTables
)
  $checksums = @()
  foreach($t in $listTables)
  {
    $serverInstance = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $servername
    $smodb = $serverInstance.Databases[$database]
    $smotable = $smodb.Tables[$t.SchemaObject.BaseIdentifier.Value, $t.SchemaObject.SchemaIdentifier.Value]
    if($smotable -ne $null)
    {
      $kmochecksum = [KMO.KTable]::DataChecksum($smotable)
      $checksums += New-Object PSObject -Property @{
        table = $t
        checksum = $kmochecksum
      }
    }
  }
  return $checksums
}


# Parsing de la requête
$query = "update dbo.demoFinal SET name = 'ZZZ' WHERE id = 10"
$reader = New-Object System.IO.StringReader($query)
$parser = new-object Microsoft.SqlServer.TransactSql.ScriptDom.TSql120Parser -ArgumentList $reader
[System.Collections.Generic.IList[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]]$parseErrors = New-Object -TypeName 'System.Collections.Generic.List[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]'
[Microsoft.SqlServer.TransactSql.ScriptDom.TSqlScript] $script = $parser.Parse($reader, [ref] $parseErrors)

# je récupère la liste des tables du script
$listTables = [ScriptDomMeetupExtension.TSqlScriptExtension]::GetListUsedTableReference($script)

# je calcule le checksum de chaque table
$checksumBefore = Get-AllChecksum -servername 'localhost' -database 'AdventureWorks2014' -listTables $listTables

# Je joue le script de rollout
$serverInstance = New-Object ('Microsoft.SqlServer.Management.Smo.Server') 'localhost'
$smodb = $serverInstance.Databases['AdventureWorks2014']
$smodb.ExecuteNonQuery("update dbo.demoFinal SET name = 'ZZZ' WHERE id = 10")

# puis le rollback
$smodb.ExecuteNonQuery("update dbo.demoFinal SET name = 'XXX' WHERE id = 10")

# je recalcule le checksum de chaque table
$checksumAfter = Get-AllChecksum -servername 'localhost' -database 'AdventureWorks2014' -listTables $listTables

# je compare les objets
$diff = Compare-Object -ReferenceObject $checksumBefore -DifferenceObject $checksumAfter -Property table, checksum
foreach($d in $diff)
{
    $message = $d.table.SchemaObject.SchemaIdentifier.Value + '.' + $d.table.SchemaObject.BaseIdentifier.Value + ' : ' + $d.checksum
    Write-Error $message
}
if($diff.Count -eq 0)
{
    Write-Host 'Script OK'
}