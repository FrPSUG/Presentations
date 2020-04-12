import-module AZ


$SpSecret = ConvertTo-SecureString  $env:INPUT_SPSECRET -AsPlainText -Force
$SpCredential = New-Object System.Management.Automation.PSCredential $env:INPUT_APPID,$SpSecret

Connect-AzAccount -Credential $SpCredential -Tenant $ENV:INPUT_TENANTID -Subscription $ENV:INPUT_SUBSCRIPTIONID -ServicePrincipal 

$ARMDir =  $Env:INPUT_DIRECTORY 

if (test-path -path $ARMDir) {

    

    if (($null -eq $Env:INPUT_TEMPLATE) -and (test-path -Path (join-path -Path $ARMDir -ChildPath "azuredeploy.json") -ErrorAction SilentlyContinue)) {

        $TemplatePath = join-path -Path $ARMDir -ChildPath "azuredeploy.json"

    }
    elseif (($null -ne $Env:INPUT_TEMPLATE) -and (test-path -Path (join-path -Path $ARMDir -ChildPath $Env:INPUT_TEMPLATE) -ErrorAction SilentlyContinue) ) {
        $TemplatePath = join-path -Path $ARMDir -ChildPath $Env:INPUT_TEMPLATE
    }
    else {
        throw "No azuredeploy.json file or template parameter in the $($ARMDir) folder"
        exit 1
    }

    $DeploymentName = "Github-" + (get-date -Format ddMMyyyyHHmm)

    New-AzResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $Env:INPUT_RESOURCEGROUP -TemplateFile $TemplatePath

}
else {
    throw "Folder $($ARMDir) doesn't exit"
    exit 1
}
