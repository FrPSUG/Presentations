#Encore, Encore une fois pas de powershell tout se fait dans le fichier manifest ;-)
notepad $env:TEMP\MyCompleteTemplateModule\PlasterManifest.xml

#Création du manifest (fichier psd1) pour notre nouveau module
#Pour le générer on prend simplement les informations saisie lors de l'execution d'invoke-plaster
<message>`r`n-> Creating module manifest</message>
<newModuleManifest destination='$PLASTER_PARAM_ModuleName\${PLASTER_PARAM_ModuleName}.psd1' moduleVersion='$PLASTER_PARAM_ModuleVersion' rootModule='.\${PLASTER_PARAM_ModuleName}.psm1' author='$PLASTER_PARAM_AuthorName' companyName='${PLASTER_PARAM_Company}' description='$PLASTER_PARAM_ModuleDescription' encoding='UTF8-NoBOM'/>

#Jusque là on a parler de créer des dossiers mais quand est-il des fichiers
#2 possibilités : 
# * simple copie d'un fichier (comme pour les dossiers)
# * utiliser les templatefile (a expliquer)
#pour générer le fichier psm1 on peu utiliser l'une ou l'autre des méthodes
#pour l'exemple on va utiliser un templatefile (copier le fichie Module.template.psm1 dans le template Plaster)
<templateFile source='.\Module.template.psm1' destination='${PLASTER_PARAM_ModuleName}\${PLASTER_PARAM_ModuleName}.psm1'/>

Copy-Item -Path ".\Resources\Module.template.psm1" -Destination "$env:TEMP\MyCompleteTemplateModule\"
Copy-Item -Path ".\Demo\Demo6_2-PlasterManifest.xml" -Destination "$env:TEMP\MyCompleteTemplateModule\PlasterManifest.xml"
Clear-Host
Invoke-Plaster -TemplatePath $env:TEMP\MyCompleteTemplateModule -DestinationPath $env:TEMP
explorer.exe $env:TEMP\ModuleTest
code $env:TEMP\ModuleTest\
code $env:TEMP\MyCompleteTemplateModule\
Remove-Item -Path $env:TEMP\ModuleTest -Recurse -Force -Confirm:$false

Remove-Item -Path $env:TEMP\MyCompleteTemplateModule\ -Recurse -Force -Confirm:$false
