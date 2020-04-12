<# 
Notion importante avec plaster c'est la notion de templateFile
Le templateFile est un fichier que l'on peut compléter, avec le contenu des variables, lors de l'utilisation de invoke-plaster 
pour créer son module a partir du template
C'est cette notion qui va rendre l'utilisation de Plaster interresante et moins statique
 #>


 #Encore une fois pas de powershell tout se fait dans le fichier manifest ;-)
notepad $env:TEMP\MyCompleteTemplateModule\PlasterManifest.xml


 <message condition='$PLASTER_PARAM_Pester -eq "Yes"'>`r`n-> Copying UnitTests files</message>
 <templateFile source='UnitTests\*.Tests.ps1' destination='${PLASTER_PARAM_ModuleName}\UnitTests\' condition='$PLASTER_PARAM_Pester -eq "Yes"'/>

 <message condition='$PLASTER_PARAM_Deploy -eq "Yes"'>`r`n-> Copying Deploy files</message>
 <templateFile source='Deploy\template.PSDeploy.ps1' destination='${PLASTER_PARAM_ModuleName}\Deploy\${PLASTER_PARAM_ModuleName}.PSDeploy.ps1' condition='$PLASTER_PARAM_Deploy -eq "Yes"'/>

 <message condition='$PLASTER_PARAM_Ci -eq "Yes"'>`r`n-> Copying CI files</message>
 <templateFile source='CI\template.Build.ps1' destination='${PLASTER_PARAM_ModuleName}\CI\${PLASTER_PARAM_ModuleName}.Build.ps1' condition='$PLASTER_PARAM_Ci -eq "Yes"'/>

 <message condition='$PLASTER_PARAM_github -eq "Yes"'>`r`n-> Copying Github files</message>
 <templateFile source='github\*.md' destination='${PLASTER_PARAM_ModuleName}\.github\' condition='$PLASTER_PARAM_Github -eq "Yes"'/>

 <file source='vscode\settings.json' destination='${PLASTER_PARAM_ModuleName}\.vscode\settings.json' condition='$PLASTER_PARAM_Editor -eq "VSCode"' />
 <file source='vscode\launch.json' destination='${PLASTER_PARAM_ModuleName}\.vscode\launch.json' condition='$PLASTER_PARAM_Editor -eq "VSCode"' />
 <file source='vscode\PSScriptAnalyzerSettings.psd1' destination='${PLASTER_PARAM_ModuleName}\.vscode\PSScriptAnalyzerSettings.psd1' condition='$PLASTER_PARAM_Editor -eq "VSCode"' />
 <templateFile source='vscode\tasks.json' destination='${PLASTER_PARAM_ModuleName}\.vscode\tasks.json' condition='($PLASTER_PARAM_Editor -eq "VSCode")' />


Copy-Item -Path ".\PSPlasterTemplate\*" -Destination $env:TEMP\MyCompleteTemplateModule -Recurse
Copy-Item -Path ".\Demo\Demo5_2-PlasterManifest.xml" -Destination "$env:TEMP\MyCompleteTemplateModule\PlasterManifest.xml"
code $env:TEMP\MyCompleteTemplateModule
Remove-Item -Path $env:TEMP\ModuleTest -Recurse -Force -Confirm:$false
Clear-Host
Invoke-Plaster -TemplatePath $env:TEMP\MyCompleteTemplateModule -DestinationPath $env:TEMP
code $env:TEMP\ModuleTest
Remove-Item -Path $env:TEMP\ModuleTest -Recurse -Force -Confirm:$false