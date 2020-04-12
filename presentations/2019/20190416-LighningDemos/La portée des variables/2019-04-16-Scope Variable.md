# La portée des variables en Powershell

Plusieurs scopes sont possibles pour l'utilisation des variables en fonctions du besoin

Quelques régles de base :

* Un élément que vous incluez dans une étendue est visible dans l'étendue dans laquelle il a été créé et dans toute étendue enfant, à moins que vous ne le rendiez explicitement privé
* Si vous créez un élément dans une étendue et que l'élément partage son nom avec un élément d'une autre étendue, l'élément d'origine peut être masqué sous le nouvel élément. Mais, il n'est pas remplacé ou modifié.

**Attention à la fin de l'article nous parlerons d'un cas particulier se présentant dans les modules PowerShell.**

## Global

les variables de ce type ce déclare le facon suivante :

```Powershell
$global:MaVariable
```

Les variables définies dans ce scope on une visibilité étendue à **TOUS** les scripts qui s'executent à ce moment là mais aussi **après leur fin d'execution**.

Prenons un script qui ne fait que définir une variable globale ``MaVariable``

```Powershell
$Global:MaVariable = "Mon Numéro de carte bancaire :-) "
```

Lancons ensuite un second script avec une fonction qui va lire cette variable (noté bien que le script précédent est terminé)

```Powershell
function DoSomething {
    Clear-Host
    Write-Output "Je suis dans DoSomething !"
    Write-output $Global:MaVariable
}

DoSomething
```

Le résultat est

```Powershell
Je suis dans DoSomething !
Mon Numéro de carte bancaire :-)
```

Cette variable va continuer d'exister tant que vous ne quittez pas le context powershell dans lequel vous l'avez créée.

Par exemple les variables présentent au démarrage de PowerShell, telles que les variables automatiques et les variables de préférences, sont dans cette étendue afin de pouvoir être utilisées partout.

## Local

La portée Local est la portée par défaut, une variable sans modificateur est créée ou référencée
dans la portée Local. Sont considérées comme des variables locales celles qui ne précisent pas de
modificateur et celles qui précisent le modificateur Local ou Private.

Vous trouverez un exemple dans le point suivant sur le ``scope Script``

## Script

les variables de ce type ce déclare de la facon suivante :

```Powershell
$script:MaVariable
```

C'est une étendue créée lors de l'execution d'un script et qui disparait avec la fn de l'execution du script.

Les variables définies dans ce scope  sont visibles que dans le script et pendant l'execution du script.

```Powershell
function DoSomething {
    $Script:MaVariable = "Créée dans le scope script"
    $MaVariable1 = "Créée dans le scope de la fonction"
    Clear-Host
    Write-Output "Je suis dans la fonction"
    $Script:MaVariable
    $MaVariable1
}

DoSomething

Write-Output "Je suis dans le script"
$Script:MaVariable
$MaVariable1
```

Le résultat est

```Powershell
Je suis dans la fonction
Créée dans le scope script
Créée dans le scope de la fonction
Je suis dans le script
Créée dans le scope script
```

La Variable ```$MaVariable1``` est une variable locale à la fonction ```DoSomething``` elle n'est donc pas visible dans l'étendue du script contrairement à la variable ```$Script:MaVariable```

## Private

```Powershell
$private:MaVariable
```

Les éléments dans la portée privée ne peuvent pas être vus en dehors de la portée actuelle. Vous pouvez utiliser une portée privée pour créer une version privée d'un élément portant le même nom dans une autre portée.

```Powershell
$MaVariable = "mon adresse mail !"

function DoSomething {
    $Private:MaVariable = "Mon numéro de CB !"

    function DoSomething2 {
        Write-Output "je suis dans DoSomething2 et MaVariable vaut $MaVariable"
    }
    DoSomething2
}
DoSomething
```

Le résultat est

```Powershell
je suis dans DoSomething2 et MaVariable vaut mon adresse mail !
```

Du fait que la variable ``$MaVariable`` dans la fonction DoSomething le soit en tant que private, elle n'est pas visible dans la fonction DoSomething2 qui utilise donc la variable $MaVariable défini au début du script dans le scope Local

## Numeroted

Vous pouvez faire référence à des portées par leur nom ou par un numéro décrivant la position relative d’un champ à l’autre.

La portée 0 représente la portée actuelle ou locale.

L'étendue 1 indique l'étendue parent immédiate.

L'étendue  2 indique le parent de la portée parent, etc.

Les étendues numérotées sont utiles si vous avez créé de nombreuses étendues récursives.

Prenons le script suivant

```Powershell
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
```

le résultat est le suivant

```Powershell
Fun1
L'heritage permet de récupérer la valeur de X dans la fonction Fun1 => testvar

Fun2
la notation scope 0 modifie la valeur de X dans cette fonction => testvar2
La notation Scope 1 permet de récupérer la valeur de la variable dans le parent => testvar

Fun3
la notation scope 1 modifie la valeur de X dans la fonction parent => testvar3
La notation Scope 1 permet de récupérer la valeur de la variable dans le parent => testvar3
```

## Cas Particulier : Les modules

_________________________________

Dans le cas des modules il y a une subtilité au niveau des variables dans le scope Script.

Une variable script définie dans un module est accessible par tous les fonctions, scripts composant le module mais également à partir du contexte du script qui a ammené à la création de cette variable.

Cela parait compliquer mais nous allons voir avec un petit exemple de quoi il retourne.

Imaginons le module suivant : Demo5_ModuleScope.psm1

```Powershell
function Set-MrVar {
    $PsProcess = Get-Process -Name PowerShell
}
function Set-MrVarLocal {
    $Local:PsProcess = Get-Process -Name PowerShell
}
function Set-MrVarScript {
    $Script:PsProcess = Get-Process -Name PowerShell
}
function Set-MrVarGlobal {
    $Global:PsProcess = Get-Process -Name PowerShell
}
function Test-MrVarScoping {
    if ($PsProcess) {
        Write-Output $PsProcess
    }
    else {
        Write-Warning -Message 'Variable $PsProcess not found!'
    }
}
```

Il est assez simple il créé une variable ```$PsProcess``` dans les divers scope que nous avons vu précédement.

Pour appeller ce module faisons un petit script : Demo5_ModuleScope.ps1

```Powershell
#Importer le module Demo5_ModuleScope.psm1

#Définition la variable sans contrainte de la portée dans une fonction du module
Set-MrVar

#Vérifiez la valeur de la variable $PsProcess à partir d'une autre fonction du même module
Test-MrVarScoping

#Vérifiez la valeur de la variable $PsProcess à partir de la portée actuelle
$PsProcess

#Définissez la variable sur la portée locale à partir d'une fonction du module.
Set-MrVarLocal

#Vérifiez la valeur de la variable $PsProcess à partir d'une autre fonction du même module
Test-MrVarScoping

#Vérifiez la valeur de la variable $PsProcess à partir de la portée actuelle
$PsProcess

#Set the variable to the script scope from within a function in the module
Set-MrVarScript

#Vérifiez la valeur de la variable $PsProcess à partir d'une autre fonction du même module
Test-MrVarScoping

#Vérifiez la valeur de la variable $PsProcess à partir de la portée actuelle
$PsProcess

#Définissez la variable sur la portée globale à partir d'une fonction du module.
Set-MrVarGlobal

#Vérifiez la valeur de la variable $PsProcess à partir d'une autre fonction du même module
Test-MrVarScoping

#Vérifiez la valeur de la variable $PsProcess à partir de la portée actuelle
$PsProcess
```

Ce script execute à tour de rôle la création de la variable ```$PsProcess``` dans chacun des scopes, et vérifie si la variable est visible dans le contexte du module (psm1) et/ou du script (ps1)

Dans la plupart des cas le scope se comporte exactement comme il le devrait sauf pour le scope Script.

On commence par instancier la variable de scope Script

```Powershell
Set-MrVarScript
```

Ensuite testons la valeur de cette variable à partir de la fonction ```Test-MrVarScoping``` nous sommes donc dans le contexte du module

```Powershell
PS > Test-MrVarScoping

Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
-------  ------    -----      -----     ------     --  -- -----------
    599      27    65608      74188       0,83   1580   2 powershell
    783      41   135132     133900       6,59   9564   2 powershell
```

Logiquement nous avons un retour puisque la variable est dans le scope Script et que la fonction ```Test-MrVarScoping``` se trouve également dans le même fichier.

Tentons la même chose dans le contexte du script Demo5_ModuleScope.ps1

```Powershell
PS > $PsProcess

Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName
-------  ------    -----      -----     ------     --  -- -----------
    599      27    65608      74188       0,83   1580   2 powershell
    783      41   135132     133900       6,63   9564   2 powershell
```

Surprenant :-)

Effectivement bien que définie en tant que script dans le module, la variable ```$PsProcess``` est également disponible dans le contexte du script ps1 qui utilise ce module.

Voilà j'espère vous en avoir appris un peu plus sur cette notion de scope de variables en PowerShell.