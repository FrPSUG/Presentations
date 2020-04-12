$manifestProperties = @{
    #Mandatory=$True
    TemplateName = 'MyCompleteTemplateModule'
    TemplateType = 'Project'
    #Mandatory=$False
    Path = "$env:temp\MyCompleteTemplateModule\PlasterManifest.xml"
    Title = "Full Module Template"
    TemplateVersion = '0.0.1'
    Author = 'Laurent LIENHARD'
    Tags = 'Module','Complete','FRPSUG'
    Description = 'Full Module Template'
}

New-Item -Path $env:temp\MyCompleteTemplateModule -ItemType Directory -Force
New-PlasterManifest @manifestProperties

code $env:temp\MyCompleteTemplateModule

Test-PlasterManifest -Path "$env:temp\MyCompleteTemplateModule\PlasterManifest.xml"
Get-PlasterTemplate -Path "$env:temp\MyCompleteTemplateModule"

Clear-Host
Invoke-Plaster -TemplatePath $env:temp\MyCompleteTemplateModule -DestinationPath $env:temp
