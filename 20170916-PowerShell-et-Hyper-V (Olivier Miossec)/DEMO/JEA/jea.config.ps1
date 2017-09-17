

# definition des répertoires 

$pathmodule = "C:\Program Files\windowspowershell\modules\HyperOpsJea"

$pathJea = "C:\ProgramData\jeaconfiguration\"

# Mise en place du dossier du module 

if (!(test-path -Path $pathmodule))
{
    new-item -Path $pathmodule -ItemType Directory
}

if (!(test-path -Path "$pathmodule\RoleCapabilities"))
{
    new-item -Path "$pathmodule\RoleCapabilities" -ItemType Directory
}

if (!(test-path -Path $$pathJea))
{
    new-item -Path $pathJea -ItemType Directory
}

# pour le module manifeste
New-ModuleManifest -Path "$pathmodule\HyperOpsJea.psd1"

# création du RoleCapabilities
New-PSRoleCapabilityFile -Path "$pathmodule\RoleCapabilities\HyperOpsJea.psrc" -Author Om-PowerShellSaturdayParis2017


# creation du fichier de session 

New-PSSessionConfigurationFile -Path "$pathJea\HyperOpsJea.pssc" -Author Om-PowerShellSaturdayParis2017

pause

# a exectuter sur la machine  ou en dsc
Register-PSSessionConfiguration -name HyperOpsJea -Path $pathJea\HyperOpsJea.pssc

restart-service winrm
 

