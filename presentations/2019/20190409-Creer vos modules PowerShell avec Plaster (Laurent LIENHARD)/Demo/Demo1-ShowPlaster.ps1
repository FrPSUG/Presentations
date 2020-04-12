#Clean
Remove-Item -Path "$env:temp\MyCompleteTemplateModule" -Recurse -Force -Confirm:$false

#Installation
Install-module Plaster -Scope CurrentUser
Import-Module Plaster

get-command -Module Plaster

#Creation d'un manifest
New-PlasterManifest 
#Test d'un manifest
Test-PlasterManifest
#Information sur un template
Get-PlasterTemplate
#Création d'un module basé sur le template
Invoke-Plaster