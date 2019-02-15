

Describe "Add-Content" {
    $Path = "TestDrive:\psfrug.txt"
    Set-Content $Path -value "http://www.meetup.com/fr-FR/FrenchPSUG/"
    $result = Get-Content $Path

    It "Fait de la pub pour le User Group" {
        $result | Should Be "http://www.meetup.com/fr-FR/FrenchPSUG/"
    }
}

Describe "tests qui ne doivent pas fonctionner" {
    It "Valide la présence de psfrug.txt dans testdrive" {
       Test-Path TestDrive:\psfrug.txt | Should be $true
    }
}

