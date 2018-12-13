$Date = Get-Date -Format ddMMyyyHHmmss
$tempFolder = 'e:\reports\'
Push-Location $tempFolder
$XML = $tempFolder + "TestResults_$Date.xml"
$script = 'E:\demo\demo01\testinfra.ps1'
Invoke-Pester -Script $Script -OutputFile $xml -OutputFormat NUnitXml


$HTML = $tempFolder  + 'index.html'
& E:\demo\demo02\reportunit.exe $tempFolder







	