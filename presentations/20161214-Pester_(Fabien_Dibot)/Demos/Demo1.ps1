# 1
New-Fixture -Path D:\Git\Demo-Pester\Demo1 -Name Do-Something
New-Fixture -Path D:\Git\Demo-Pester\Demo1 -Name Do-Machin
New-Fixture -Path D:\Git\Demo-Pester\Demo1\SubDemo -Name Do-Truc
Push-Location D:\Git\Demo-Pester\Demo1

# 2
<#
function Do-Something {
    param (
        [Switch]$Path,
        [int]$i
    )

    if ($path) {
        $a = Test-Path -Path 'D:\'
    }
    elseif ($i -ne 0) { $a = "Something"}
    elseif ($i -eq 0) { $a = "Too small!"}
    
    Return $a
}   
#>

<#
Describe "Faisons des tests autour de Do-Something pour valider cette fonction" {
    It "test bien le disque D:\" {
        Do-Something -Path | Should Be $true
    }
    It "test de la valeur de i = 0" {
        Do-Something -i 0 | Should be "Too small!"
    }
    It "test de la valeur de i > 0" {
        Do-Something -i 10 | Should be "Something"
    }
}
#>

<#
Describe "Faisons des tests autour de Do-Something pour valider cette fonction" {
    Context "Demo PSFRUG !!" {
        It "test bien le disque D:\" {
            Do-Something -Path | Should Be $true
        }
        It "test de la valeur de i = 0" {
            Do-Something -i 0 | Should be "Too small!"
        }
        It "test de la valeur de i > 0" {
            Do-Something -i 10 | Should be "Something"
        }
    }
}
#>

Liste des mots clefs derrière should:
=====================================
beExactly
BeGreaterThan
BeLessthan
BeLike
BeLikeExactly
BeOfType
Exist
Contain
ContainExactly
Match
MatchExactly
Throw
BeNullOrempty

