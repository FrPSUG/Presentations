
#region Configuration Cluster et ajout des hôtes
Add-VMHost -Name 192.168.0.123   -Location (Get-Cluster -Name "Cluster") -User root -Password VMware1! -Force
Set-VMHost -VMHost 192.168.0.123 -State "Maintenance" -RunAsync
Remove-VMHost -VMHost 192.168.0.123 
Set-VMHost -VMHost 192.168.0.123 -State "Connected" -RunAsync
Add-VMHost -Name 192.168.0.123   -Location (Get-Cluster -Name "Cluster") -User root -Password VMware1! -Force

New-Cluster -Name "PowerCLI-HA" -HARestartPriority High -HAIsolationResponse DoNothing -HAEnabled -Location (Get-Datacenter) -Confirm:$false
#Ajout d'une Cile ISCSI au ESXI
$FreenasISCSI = "192.168.0.49"
$ESXI = ("192.168.0.120","192.168.0.121","192.168.0.122","192.168.0.123")

    foreach ($item in $ESXI) {
        Get-VMHostStorage -VMHost $item | Set-VMHostStorage -SoftwareIScsiEnabled $True  
        Start-Sleep -Seconds 3
        $hba = Get-VMHost  $item | Get-VMHostHba -Type iScsi
        New-IScsiHbaTarget -IScsiHba $hba -Address $FreenasISCSI
        Get-VMHost $item | Get-VMHostStorage -RescanAllHba
       Write-Host "the host $item is Ok ! " -ForegroundColor Green
    }
  
#region création d'un Cluster

  $name = ("192.168.0.120","192.168.0.121","192.168.0.122","192.168.0.123")
    foreach ($item in $ESXI) {
      Add-VMHost -Name $item   -Location (Get-Cluster -Name "PowerCLI-HA") -User root -Password VMware1! -Force
    }
   #Activation de DRS
    $Cluster= Get-Cluster -Name PowerCLI-HA
    $NewClustername = $Cluster.Name + '-DRS'
    
    Get-Cluster -Name $Cluster | Set-Cluster -Name $NewClustername -DrsAutomationLevel "FullyAutomated" -Confirm:$false 
    
  #Activation de vMotion pour les ESXI
  $ESXI = (Get-Cluster -Name "PowerCLI-HA-DRS" | Get-VMHost)

  foreach ($vEsxi in $ESXI)
      {
      Get-VMHost -Name $vEsxi | Get-VMHostNetworkAdapter | Where { $_.PortGroupName -eq "Management Network" }`
      | Set-VMHostNetworkAdapter -VMotionEnabled $true -Confirm:$false
        
      }
  
  
#endregion Cluster
#endregion

