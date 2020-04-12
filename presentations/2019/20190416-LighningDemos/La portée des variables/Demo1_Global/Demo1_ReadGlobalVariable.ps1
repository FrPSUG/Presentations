<#
Simple fonction qui ne fait que tenter d'afficher ma variable globale
 #>
function DoSomething {
    Clear-host
    Write-Output "Je suis dans DoSomething !"
    Write-output $Global:MaVariable    
}

DoSomething