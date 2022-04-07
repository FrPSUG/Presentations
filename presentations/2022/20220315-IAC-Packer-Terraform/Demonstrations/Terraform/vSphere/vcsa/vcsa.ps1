Connect-VIServer -server sco-labo-vcsa.ad.supalta.com
$VM = Get-VM -Name "vcsa_ref"

$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.changeVersion = $VM.ExtensionData.Config.ChangeVersion
$spec.vAppConfig = New-Object VMware.Vim.VmConfigSpec

$properties = $vm.ExtensionData.Config.VAppConfig.Property
foreach ($prop in $properties) {
    $p = New-Object VMware.Vim.VAppPropertySpec
    $p.operation = "edit"
    $p.info = $prop
    $p.info.UserConfigurable = $True
    
    $spec.vAppConfig.property += $p
    }

$VM.ExtensionData.ReconfigVM_Task($spec)

$vm.ExtensionData.Config.VAppConfig.Property | Select {$_.id,$_.Value}