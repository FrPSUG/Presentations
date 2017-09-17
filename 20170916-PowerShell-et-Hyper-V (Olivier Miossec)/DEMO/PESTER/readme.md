**simple.test.ps1**
Test simple

**integration.function.test.ps1**
Comment intégrer Pester dans une fonction. Cela peut être utile à la fin d'un test de déploiement. 
Mais les tests doivent être assez simple. 


**integration.test.ps1**
On utilise un fichier de données pour construire un tableau de hastable. 
Ce tableau de hastable permet d'envoyer des donnée à différents test. 

Un example plus simple

```powershell
describe "TestCase Test" {
    $cases = @{ Param1 = 1; Param2 = 1},@{ Param1 = 2; Param2 = 3},@{ Param1 = 2; Param2 = 2}
    it "Test if <Param1> Minus <Param2> equal 0" -TestCases $cases {
        param ( $Param1,$Param2 )
        $Param1 - $Param2 | should be 0
    }
}
```

le paramêtre testcases permet d'effectuer une boucle sur le IT à partir des données du tableau de hastable. 
A noter que les keys peuvent être affichées dans la description du IT avec <>.
Pour passer des données dans les test il faut utiliser param(). Les key du hastable peut être alors mise en variable


_Utilisatation de reportunit _

```powershell
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
```

ReportUnit demande un fichier au format NunitXML d'où le -outputformat NUnitXml 

il s'éxécute dans un dossier. 