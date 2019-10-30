Clear-Host
$x = "testvar"

function fun1{
    Write-Output "Fun1"
    Write-Output "L'heritage permet de récupérer la valeur de X dans la fonction Fun1 => $x"
}

fun1

function fun2{
    Write-Output ""
    Write-Output "Fun2"
    Set-Variable -Name x -Value "testvar2" -Scope 0
    Write-Output "la notation scope 0 modifie la valeur de X dans cette fonction => $x"
    Write-Output "La notation Scope 1 permet de récupérer la valeur de la variable dans le parent => $((get-variable -Name X -Scope 1).Value)"
}

fun2

function fun3{
    Write-Output ""
    Write-Output "Fun3"
    Set-Variable -Name x -Value "testvar3" -Scope 1
    Write-Output "la notation scope 1 modifie la valeur de X dans la fonction parent => $x"
    Write-Output "La notation Scope 1 permet de récupérer la valeur de la variable dans le parent => $((get-variable -Name X -Scope 1).Value)"
}

fun3