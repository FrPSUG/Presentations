Describe "Vm Creation" {
    $vm = Get-VM -Name vm1 -ComputerName "lab-node01" -ErrorAction SilentlyContinue
    $vhd = Get-VHD -VMId $vm.VMId -ComputerName "lab-node01" 
    # Test si la VM exist
    It "the Vm Exist" {
        $vm.name | Should Be "vm1"
    }
    It "The VM has 2Gb of Ram" {
        $VMRam = $vm.MemoryStartup / 1GB
        $VMRam | Should Be 2
    }
    It "has 3 vhd" {
        $vhd.count | Should Be 3
    }
    It "should be started" {
        $vm.Status | Should Be "Started"
    }
}