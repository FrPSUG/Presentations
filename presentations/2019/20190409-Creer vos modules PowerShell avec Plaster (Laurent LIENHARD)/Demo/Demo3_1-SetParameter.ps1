#pas de powershell tout se fait dans le fichier manifest ;-)
notepad $env:TEMP\MyCompleteTemplateModule\PlasterManifest.xml

#Question simple à copier/coller dans le manifest
<parameter name='ModuleName' type='text' prompt='`r`nEnter the name of the module' />
<parameter name='ModuleDescription' type='text' prompt='`r`nEnter a description of the module (required for publishing to the PowerShell Gallery)' />
<parameter name='ModuleVersion' type='text' prompt='`r`nEnter the version number for the module' default='0.0.1' />
<parameter name='AuthorName' type='user-fullname' prompt='`r`nEnter your full name' />
<parameter name='AuthorEmail' type='user-email' prompt='`r`nEnter your email address' />


#Choix simple  à copier/coller dans le manifest
#En répondant a cette question on affecte la réponse à la vairiable Pester
<parameter name='PESTER' type = 'choice' prompt='`r`nPester test support?' default='0'>
    <choice label='&amp;Yes' value='Yes' help='Add Tests directory and a starter Pester Tests file.'/>
    <choice label='&amp;No' value='No' help='No Pester support'/>
</parameter>
<parameter name='GITHUB' type = 'choice' prompt='`r`nInclude GitHub Support?' default='0'>
    <choice label='&amp;Yes' value='Yes' help='Issue/PR Templates, Code of Conduct and Contribution guide'/>
    <choice label='&amp;No' value='No' help='Do not include files'/>
</parameter>
<parameter name='EDITOR' type='choice' default='1' store='text' prompt='`r`nWhich editor do you use'>
    <choice label='&amp;ISE' help='Your editor is PowerShell ISE.' value='ISE'/>
    <choice label='Visual Studio &amp;Code' help='Your editor is Visual Studio Code.' value='VSCode'/>
    <choice label='&amp;None' help='No editor specified.' value='None'/>
</parameter>
<parameter name='CI' type = 'choice' prompt='`r`nCreate CI directory (needed for vscode tasks)' default='0'>
    <choice label='&amp;Yes' value='Yes' help='use for vscode tasks to automate build and tests'/>
    <choice label='&amp;No' value='No' help='Do not include files'/>
</parameter>
<parameter name='DEPLOY' type = 'choice' prompt='`r`nCreate Deploy directory (needed for vscode tasks)' default='0'>
    <choice label='&amp;Yes' value='Yes' help='use for vscode tasks to automate module deploy'/>
    <choice label='&amp;No' value='No' help='Do not include files'/>
</parameter>

#Choix multiple à copier/coller dans le manifest
<parameter name='MODULEFOLDERS' type = 'multichoice' prompt='`r`nPlease select folders to include' default='0,1,2'>
    <choice label='&amp;Functions' value='functions' help='Folder containing functions'/>
    <choice label='&amp;Classes' value='Classes' help='Folder containing classes'/>
    <choice label='&amp;Enums' value='Enums' help='Folder containing enums'/>
</parameter>

Copy-Item -Path ".\Demo\Demo3_2-PlasterManifest.xml" -Destination "$env:TEMP\MyCompleteTemplateModule\PlasterManifest.xml"
Clear-Host
Invoke-Plaster -TemplatePath $env:TEMP\MyCompleteTemplateModule -DestinationPath $env:TEMP


