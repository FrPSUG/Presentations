Describe 'Test un' -tags 'Init' {
    It "Valide que le répertoire Demo-Pester est présent" {
        Test-Path D:\git\Demo-Pester | should be $true
    }
    It "Valide qu'il y a 3 répertoires dans Demo-Pester" {
        (Get-ChildItem D:\git\Demo-Pester -Directory).count | should be 3
    }
}

Describe 'Test deux' {
    It "Valide que le répertoire D:\ est présent" {
        Test-Path D:\ | should be $true
    }
    It "Valide qu'il y a 3 répertoires minimum dans Demo-Pester" {
        (Get-ChildItem D:\git\ -Directory).count | should BeGreaterThan 3
    }
}

[array]$a = ($env:Path).split(';')
Describe 'test trois' -Tags 'Init' {
    It 'Valide que la variable est bien typée' {
           ,$a  | Should BeOfType String[]
    }
}
