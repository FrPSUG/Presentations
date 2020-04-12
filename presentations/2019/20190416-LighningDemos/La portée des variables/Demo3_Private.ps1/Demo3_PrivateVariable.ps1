$MaVariable = "mon adresse mail !"

function DoSomething {
    $Private:MaVariable = "Mon numéro de CB !"

    function DoSomething2 {
        Write-Output "je suis dans DoSomething2 et MaVariable vaut $MaVariable"
    }
    DoSomething2
    
}

DoSomething