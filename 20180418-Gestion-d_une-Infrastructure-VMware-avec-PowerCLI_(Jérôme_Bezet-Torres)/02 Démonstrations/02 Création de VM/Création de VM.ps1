
#region Création des VM
New-VM -Name FRPSUG_00001 -ResourcePool 192.168.0.30  

New-VM -Name FRPSUG_00002 `
      -DiskGB 80 `
      -DiskStorageFormat Thin `
      -MemoryGB 1 `
      -CD `
      -ResourcePool ("192.168.0.30") `
      -GuestId 'windows8Guest' `
      -NetworkName:"VM Network" `
      -Datastore ("LUN")`
  
 #Connection à un vCenter Obligatoire

$viObjVmHost = Get-VMHost -Name "192.168.0.30"

$viewObjEnvBrowser = Get-View -Id (Get-View -Id $viObjVmHost.ExtensionData.Parent).EnvironmentBrowser

$vmxVer = ($viewObjEnvBrowser.QueryConfigOptionDescriptor() | Where-Object {$_.DefaultConfigOption}).Key

$osDesc = $viewObjEnvBrowser.QueryConfigOption($vmxVer,$viObjVmHost.ExtensionData.MoRef).GuestOSDescriptor 
$osDesc | select Id,FullName 
$osDesc | select Id, FullName | where Id -Like cen*


15..45 | % {
  $name = "FRPSUG_{0:000000}" -f $_
  New-VM -Name $name `
      -DiskGB 8 `
      -DiskStorageFormat Thin `
      -MemoryGB 1 `
      -CD `
      -ResourcePool ("192.168.0.30") `
      -GuestId 'windows9Server64Guest' `
      -NetworkName:"VM Network" `
      -Datastore ("LUN") 
}



46..55 | % {
  $name = "FRPSUG_CLI_{0:000000}" -f $_
  New-VM -Name $name `
      -DiskGB 2 `
      -DiskStorageFormat Thin `
      -MemoryGB 1 `
      -CD `
      -ResourcePool ("192.168.0.30") `
      -GuestId 'windows9Server64Guest' `
      -NetworkName:"VM Network" `
      -Datastore ("LUN") 
        }


$datastore    = 'LUN'
$chemin       = 'ISO'
$Destination  = $(get-datastore -name $datastore).DatastoreBrowserPath
$iso          = "H:\iso\mu_system_center_configuration_manager_current_branch_version_1702_x86_x64_dvd_10325571.iso"
$IsoPath = "[$datastore]"+" "+$chemin+"\"+ "$(Split-Path $iso -Leaf)"

Copy-DatastoreItem $iso -Destination "$Destination\$chemin"

New-CDDrive -VM FRPSUG_00001 -IsoPath $IsoPath -StartConnected


#Import des ESXI avec VMware_Lab

#endregion  Création des VM

