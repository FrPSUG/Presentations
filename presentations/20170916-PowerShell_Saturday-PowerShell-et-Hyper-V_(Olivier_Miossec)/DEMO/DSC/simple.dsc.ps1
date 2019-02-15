<#
##########################################################################################################################################
#                                           PowerShell Saturday Paris 2017
##########################################################################################################################################

.SYNOPSIS  
    Ce Script fait partie des démos de la présentation Hyper-V & PowerShell 
    il permet de déployer des VM sur plusieurs host Hyper-v à partir d'un fichier de configuration en utilisant DSC
.DESCRIPTION
    Ce script prend pour paramètres VMData, le chemin d'un fichier de configration psd1 contenant un hastable.
    Ce Hastable permet de lancer les configuration contenue dans ce script.
    La configuration est lancé par DSC, les ressources sont créées dynamiquement en se basant sur les données du Hastable

.PARAMETER VMDataFile
    Le chemin du fichier psd1 contenant les donnees

.EXAMPLE
    .\simpledsc.ps1 -VMdata sampledata.psd1
    
.NOTES
   
    Author       : Olivier Miossec <olivier@omiossec.work>
#> 

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [String] $VMdataFile
)  



Configuration CreateVM
{
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -moduleName 'xHyper-v'

    
    Node $AllNodes.Where{$_.Role -eq "HyperV"}.NodeName
    {

        foreach ($vm in $node.VMs)
        {

                # create ressources folder
                File "VmFolder_$($vm.VMName)"
                {
                    Type = "Directory"
                    Ensure = "Present"
                    Force = $True 
                    DestinationPath = $node.path+"\"+$($vm.VMName) 
                }
                
                # copy the VHD
                File "CopysyspreVHD_$($vm.VMName)" 
                {
                    Type = "File"
                    Ensure = "Present"
                    Force = $True
                    SourcePath = $AllNodes.TemplateVHDX
                    DestinationPath =  "$($node.path)$($vm.VMName)\$($vm.VMName).vhdx"
                }
                
                # create the vm
                xVMHyperV "NewVm_$($vm.VMName)" 
                {
                    Ensure    = 'Present'
                    Name      = $vm.VMName
                    VhdPath   = $node.path+"\"+$($vm.VMName)+"\"+$($vm.VMName)+".vhdx"
                    Path = $node.path+"\"+$($vm.VMName)
                    Generation = $vm.generation
                    StartupMemory = $vm.VMMemory
                    ProcessorCount = $vm.VMCpu
                }
                
                # Create the VHD
                
                foreach ($vhd in $vm.VHDs)
                {
                    xVhd "NewVhd_$($vm.VMName)_$($vhd.Name)"
                    {
                        
                        Ensure  = 'present'
                        Name  = $vhd.Name
                        Path   = "$($node.path)$($vm.VMName)"
                        Generation   = 'vhdx'
                        type = 'Dynamic'
                        MaximumSizeBytes = $vhd.Size

                    }

                    Script "AddVhd_$($vm.VMName)_$($vhd.Name)"
                    {  
                            SetScript = {
                            # attach the drive to the VM 
                            
                            
                            ADD-VMHardDiskDrive -VMName $using:vm.VMName -Path "$($using:node.path)$($using:vm.VMName)\$($using:vhd.Name)"


                            }

                            GetScript = {

                                $vm = get-vm -VMName $using:vm.VMName  
                                $vhd = get-vhd  -VMId $vm.vmid | where-object path -eq "$($using:node.path)$($using:vm.VMName)\$($using:vhd.Name)"

                                return @{ result = $vhd }      
                            }

                            TestScript = {
                                try 
                                {
                                    $vm = get-vm -VMName $using:vm.VMName  
                                    $vhd = get-vhd  -VMId $vm.vmid | where-object path -eq "$($using:node.path)$($using:vm.VMName)\$($using:vhd.Name)"
                                    
                                    if ($vhd.value -gt 0)
                                    {
                                        return $true
                                    }
                                    else {
                                        return $false
                                    }

                                }
                                Catch 
                                {
                                    return $false
                                }
                                

                            }
                    }

                }
               

                script "ConnectVm_$($vm.VMName)"
                {

                    SetScript = {

                        Add-VMNetworkAdapter -VMName $using:vm.VMName  -SwitchName $using:vm.SwitchName    


                    }
                    
                    GetScript = {

                                 
                                $nic = get-vmnetadapter -VMName $using:vm.VMName

                                return @{ result = $nic }      
                            }

                            TestScript = {

                                try {
                                    $nic =Get-VMNetworkAdapter -VMName $vm.VMName

                                    if ($nic.SwitchName -eq $using:vm.SwitchName)
                                    {
                                        $true
                                    }
                                    else
                                    {
                                        $false
                                    }
                                }
                                catch {
                                    return $false
                                }


                            }
                }


        }


    }
}

# Suppression des fichiers MOF précédents
function Reset-MofConfig
{
        Remove-Item .\CreateVM -Force -Recurse 2>$null
}


# compilation des données en mof 
function Initialize-MofConfig
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [hashtable] $data
    )  

    createvm -ConfigurationData $data -verbose
}

<#
Start configuration
#>

function Get-VmData
{
    return $vmData
}


try
    {

        if (!(test-path $VMdataFile))
        {
            write-error '$VMdataFile non trouvé'
            exit
        }

        write-verbose "Lecture : $vmdatafile"
        # Récupération des données dans une variable
        $VMData = [hashtable] (invoke-expression (get-content $vmdatafile | out-string))

        

        write-verbose "Etape 1: Suppression des anciennes donnée"
        # Suppression des anciennes données
        Reset-MofConfig

        write-verbose "Etape 2: Compilation des fichiers MOF"
        # Compilation de la configuration 
        Initialize-MofConfig -data $VMData

        write-verbose "Etape 3: Lancement de la configuration"
        Start-DscConfiguration -Path .\createvm -Wait -Force -Verbose -Erroraction Stop

    }
catch {
        Write-Verbose "Exception: $_"
        throw
}