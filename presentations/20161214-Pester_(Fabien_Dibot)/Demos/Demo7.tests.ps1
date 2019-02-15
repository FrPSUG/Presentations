Describe 'Création de fichiers "fantome"' {
    It "Le fichier n'existe pas" {
       Test-Path TestDrive:\SomeFile.ps1 | Should be $false
    }
}

Describe 'Création de fichiers "fantome"' {
    Setup -File SomeFile.ps1
    It "Le fichier existe " {
        Test-path $TestDrive\SomeFile.ps1 | Should be $true
    }
}
