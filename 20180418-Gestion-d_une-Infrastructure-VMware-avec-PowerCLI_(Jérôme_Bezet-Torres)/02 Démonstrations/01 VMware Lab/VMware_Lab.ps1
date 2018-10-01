############################################################
#  Author : Jérôme Bezet-Torres                            #
#  Date : Avril 2018                                       #
#  vSphere 6.5 : Nested Deployement Lab                    #
#  Version 1.2                                             #
#  Twitter : @JM2K69                                       #
#  Blog : https://jm2k69.github.io                         #
#  Next major Update => WPF and XAML PowerShell            #
############################################################        
####################### Fonctions ##########################
function New-ConfNestedExsi
{
    [CmdletBinding()]
    
    [CmdletBinding()]
    param(
    [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
    [String[]]$Name,
    [Parameter(Mandatory=$true)]
    [ValidateScript({$_ -match [IPAddress]$_ })]
    [String[]]$IpESXI,
    [Int]$Number
    )
    
    Begin
    {
     $global:NestedConfESXI =[ordered] @{}
                    
            if ($Number -gt 3)
             {
                $ESXINumber = "1"
             }
            else {
         
            if ($Name.count -eq $IpESXI.count)
            { }
            else
             {
            Write-Warning "Error. Verify they are not the same number of parameter for Name and IpESXI"
            break
            }
        }
    
    }
    Process
    {
        if ($ESXINumber -eq "1")
            {
            
                $Next=($Name[2].substring(0,$Name[2].length -1))
                          
                for ($i = 0; $i -lt $Name.count; $i++)
                {
                
                $global:NestedConfESXI.add($Name[$i],$IpESXI[$i])
                
                }
               
                
                for ($i = 4; $i -le $Number; $i++)
                {
                $ip = $IpESXI[2]
                $SplitIP = $ip.Split(".")
                [INT]$forOctect =$SplitIP[3]
                $forOctect =$forOctect + $i - $Number + 1
                $newip = -join($SplitIP[0], ".", $SplitIP[1],".",$SplitIP[2],".",$forOctect);
                $namef = $next + $i
                
                $global:NestedConfESXI.add($Namef,$newip)
                
                }


            }

        else 
        {
              for ($i = 0; $i -lt $Name.count; $i++)
            { 
          
              $global:NestedConfESXI.add($Name[$i],$IpESXI[$i])

             }
        }
    }


    End
    {
        

    }

}
Function New-Logtrace 
{
    param(
    [Parameter(Mandatory=$true)]
    [String]$message
    )

    $timeStamp = Get-Date -Format "MM-dd-yyyy/%H:mm:ss"

    Write-Host -NoNewline -ForegroundColor Gray "[$timestamp]"
    Write-Host -ForegroundColor Green " $message"
    $logMessage = "{$timeStamp} $message"
    $logMessage | Out-File -Append -LiteralPath $verboseLogFile
}

####################### Fin des fonctions ##################
####################### Variables ##########################
$VIServer = "192.168.0.30"#"192.168.0.110" # @IP ou DNS
$VIUsername ="root" #"Administrator@vsphere.local"
$VIPassword = "123+aze" #123456+Aze"

# Use either ESXI or VCENTER
$DeploymentTarget = "ESXI" #"VCENTER"

# Full Path to both the Nested ESXi 6.5 VA + extracted VCSA 6.5 ISO Thx to William Lam for ESXI Appliance 
# https://www.virtuallyghetto.com/2017/05/updated-nested-esxi-6-0u3-6-5d-virtual-appliances.html
# Link https://download3.vmware.com/software/vmw-tools/nested-esxi/Nested_ESXi6.5u1_Appliance_Template_v1.0.ova 
$NestedESXiAppliance = "C:\VMware\ESXI\Nested_ESXi6.5u1_Appliance_Template_v1.0.ovf"
$VCSAInstallerPath = "C:\VMware\VCSA"

New-ConfNestedExsi -Name "N_esxi1","N_esxi2","N_esxi3" -IpESXI 192.168.0.120,192.168.0.121,192.168.0.122 -Number 4

# Ressources pour les ESXIs
$NestedESXivCPU = "2"
$NestedESXivMEM = "8" #GB
$NestedESXiCachingvDisk = "4" #GB
$NestedESXiCapacityvDisk = "32" #GB
$VMSSH = "true" # Activation de SSH pour les ESXI
$VMVMFS = "true" # création au nom d'un stockage local NFS


# Vcenter VCSA configurations 
$VCSADeploymentSize = "tiny"
$VCSADisplayName = "vcsa"
$VCSAIPAddress = "192.168.0.210"
$VCSAHostname = "192.168.0.210" #Possibilité d'ajouter avec un nom DNS
$VCSAPrefix = "24"
$VCSASSODomainName = "JM2K69.Posh"
$VCSASSOSiteName = "JM2K69"
$VCSASSOPassword = "VMware1!"
$VCSARootPassword = "VMware1!"
$VCSASSHEnable = "true"

# Configurations commun  aux ESXi et VCSA
$VirtualSwitchType = "VSS" # VSS or VDS type de switchs Standard ou Distribués
$VMNetwork = "JM2K69"
$VMDatastore = "LUN"
$VMNetmask = "255.255.255.0"
$VMGateway = "192.168.0.1"
$VMDNS = "1.1.1.1"
$VMNTP = "pool.ntp.org"
$VMPassword = "VMware1!"
$VMDomain = "JM2K69.Posh"
$VMSyslog = "172.30.0.170"
$VMCluster = "Cluster" # nom du Cluster dans lequel le vApp va etre crée.
$NewVCDatacenterName = "vSphere-Lab" # Nom du Datacenter dans le nouveau VCSA deployé.
$NewVCVSANClusterName = "VSAN-Cluster"

$addHostByDnsName = 0 # Mettre à 1 si une infra DNS est disponnible attention ZRD et ZRI pour les ESXIs

####################### Ne pas modifier Après #######################

$verboseLogFile = "VMware-lab.log"
$vSphereVersion = "6.5"
$deploymentType = "Standard"
$random_string = -join ((65..90) + (97..122) | Get-Random -Count 5 | ForEach-Object {[char]$_})
$VAppName = "Nested-vSphere-Lab-$vSphereVersion-$random_string"

$vcsaSize2MemoryStorageMap = @{
"tiny"=@{"cpu"="2";"mem"="10";"disk"="250"};
"small"=@{"cpu"="4";"mem"="16";"disk"="290"};
"medium"=@{"cpu"="8";"mem"="24";"disk"="425"};
"large"=@{"cpu"="16";"mem"="32";"disk"="640"};
"xlarge"=@{"cpu"="24";"mem"="48";"disk"="980"}
}

$esxiTotalCPU = 0
$vcsaTotalCPU = 0
$esxiTotalMemory = 0
$vcsaTotalMemory = 0
$vcsaTotalStorage = 0
$esxiTotalStorage = 0

$preCheck = 1
$confirmDeployment = 1
$deployNestedESXiVMs = 1
$deployVCSA = 0 # for deploy Only ESXI
$setupNewVC = 0 # for deploy Only ESXI
$addESXiHostsToVC = 1
$configureVSANDiskGroups = 1
$clearVSANHealthCheckAlarm = 1
$moveVMsIntovApp = 1

$StartTime = Get-Date

if($preCheck -eq 1) {
    if(!(Test-Path $NestedESXiAppliance)) {
        Write-Host -ForegroundColor Red "`nUnable to find $NestedESXiAppliance ...`nexiting"
        exit
    }

    if(!(Test-Path $VCSAInstallerPath)) {
        Write-Host -ForegroundColor Red "`nUnable to find $VCSAInstallerPath ...`nexiting"
        exit
    }
    
}

if($confirmDeployment -eq 1) {
    Write-Host -ForegroundColor Magenta "`nPlease confirm the following configuration will be deployed:`n"

    Write-Host -ForegroundColor Yellow "---- Nested VMware vCenter Lab @JM2K69 ---- "
    Write-Host -NoNewline -ForegroundColor Green "Deployment Target: "
    Write-Host -ForegroundColor White $DeploymentTarget
    Write-Host -NoNewline -ForegroundColor Green "Deployment Type: "
    Write-Host -ForegroundColor White $deploymentType
    Write-Host -NoNewline -ForegroundColor Green "vSphere Version: "
    Write-Host -ForegroundColor White  "vSphere $vSphereVersion"
    Write-Host -NoNewline -ForegroundColor Green "Nested ESXi Image Path: "
    Write-Host -ForegroundColor White $NestedESXiAppliance
    Write-Host -NoNewline -ForegroundColor Green "VCSA Image Path: "
    Write-Host -ForegroundColor White $VCSAInstallerPath

    
    if($DeploymentTarget -eq "ESXI") {
        Write-Host -ForegroundColor Yellow "`n---- Physical ESXi Deployment Target Configuration ----"
        Write-Host -NoNewline -ForegroundColor Green "ESXi Address: "
    } else {
        Write-Host -ForegroundColor Yellow "`n---- vCenter Server Deployment Target Configuration ----"
        Write-Host -NoNewline -ForegroundColor Green "vCenter Server Address: "
    }

    Write-Host -ForegroundColor White $VIServer
    Write-Host -NoNewline -ForegroundColor Green "Username: "
    Write-Host -ForegroundColor White $VIUsername
    Write-Host -NoNewline -ForegroundColor Green "VM Network: "
    Write-Host -ForegroundColor White $VMNetwork

   
    Write-Host -NoNewline -ForegroundColor Green "VM Storage: "
    Write-Host -ForegroundColor White $VMDatastore

    if($DeploymentTarget -eq "VCENTER") {
        Write-Host -NoNewline -ForegroundColor Green "VM Cluster: "
        Write-Host -ForegroundColor White $VMCluster
        Write-Host -NoNewline -ForegroundColor Green "VM vApp: "
        Write-Host -ForegroundColor White $VAppName
    }

    Write-Host -ForegroundColor Yellow "`n---- Nested ESXi Configuration ----"
    Write-Host -NoNewline -ForegroundColor Green "# of Nested ESXi VMs: "
    Write-Host -ForegroundColor White $global:NestedConfESXI.count
    Write-Host -NoNewline -ForegroundColor Green "vCPU: "
    Write-Host -ForegroundColor White $NestedESXivCPU
    Write-Host -NoNewline -ForegroundColor Green "vMEM: "
    Write-Host -ForegroundColor White "$NestedESXivMEM GB"
    Write-Host -NoNewline -ForegroundColor Green "Caching VMDK: "
    Write-Host -ForegroundColor White "$NestedESXiCachingvDisk GB"
    Write-Host -NoNewline -ForegroundColor Green "Capacity VMDK: "
    Write-Host -ForegroundColor White "$NestedESXiCapacityvDisk GB"
    Write-Host -NoNewline -ForegroundColor Green "IP Address(s): "
    Write-Host -ForegroundColor White $global:NestedConfESXI.Values
    Write-Host -NoNewline -ForegroundColor Green "Netmask "
    Write-Host -ForegroundColor White $VMNetmask
    Write-Host -NoNewline -ForegroundColor Green "Gateway: "
    Write-Host -ForegroundColor White $VMGateway
    Write-Host -NoNewline -ForegroundColor Green "DNS: "
    Write-Host -ForegroundColor White $VMDNS
    Write-Host -NoNewline -ForegroundColor Green "NTP: "
    Write-Host -ForegroundColor White $VMNTP
    Write-Host -NoNewline -ForegroundColor Green "Syslog: "
    Write-Host -ForegroundColor White $VMSyslog
    Write-Host -NoNewline -ForegroundColor Green "Enable SSH: "
    Write-Host -ForegroundColor White $VMSSH
    Write-Host -NoNewline -ForegroundColor Green "Create VMFS Volume: "
    Write-Host -ForegroundColor White $VMVMFS
    Write-Host -NoNewline -ForegroundColor Green "Root Password: "
    Write-Host -ForegroundColor White $VMPassword
if ($deployVCSA -eq 1){
    Write-Host -ForegroundColor Yellow "`n---- VCSA Configuration ----"
    Write-Host -NoNewline -ForegroundColor Green "Deployment Size: "
    Write-Host -ForegroundColor White $VCSADeploymentSize
    Write-Host -NoNewline -ForegroundColor Green "SSO Domain: "
    Write-Host -ForegroundColor White $VCSASSODomainName
    Write-Host -NoNewline -ForegroundColor Green "SSO Site: "
    Write-Host -ForegroundColor White $VCSASSOSiteName
    Write-Host -NoNewline -ForegroundColor Green "SSO Password: "
    Write-Host -ForegroundColor White $VCSASSOPassword
    Write-Host -NoNewline -ForegroundColor Green "Root Password: "
    Write-Host -ForegroundColor White $VCSARootPassword
    Write-Host -NoNewline -ForegroundColor Green "Enable SSH: "
    Write-Host -ForegroundColor White $VCSASSHEnable
    Write-Host -NoNewline -ForegroundColor Green "Hostname: "
    Write-Host -ForegroundColor White $VCSAHostname
    Write-Host -NoNewline -ForegroundColor Green "IP Address: "
    Write-Host -ForegroundColor White $VCSAIPAddress
    Write-Host -NoNewline -ForegroundColor Green "Netmask "
    Write-Host -ForegroundColor White $VMNetmask
    Write-Host -NoNewline -ForegroundColor Green "Gateway: "
    Write-Host -ForegroundColor White $VMGateway
}

    $esxiTotalCPU = $global:NestedConfESXI.count * [int]$NestedESXivCPU
    $esxiTotalMemory = $global:NestedConfESXI.count * [int]$NestedESXivMEM
    $esxiTotalStorage = ($global:NestedConfESXI.count * [int]$NestedESXiCachingvDisk) + ($global:NestedConfESXI.count * [int]$NestedESXiCapacityvDisk)
    $vcsaTotalCPU = $vcsaSize2MemoryStorageMap.$VCSADeploymentSize.cpu
    $vcsaTotalMemory = $vcsaSize2MemoryStorageMap.$VCSADeploymentSize.mem
    $vcsaTotalStorage = $vcsaSize2MemoryStorageMap.$VCSADeploymentSize.disk

    Write-Host -ForegroundColor Yellow "`n---- Resource Requirements ----"
    Write-Host -NoNewline -ForegroundColor Green "ESXi VM CPU: "
    Write-Host -NoNewline -ForegroundColor White $esxiTotalCPU
    Write-Host -NoNewline -ForegroundColor Green " ESXi VM Memory: "
    Write-Host -NoNewline -ForegroundColor White $esxiTotalMemory "GB "
    Write-Host -NoNewline -ForegroundColor Green "ESXi VM Storage: "
    Write-Host -ForegroundColor White $esxiTotalStorage "GB"
    Write-Host -NoNewline -ForegroundColor Green "VCSA VM CPU: "
    Write-Host -NoNewline -ForegroundColor White $vcsaTotalCPU
    Write-Host -NoNewline -ForegroundColor Green " VCSA VM Memory: "
    Write-Host -NoNewline -ForegroundColor White $vcsaTotalMemory "GB "
    Write-Host -NoNewline -ForegroundColor Green "VCSA VM Storage: "
    Write-Host -ForegroundColor White $vcsaTotalStorage "GB"

    Write-Host -ForegroundColor White "---------------------------------------------"
    Write-Host -NoNewline -ForegroundColor Green "Total CPU: "
    Write-Host -ForegroundColor White ($esxiTotalCPU + $vcsaTotalCPU + $nsxTotalCPU)
    Write-Host -NoNewline -ForegroundColor Green "Total Memory: "
    Write-Host -ForegroundColor White ($esxiTotalMemory + $vcsaTotalMemory + $nsxTotalMemory) "GB"
    Write-Host -NoNewline -ForegroundColor Green "Total Storage: "
    Write-Host -ForegroundColor White ($esxiTotalStorage + $vcsaTotalStorage + $nsxTotalStorage) "GB"

    Write-Host -ForegroundColor Magenta "`nWould you like to proceed with this deployment?`n"
    $answer = Read-Host -Prompt "Do you accept (Y or N)"
    if($answer -ne "Y" -or $answer -ne "y") {
        exit
    }
    Clear-Host
}

New-Logtrace "Connecting to $VIServer ..."
$viConnection = Connect-VIServer $VIServer -User $VIUsername -Password $VIPassword -WarningAction SilentlyContinue

if($DeploymentTarget -eq "ESXI") {
    $datastore = Get-Datastore -Server $viConnection -Name $VMDatastore
    if($VirtualSwitchType -eq "VSS") {
        $network = Get-VirtualPortGroup -Server $viConnection -Name $VMNetwork
        
    } else {
        $network = Get-VDPortgroup -Server $viConnection -Name $VMNetwork
       
    }
    $vmhost = Get-VMHost -Server $viConnection

    if($datastore.Type -eq "vsan") {
        New-Logtrace "VSAN Datastore detected, enabling Fake SCSI Reservations ..."
        Get-AdvancedSetting -Entity $vmhost -Name "VSAN.FakeSCSIReservations" | Set-AdvancedSetting -Value 1 -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
    }
} else {
    $datastore = Get-Datastore -Server $viConnection -Name $VMDatastore | Select -First 1
    if($VirtualSwitchType -eq "VSS") {
        $network = Get-VirtualPortGroup -Server $viConnection -Name $VMNetwork | Select -First 1
        
    } else {
        $network = Get-VDPortgroup -Server $viConnection -Name $VMNetwork | Select -First 1
        
    }
    $cluster = Get-Cluster -Server $viConnection -Name $VMCluster
    $datacenter = $cluster | Get-Datacenter
    $vmhost = $cluster | Get-VMHost | Select -First 1

    if($datastore.Type -eq "vsan") {
        New-Logtrace "VSAN Datastore detected, enabling Fake SCSI Reservations ..."
        Get-AdvancedSetting -Entity $vmhost -Name "VSAN.FakeSCSIReservations" | Set-AdvancedSetting -Value 1 -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
    }
}

if($deployNestedESXiVMs -eq 1) {
    if($DeploymentTarget -eq "ESXI") {
        $global:NestedConfESXI.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
            $VMName = $_.Key
            $VMIPAddress = $_.Value

            New-Logtrace "Deploying Nested ESXi VM $VMName ..."
            $vm = Import-VApp -Server $viConnection -Source $NestedESXiAppliance -Name $VMName -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin

            
            New-Logtrace "Correcting missing dvFilter settings for Eth1 ..."
            $vm | New-AdvancedSetting -name "ethernet1.filter4.name" -value "dvfilter-maclearn" -confirm:$false -ErrorAction SilentlyContinue | Out-File -Append -LiteralPath $verboseLogFile
            $vm | New-AdvancedSetting -Name "ethernet1.filter4.onFailure" -value "failOpen" -confirm:$false -ErrorAction SilentlyContinue | Out-File -Append -LiteralPath $verboseLogFile

            New-Logtrace "Updating VM Network ..."
            $vm | Get-NetworkAdapter -Name "Network adapter 1" | Set-NetworkAdapter -Portgroup $network -confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
            sleep 5
           
            $vm | Get-NetworkAdapter -Name "Network adapter 2" | Set-NetworkAdapter -Portgroup $network -confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
            

            New-Logtrace "Updating vCPU Count to $NestedESXivCPU & vMEM to $NestedESXivMEM GB ..."
            Set-VM -Server $viConnection -VM $vm -NumCpu $NestedESXivCPU -MemoryGB $NestedESXivMEM -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile

            New-Logtrace "Updating vSAN Caching VMDK size to $NestedESXiCachingvDisk GB ..."
            Get-HardDisk -Server $viConnection -VM $vm -Name "Hard disk 2" | Set-HardDisk -CapacityGB $NestedESXiCachingvDisk -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile

            New-Logtrace "Updating vSAN Capacity VMDK size to $NestedESXiCapacityvDisk GB ..."
            Get-HardDisk -Server $viConnection -VM $vm -Name "Hard disk 3" | Set-HardDisk -CapacityGB $NestedESXiCapacityvDisk -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile

            $orignalExtraConfig = $vm.ExtensionData.Config.ExtraConfig
            $a = New-Object VMware.Vim.OptionValue
            $a.key = "guestinfo.hostname"
            $a.value = $VMName
            $b = New-Object VMware.Vim.OptionValue
            $b.key = "guestinfo.ipaddress"
            $b.value = $VMIPAddress
            $c = New-Object VMware.Vim.OptionValue
            $c.key = "guestinfo.netmask"
            $c.value = $VMNetmask
            $d = New-Object VMware.Vim.OptionValue
            $d.key = "guestinfo.gateway"
            $d.value = $VMGateway
            $e = New-Object VMware.Vim.OptionValue
            $e.key = "guestinfo.dns"
            $e.value = $VMDNS
            $f = New-Object VMware.Vim.OptionValue
            $f.key = "guestinfo.domain"
            $f.value = $VMDomain
            $g = New-Object VMware.Vim.OptionValue
            $g.key = "guestinfo.ntp"
            $g.value = $VMNTP
            $h = New-Object VMware.Vim.OptionValue
            $h.key = "guestinfo.syslog"
            $h.value = $VMSyslog
            $i = New-Object VMware.Vim.OptionValue
            $i.key = "guestinfo.password"
            $i.value = $VMPassword
            $j = New-Object VMware.Vim.OptionValue
            $j.key = "guestinfo.ssh"
            $j.value = $VMSSH
            $k = New-Object VMware.Vim.OptionValue
            $k.key = "guestinfo.createvmfs"
            $k.value = $VMVMFS
            $l = New-Object VMware.Vim.OptionValue
            $l.key = "ethernet1.filter4.name"
            $l.value = "dvfilter-maclearn"
            $m = New-Object VMware.Vim.OptionValue
            $m.key = "ethernet1.filter4.onFailure"
            $m.value = "failOpen"
            $orignalExtraConfig+=$a
            $orignalExtraConfig+=$b
            $orignalExtraConfig+=$c
            $orignalExtraConfig+=$d
            $orignalExtraConfig+=$e
            $orignalExtraConfig+=$f
            $orignalExtraConfig+=$g
            $orignalExtraConfig+=$h
            $orignalExtraConfig+=$i
            $orignalExtraConfig+=$j
            $orignalExtraConfig+=$k
            $orignalExtraConfig+=$l
            $orignalExtraConfig+=$m

            $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
            $spec.ExtraConfig = $orignalExtraConfig

            New-Logtrace "Adding guestinfo customization properties to $vmname ..."
            $task = $vm.ExtensionData.ReconfigVM_Task($spec)
            $task1 = Get-Task -Id ("Task-$($task.value)")
            $task1 | Wait-Task | Out-Null

            New-Logtrace "Powering On $vmname ..."
            Start-VM -Server $viConnection -VM $vm -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
        }
    } else {
        $global:NestedConfESXI.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
            $VMName = $_.Key
            $VMIPAddress = $_.Value

            $ovfconfig = Get-OvfConfiguration $NestedESXiAppliance
            $ovfconfig.NetworkMapping.VM_Network.value = $VMNetwork

            $ovfconfig.common.guestinfo.hostname.value = $VMName
            $ovfconfig.common.guestinfo.ipaddress.value = $VMIPAddress
            $ovfconfig.common.guestinfo.netmask.value = $VMNetmask
            $ovfconfig.common.guestinfo.gateway.value = $VMGateway
            $ovfconfig.common.guestinfo.dns.value = $VMDNS
            $ovfconfig.common.guestinfo.domain.value = $VMDomain
            $ovfconfig.common.guestinfo.ntp.value = $VMNTP
            $ovfconfig.common.guestinfo.syslog.value = $VMSyslog
            $ovfconfig.common.guestinfo.password.value = $VMPassword
            if($VMSSH -eq "true") {
                $VMSSHVar = $true
            } else {
                $VMSSHVar = $false
            }
            $ovfconfig.common.guestinfo.ssh.value = $VMSSHVar

            New-Logtrace "Deploying Nested ESXi VM $VMName ..."
            $vm = Import-VApp -Source $NestedESXiAppliance -OvfConfiguration $ovfconfig -Name $VMName -Location $cluster -VMHost $vmhost -Datastore $datastore -DiskStorageFormat thin

            # Add the dvfilter settings to the exisiting ethernet1 (not part of ova template)
            New-Logtrace "Correcting missing dvFilter settings for Eth1 ..."
            $vm | New-AdvancedSetting -name "ethernet1.filter4.name" -value "dvfilter-maclearn" -confirm:$false -ErrorAction SilentlyContinue | Out-File -Append -LiteralPath $verboseLogFile
            $vm | New-AdvancedSetting -Name "ethernet1.filter4.onFailure" -value "failOpen" -confirm:$false -ErrorAction SilentlyContinue | Out-File -Append -LiteralPath $verboseLogFile

            
            New-Logtrace "Updating vCPU Count to $NestedESXivCPU & vMEM to $NestedESXivMEM GB ..."
            Set-VM -Server $viConnection -VM $vm -NumCpu $NestedESXivCPU -MemoryGB $NestedESXivMEM -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile

            New-Logtrace "Updating vSAN Caching VMDK size to $NestedESXiCachingvDisk GB ..."
            Get-HardDisk -Server $viConnection -VM $vm -Name "Hard disk 2" | Set-HardDisk -CapacityGB $NestedESXiCachingvDisk -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile

            New-Logtrace "Updating vSAN Capacity VMDK size to $NestedESXiCapacityvDisk GB ..."
            Get-HardDisk -Server $viConnection -VM $vm -Name "Hard disk 3" | Set-HardDisk -CapacityGB $NestedESXiCapacityvDisk -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile

            New-Logtrace "Powering On $vmname ..."
            $vm | Start-Vm -RunAsync | Out-Null
        }
    }
}

if($deployVCSA -eq 1) {
    if($DeploymentTarget -eq "ESXI") {
        # Deploy using the VCSA CLI Installer
        $config = (Get-Content -Raw "$($VCSAInstallerPath)\vcsa-cli-installer\templates\install\embedded_vCSA_on_ESXi.json") | convertfrom-json
        $config.'new.vcsa'.esxi.hostname = $VIServer
        $config.'new.vcsa'.esxi.username = $VIUsername
        $config.'new.vcsa'.esxi.password = $VIPassword
        $config.'new.vcsa'.esxi.'deployment.network' = $VMNetwork
        $config.'new.vcsa'.esxi.datastore = $datastore
        $config.'new.vcsa'.appliance.'thin.disk.mode' = $true
        $config.'new.vcsa'.appliance.'deployment.option' = $VCSADeploymentSize
        $config.'new.vcsa'.appliance.name = $VCSADisplayName
        $config.'new.vcsa'.network.'ip.family' = "ipv4"
        $config.'new.vcsa'.network.mode = "static"
        $config.'new.vcsa'.network.ip = $VCSAIPAddress
        $config.'new.vcsa'.network.'dns.servers'[0] = $VMDNS
        $config.'new.vcsa'.network.prefix = $VCSAPrefix
        $config.'new.vcsa'.network.gateway = $VMGateway
        $config.'new.vcsa'.network.'system.name' = $VCSAHostname
        $config.'new.vcsa'.os.password = $VCSARootPassword
        if($VCSASSHEnable -eq "true") {
            $VCSASSHEnableVar = $true
        } else {
            $VCSASSHEnableVar = $false
        }
        $config.'new.vcsa'.os.'ssh.enable' = $VCSASSHEnableVar
        $config.'new.vcsa'.sso.password = $VCSASSOPassword
        $config.'new.vcsa'.sso.'domain-name' = $VCSASSODomainName
        $config.'new.vcsa'.sso.'site-name' = $VCSASSOSiteName

        New-Logtrace "Creating VCSA JSON Configuration file for deployment ..."
        $config | ConvertTo-Json | Set-Content -Path "$($ENV:Temp)\jsontemplate.json"

        New-Logtrace "Deploying the VCSA ..."
        Invoke-Expression "$($VCSAInstallerPath)\vcsa-cli-installer\win32\vcsa-deploy.exe install --no-esx-ssl-verify --accept-eula --acknowledge-ceip $($ENV:Temp)\jsontemplate.json"| Out-File -Append -LiteralPath $verboseLogFile
    } else {
        $config = (Get-Content -Raw "$($VCSAInstallerPath)\vcsa-cli-installer\templates\install\embedded_vCSA_on_VC.json") | convertfrom-json
        $config.'new.vcsa'.vc.hostname = $VIServer
        $config.'new.vcsa'.vc.username = $VIUsername
        $config.'new.vcsa'.vc.password = $VIPassword
        $config.'new.vcsa'.vc.'deployment.network' = $VMNetwork
        $config.'new.vcsa'.vc.datastore = $datastore
        $config.'new.vcsa'.vc.datacenter = $datacenter.name
        $config.'new.vcsa'.vc.target = $VMCluster
        $config.'new.vcsa'.appliance.'thin.disk.mode' = $true
        $config.'new.vcsa'.appliance.'deployment.option' = $VCSADeploymentSize
        $config.'new.vcsa'.appliance.name = $VCSADisplayName
        $config.'new.vcsa'.network.'ip.family' = "ipv4"
        $config.'new.vcsa'.network.mode = "static"
        $config.'new.vcsa'.network.ip = $VCSAIPAddress
        $config.'new.vcsa'.network.'dns.servers'[0] = $VMDNS
        $config.'new.vcsa'.network.prefix = $VCSAPrefix
        $config.'new.vcsa'.network.gateway = $VMGateway
        $config.'new.vcsa'.network.'system.name' = $VCSAHostname
        $config.'new.vcsa'.os.password = $VCSARootPassword
        if($VCSASSHEnable -eq "true") {
            $VCSASSHEnableVar = $true
        } else {
            $VCSASSHEnableVar = $false
        }
        $config.'new.vcsa'.os.'ssh.enable' = $VCSASSHEnableVar
        $config.'new.vcsa'.sso.password = $VCSASSOPassword
        $config.'new.vcsa'.sso.'domain-name' = $VCSASSODomainName
        $config.'new.vcsa'.sso.'site-name' = $VCSASSOSiteName

        New-Logtrace "Creating VCSA JSON Configuration file for deployment ..."
        $config | ConvertTo-Json | Set-Content -Path "$($ENV:Temp)\jsontemplate.json"

        New-Logtrace "Deploying the VCSA ..."
        Invoke-Expression "$($VCSAInstallerPath)\vcsa-cli-installer\win32\vcsa-deploy.exe install --no-esx-ssl-verify --accept-eula --acknowledge-ceip $($ENV:Temp)\jsontemplate.json"| Out-File -Append -LiteralPath $verboseLogFile
    }
}

if($moveVMsIntovApp -eq 1 -and $DeploymentTarget -eq "VCENTER") {
    New-Logtrace "Creating vApp $VAppName ..."
    $VApp = New-VApp -Name $VAppName -Server $viConnection -Location $cluster

    if($deployNestedESXiVMs -eq 1) {
        New-Logtrace "Moving Nested ESXi VMs into $VAppName vApp ..."
        $global:NestedConfESXI.GetEnumerator() | Sort-Object -Property Value | Foreach-Object {
            $vm = Get-VM -Name $_.Key -Server $viConnection
            Move-VM -VM $vm -Server $viConnection -Destination $VApp -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
        }
    }

    if($deployVCSA -eq 1) {
        $vcsaVM = Get-VM -Name $VCSADisplayName -Server $viConnection
        New-Logtrace "Moving $VCSADisplayName into $VAppName vApp ..."
        Move-VM -VM $vcsaVM -Server $viConnection -Destination $VApp -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
    }

}

New-Logtrace "Disconnecting from $VIServer ..."
Disconnect-VIServer $viConnection -Confirm:$false


if($setupNewVC -eq 1) {
    New-Logtrace "Connecting to the new VCSA ..."
    $vc = Connect-VIServer $VCSAIPAddress -User "administrator@$VCSASSODomainName" -Password $VCSASSOPassword -WarningAction SilentlyContinue

    New-Logtrace "Creating Datacenter $NewVCDatacenterName ..."
    New-Datacenter -Server $vc -Name $NewVCDatacenterName -Location (Get-Folder -Type Datacenter -Server $vc) | Out-File -Append -LiteralPath $verboseLogFile

    New-Logtrace "Creating VSAN Cluster $NewVCVSANClusterName ..."
    New-Cluster -Server $vc -Name $NewVCVSANClusterName -Location (Get-Datacenter -Name $NewVCDatacenterName -Server $vc) -DrsEnabled -VsanEnabled -VsanDiskClaimMode 'Manual' | Out-File -Append -LiteralPath $verboseLogFile

    if($addESXiHostsToVC -eq 1) {
        $global:NestedConfESXI.GetEnumerator() | sort -Property Value | Foreach-Object {
            $VMName = $_.Key
            $VMIPAddress = $_.Value

            $targetVMHost = $VMIPAddress
            if($addHostByDnsName -eq 1) {
                $targetVMHost = $VMName
            }
            New-Logtrace "Adding ESXi host $targetVMHost to Cluster ..."
            Add-VMHost -Server $vc -Location (Get-Cluster -Name $NewVCVSANClusterName) -User "root" -Password $VMPassword -Name $targetVMHost -Force | Out-File -Append -LiteralPath $verboseLogFile
        }
    }

  #Thanks to William Lam for This part####

    if($configureVSANDiskGroups -eq 1) {
        New-Logtrace "Enabling VSAN Space Efficiency/De-Dupe & disabling VSAN Health Check ..."
        Get-VsanClusterConfiguration -Server $vc -Cluster $NewVCVSANClusterName | Set-VsanClusterConfiguration -SpaceEfficiencyEnabled $true -HealthCheckIntervalMinutes 0 | Out-File -Append -LiteralPath $verboseLogFile


        foreach ($vmhost in Get-Cluster -Server $vc | Get-VMHost) {
            $luns = $vmhost | Get-ScsiLun | select CanonicalName, CapacityGB

            New-Logtrace "Querying ESXi host disks to create VSAN Diskgroups ..."
            foreach ($lun in $luns) {
                if(([int]($lun.CapacityGB)).toString() -eq "$NestedESXiCachingvDisk") {
                    $vsanCacheDisk = $lun.CanonicalName
                }
                if(([int]($lun.CapacityGB)).toString() -eq "$NestedESXiCapacityvDisk") {
                    $vsanCapacityDisk = $lun.CanonicalName
                }
            }
            New-Logtrace "Creating VSAN DiskGroup for $vmhost ..."
            New-VsanDiskGroup -Server $vc -VMHost $vmhost -SsdCanonicalName $vsanCacheDisk -DataDiskCanonicalName $vsanCapacityDisk | Out-File -Append -LiteralPath $verboseLogFile
          }
    }

    if($clearVSANHealthCheckAlarm -eq 1) {
        New-Logtrace "Clearing default VSAN Health Check Alarms, not applicable in Nested ESXi env ..."
        $alarmMgr = Get-View AlarmManager -Server $vc
        Get-Cluster -Server $vc | where {$_.ExtensionData.TriggeredAlarmState} | %{
            $cluster = $_
            $Cluster.ExtensionData.TriggeredAlarmState | %{
                $alarmMgr.AcknowledgeAlarm($_.Alarm,$cluster.ExtensionData.MoRef)
            }
        }
    }

    # Exit maintanence mode in case patching was done earlier
    foreach ($vmhost in Get-Cluster -Server $vc | Get-VMHost) {
        if($vmhost.ConnectionState -eq "Maintenance") {
            Set-VMHost -VMhost $vmhost -State Connected -RunAsync -Confirm:$false | Out-File -Append -LiteralPath $verboseLogFile
        }
    }

    New-Logtrace "Disconnecting from new VCSA ..."
    Disconnect-VIServer $vc -Confirm:$false
}


$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

New-Logtrace "vSphere $vSphereVersion Lab Deployment Complete!"
New-Logtrace "StartTime: $StartTime"
New-Logtrace "  EndTime: $EndTime"
New-Logtrace " Duration: $duration minutes"



