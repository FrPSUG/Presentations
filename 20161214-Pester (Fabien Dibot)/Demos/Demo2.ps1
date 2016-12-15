New-Fixture -Path D:\Git\Demo-Pester\Demo2 -Name Clean-Something

function Clean-Something {
    Return "Que la force soit avec toi !"
}


<#
Describe "Testons le Mock !" {
    Context 'Demo2 PSFRUG !' {
        Mock -CommandName clean-something -MockWith {
            Return "La Bretagne ça vous gagne !"
        }

        It "Should return some awesome thing !!" {
            Clean-Something | should be "La Bretagne ça vous gagne !"
        }
    }
}
#>

<#
Describe "Testons le Mock !" {
    Context 'Demo2 PSFRUG !' {
        Mock -CommandName clean-something -MockWith {
            Return "La Bretagne ça vous gagne !"
        }

        It "Should return some awesome thing !!" {
            Clean-Something | should be "La Bretagne ça vous gagne !"
        }

        It "Vérifie que le Mock est utilisé au moins une fois" {
            Assert-VerifiableMocks
        }
    }
}
#>

<#
Describe "Testons le Mock !" {
    Context 'Demo2 PSFRUG !' {
        Mock -CommandName clean-something -MockWith {
            Return "La Bretagne ça vous gagne !"
        }
        
        $output = @()
        0..10 | % {
            $output += Clean-Something
        }
        It "Should return some awesome thing !!" {
            Clean-Something | should be "La Bretagne ça vous gagne !"
        }

        It "Vérifie que le Mock est utilisé au moins une fois" {
            Assert-VerifiableMocks
        }

        It "Vérifie que le Mock a été exécuté 12 fois" {
            Assert-MockCalled -CommandName clean-something -Exactly -times 12
        }
    }
}
#>

