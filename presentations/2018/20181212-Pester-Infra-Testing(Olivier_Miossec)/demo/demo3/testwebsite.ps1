$session = New-PSSession -ComputerName pester-web01

$TestResultList = Invoke-Command -Session $session -ScriptBlock { Invoke-OperationValidation -IncludePesterOutput -ModuleName MeetupTests -TestType Simple }


foreach ($TestResult in $TestResultList) { 

    if ($TestResult.Result -eq "Failed") {

        write-host "Error in $($TestResult.Name)" -ForegroundColor Red

    }

}