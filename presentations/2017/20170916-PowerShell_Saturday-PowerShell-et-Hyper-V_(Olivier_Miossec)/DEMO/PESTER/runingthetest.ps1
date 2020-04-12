


$Date = Get-Date -Format ddMMyyyHHmmss
$reportFolder = 'c:\report\'
if (!(test-path $reportFolder))
{
    mkdir $reportFolder
}


Push-Location $reportFolder
$pesterxml = $reportFolder + "deploiresult_$Date.xml"
 

invoke-pester -Script integration.test.ps1 -OutputFile $pesterxml -OutputFormat NUnitXml


& C:\scripts\reportunit.exe $reportFolder

