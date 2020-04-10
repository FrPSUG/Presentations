#region Connection au serveur
Import-Module C:\Users\Jay\Documents\GitHub\FreeNas\Freenas\FreeNas.psm1 -Force
Connect-FreeNasServer -Server 192.168.0.23 -Username root -Password toto

#endregion Connection au serveur

#region Création de Volumes

Get-FreeNasDisk 
Get-FreeNasDisk -Output False
New-FreeNasVolume -VolumeName data -Vdevtype stripe -NbDisks 2 -StartDisksNB 0
New-FreeNasVolume -VolumeName data2 -Vdevtype raidz -NbDisks 3 -StartDisksNB 2
Get-FreeNasVolume
#endregion Création de Volumes

#region Creation de Volumes Zvol
New-FreeNasZvol -VolumeName data -ZvolName Zvol1 -Volsize 15 -Unit GiB -Compression lz4 -Sparse True -Comment "Pwsh FrUSUG"
New-FreeNasZvol -VolumeName data2 -ZvolName Zvol2 -Volsize 20 -Unit GiB -Compression lz4 -Sparse True -Comment "Pwsh FrUSUG"
Get-FreeNasZvol -VolumeName data
Get-FreeNasZvol -VolumeName data2
#endregion Creation de Volumes Zvol

#region Confiuration de la depuplication sur un Zvol
Set-FreeNasDedupZvol -VolumeName data -ZvolName Zvol1
Get-FreeNasZvol -VolumeName data
#endregion Confiuration de la depuplication sur un Zvol


#region Configuration du partage ISCSI
# recupération des Infos
Get-FreeNasIscsiConf
#creattion du Configurtation Global avec un nom qui commence par iqn 
Set-FreeNasIscsiConf -BaseName "iqn.2019-10.org.FrUSUG.loc" -pool_avail_threshold 75
Get-FreeNasIscsiConf

#region Le Portail
Get-FreeNasIscsiPortal
New-FreenasIscsiPortal -IpPortal 0.0.0.0   -Port 3260
#endregion Le Portail

#region Initiateurs
Get-FreeNasIscsiInitiator
New-FreeNasIscsiInitiator -AuthInitiators ALL -AuthNetwork ALL
#endregion Initiateurs

#region Cible ou target
Get-FreeNasIscsiTarget
New-FreeNasIscsiTarget -TargetName lun1 -TargetAlias lun1 
New-FreeNasIscsiTarget -TargetName lun2 -TargetAlias lun2
New-FreeNasIscsiTarget -TargetName lun3 -TargetAlias lun3   
New-FreeNasIscsiTarget -TargetName lun4 -TargetAlias lun4
Get-FreeNasIscsiTarget
#endregion Cible ou target

#region Extent
Get-FreeNasIscsiExtent
New-FreeNasIscsiExtent -ExtentName lun1 -ExtenType Disk -ExtentSpeed SSD -ExtenDiskPath /dev/da5
New-FreeNasIscsiExtent -ExtentName lun2 -ExtenType Disk -ExtentSpeed SSD -ExtenDiskPath /dev/da6
New-FreeNasIscsiExtent -ExtentName lun3 -ExtenType Disk -ExtentSpeed SSD -ExtenDiskPath zvol/data2/Zvol2
New-FreeNasIscsiExtent -ExtentName lun4 -ExtenType Disk -ExtentSpeed SSD -ExtenDiskPath zvol/data/Zvol1
Get-FreeNasIscsiExtent
#endregion Extent

#region Association
Get-FreeNasIscsiAssociat2Extent
Get-FreeNasIscsiTarget
New-FreeNasIscsiAssociat2Extent -TargetId 1 -ExtentId 1
New-FreeNasIscsiAssociat2Extent -TargetId 2 -ExtentId 2
New-FreeNasIscsiAssociat2Extent -TargetId 3 -ExtentId 3
New-FreeNasIscsiAssociat2Extent -TargetId 4 -ExtentId 4
Get-FreeNasIscsiAssociat2Extent -Output Name
#endregion Association

#endregion Configuration du partage ISCSI
Get-FreeNasService
Set-FreeNasService -Services iscsitarget -ServicesStatus True
Get-FreeNasIscsiSummary
#Region

#RegionRésumé des informations du services ISCSI
#RegionDémarrage du service ISCSI --> Test
