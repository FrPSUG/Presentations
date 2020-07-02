
foreach ($row in $results.properties.rows){
    write-host "Resource Group $($row[1]) Cost $($row[0])  Cur $($row[2])"
}