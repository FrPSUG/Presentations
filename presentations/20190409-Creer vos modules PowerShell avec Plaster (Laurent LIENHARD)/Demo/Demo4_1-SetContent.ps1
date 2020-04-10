#Encore une fois pas de powershell tout se fait dans le fichier manifest ;-)
notepad $env:TEMP\MyCompleteTemplateModule\PlasterManifest.xml

#info au passage on peut afficher des messages pendant la création du module
<message>____________________________________</message>
<message>`r`n`tMagic in progress`r`n</message>
<message>____________________________________</message>
<message>`r`n-> Creating your code folders</message>

#Premiére etape on créé le repertoire pour le module
<file source='' destination='${PLASTER_PARAM_ModuleName}' />

#On créé ensuite les dossiers pour le module en fonction des choix fait dans la variable ModuleFolders
<file source='' destination='${PLASTER_PARAM_ModuleName}\Sources\Functions\Private\' condition='$PLASTER_PARAM_ModuleFolders -contains "Functions"'/>
<file source='' destination='${PLASTER_PARAM_ModuleName}\Sources\Functions\Public\' condition='$PLASTER_PARAM_ModuleFolders -contains "Functions"'/>
<file source='' destination='${PLASTER_PARAM_ModuleName}\Sources\Classes\Private\' condition='$PLASTER_PARAM_ModuleFolders -contains "Classes"'/>
<file source='' destination='${PLASTER_PARAM_ModuleName}\Sources\Classes\Public\' condition='$PLASTER_PARAM_ModuleFolders -contains "Classes"'/>
<file source='' destination='${PLASTER_PARAM_ModuleName}\Sources\Enums\' condition='$PLASTER_PARAM_ModuleFolders -contains "Enums"'/>

#On fait de même pour toute les variables
<message condition='$PLASTER_PARAM_Github -eq "Yes"'>`r`n-> Deploying Github</message>
<file source='' destination='${PLASTER_PARAM_ModuleName}\.Github\' condition='$PLASTER_PARAM_Github -eq "Yes"'/>
<message condition='$PLASTER_PARAM_Pester -eq "Yes"'>`r`n-> Deploying Pester</message>
<file source='' destination='${PLASTER_PARAM_ModuleName}\UnitTests\' condition='$PLASTER_PARAM_Pester -eq "Yes"'/>
<message condition='$PLASTER_PARAM_Editor -eq "VSCode"'>`r`n-> Creating VSCode folder</message>
<file source='' destination='.vscode' condition='$PLASTER_PARAM_Editor -eq "VSCode"' />
<message condition='$PLASTER_PARAM_Ci -eq "Yes"'>`r`n-> Creating CI folder</message>
<file source='' destination='${PLASTER_PARAM_ModuleName}\CI\' condition='$PLASTER_PARAM_Ci -eq "Yes"'/>
<message condition='$PLASTER_PARAM_Deploy -eq "Yes"'>`r`n-> Creating CI folder</message>
<file source='' destination='${PLASTER_PARAM_ModuleName}\Deploy\' condition='$PLASTER_PARAM_Deploy -eq "Yes"'/>

Copy-Item -Path ".\Demo\Demo4_2-PlasterManifest.xml" -Destination "$env:TEMP\MyCompleteTemplateModule\PlasterManifest.xml"
Clear-Host
Invoke-Plaster -TemplatePath $env:TEMP\MyCompleteTemplateModule -DestinationPath $env:TEMP
explorer.exe $env:TEMP\ModuleTest
Remove-Item -Path $env:TEMP\ModuleTest -Recurse -Force -Confirm:$false