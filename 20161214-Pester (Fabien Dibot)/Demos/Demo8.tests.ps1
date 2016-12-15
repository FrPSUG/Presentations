
Describe 'verify disks' {
    $Disks = @{disk = 'c:'}, @{disk = 'd:'}
    It "<disk> should exists" -TestCases $disks {
        param($disk)
        Test-Path $disk | Should Be $true
    }
}