Describe "VM Running" {
    function Test-psVM {
        param ($vm,$vmhost, $Result)
        $testedvm = get-vm -name $vm -ComputerName $vmhost -ErrorAction SilentlyContinue
        It ("test  VM {0} on {1}" -f $vm, $vmhost) {
            $testedvm.State | Should be $Result
        }
    }

    $testCases = @(
        @{ vm = "vm1"; vmhost = "lab-node01" ; Result = "Running" }
        @{ vm = "vm2"; vmhost = "lab-node01" ; Result = "Off" }
        @{ vm = "vm3"; vmhost = "lab-node02" ; Result = "Off" }
    )

    foreach ($testCase in $testCases) {
        Test-psVM @testCase
    }
}