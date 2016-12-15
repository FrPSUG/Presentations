Import-Module .\Demo4\Demo.psm1


Describe 'Tester mon module' {
    It 'Test Get-SomeValue' {
        Get-SomeValue | Should Be $true
    }

    It 'Test Get-OtherValue' {
        Get-OtherValue | Should be "Tadahhh!"
    }
}

<#
InModuleScope Demo {
    Describe 'Tester mon module' {
    It 'Test Get-SomeValue' {
        Get-SomeValue | Should Be $true
    }

    It 'Test Get-OtherValue' {
        Get-OtherValue | Should be "Tadahhh!"
    }
}
}#>