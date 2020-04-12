function DoSomething {
    $Script:MaVariable = "Créée dans le scope script" <# Variable créée dans le scope script donc visible dans TOUS le script #>
    $MaVariable1 = "Créée dans le scope de la fonction" <# Variable créée dans le scope Locale (scope apr défaut) visible dans la fonction uniquement #>
    Clear-Host
    Write-Output "Je suis dans la fonction"
    $Script:MaVariable
    $MaVariable1
}

DoSomething

Write-Output "Je suis dans le script"
$Script:MaVariable
$MaVariable1