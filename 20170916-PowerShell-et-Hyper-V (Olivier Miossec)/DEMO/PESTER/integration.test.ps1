<#
##########################################################################################################################################
#                                           PowerShell Saturday Paris 2017
##########################################################################################################################################

.SYNOPSIS  
    Ce Script fait partie des démos de la présentation Hyper-V & PowerShell 
    Il permet de tester un déploiement de VM
    
.DESCRIPTION
    Ce script prend pour paramètres VMData, le chemin d'un fichier de configration psd1 contenant un hastable.
    Le même que celui utilisé pour le déploiement des VM dans la démo précédente

.PARAMETER VMDataFile
    Le chemin du fichier psd1 contenant les donnees

.EXAMPLE
    .\integration.test.ps1 
    
.NOTES
   
    Author       : Olivier Miossec <olivier@omiossec.work>
#>



$vmdatafile = "testdata.psd1"
# Récupération des données dans une variable
$VMData = [hashtable] (invoke-expression (get-content $vmdatafile | out-string))

# on construit un array avec les données que l'on souhaite tester
$testcase =@()

    foreach ($node in $vmdata.allnodes)
    {

                if ($node.nodename -ne "*")
                {
                    
                    foreach ($vm in $node.vms)
                    {
                        
                        
                        $hashdata = @{
                              vmname=$vm.VMName
                              memory=$vm.VMMemory
                              vcpu=$vm.VMCpu
                              host = $node.NodeName
                          }
                          $testcase += $hashdata
                          
                          
                    }
    
        }
    }
        

       



Describe 'Simple Vm Validation' {
     
        It "the VM <VmName>   Should Be Running" -TestCases $testcase {
            param($vmname)
            (get-vm -Name $vmname -ComputerName lab-xxxx).State | Should Be 'Running'
            
        }


        It "the VM <VmName> should have <vcpu> cpu" -TestCases $testcase {
        param($vmname,$vcpu)
        (get-vm -Name $vmname -ComputerName lab-xxxx).ProcessorCount | Should Be $vcpu

        }

        It "the VM <VmName> should have <memory> Ram" -TestCases $testcase {
        param($vmname,$memory)
        (get-vm -Name $vmname -ComputerName lab-xxx).MemoryAssigned  | Should Be $memory
        
    }
}




