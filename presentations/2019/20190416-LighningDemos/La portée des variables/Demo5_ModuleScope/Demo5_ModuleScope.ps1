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

#Définissez la variable sur la portée du script à partir d'une fonction du module.
Set-MrVarScript

#Vérifiez la valeur de la variable $PsProcess à partir d'une autre fonction du même module
Test-MrVarScoping

#Vérifiez la valeur de la variable $PsProcess à partir de la portée actuelle <!> contrairement à l'exemple précédent sur les variable de type script celle-ci est également 
#visible dans ce script puisque nous sommes dans un module.
$PsProcess

#Définissez la variable sur la portée globale à partir d'une fonction du module.
Set-MrVarGlobal

#Vérifiez la valeur de la variable $PsProcess à partir d'une autre fonction du même module
Test-MrVarScoping

#Vérifiez la valeur de la variable $PsProcess à partir de la portée actuelle
$PsProcess