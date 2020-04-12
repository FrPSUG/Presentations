import-module AZ, arm-ttk

$ARMDir =  $Env:INPUT_DIRECTORY 



if (test-path -path $ARMDir) {

    

    if (($null -eq $Env:INPUT_DIRECTORY) -and (test-path -Path (join-path -Path $ARMDir -ChildPath "azuredeploy.json") -ErrorAction SilentlyContinue)) {

        Push-Location $TestsDir

        $TestResultArray = Test-AzTemplate -TemplatePath .

    }
    elseif (($null -ne $Env:INPUT_TEMPLATE) -and (test-path -Path (join-path -Path $ARMDir -ChildPath $Env:INPUT_TEMPLATE) -ErrorAction SilentlyContinue) ) {
        $TestResultArray= Test-AzTemplate -TemplatePath (join-path -Path $ARMDir -ChildPath $Env:INPUT_TEMPLATE)
    }
    else {
        throw "No azuredeploy.json file or template parameter in the $($ARMDir) folder"
        exit 1
    }

    if ($null -ne ($TestResultArray | Where-Object { -not $_.Passed })){

        Write-Output $TestResultArray | Where-Object { -not $_.Passed }

        throw "Error in Template"

    }

}
else {
    throw "Folder $($ARMDir) doesn't exit"
    exit 1
}







