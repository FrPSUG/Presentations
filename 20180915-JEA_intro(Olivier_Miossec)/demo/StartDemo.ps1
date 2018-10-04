# Role Capabilitity for Web Administrator
New-PSRoleCapabilityFile -Path .\WebAdmin.psrc -Description "Web Admin Role" -Author "PsSaturday"

# Role Capabilitity for DB Administrator
New-PSRoleCapabilityFile -Path .\DbAdmin.psrc -Description "Db Admin Role" -Author "PsSaturday"



# Session configuration 

# PSSC File Path
$PSSCPath = "C:\ProgramData\JEAConfiguration\"
$PSSCPathFile = $PSSCPath + "ServerJeaAdmin.pssc"

if (!(Test-Path $PSSCPath)) {
    New-Item $PSSCPath -ItemType Directory
}

# Transcript Directory
$TranscriptPath = "f:\PowerShell\PsLog"

if (!(Test-Path $TranscriptPath)) {
    New-Item $TranscriptPath -ItemType Directory
}

  
    $Author = "PS Saturday"
    $Description = 'JEA Demo for PS Saturday Paris 2018'
    $SessionType = 'RestrictedRemoteServer'
    

    $Roles = @{
        "psaturday\SqlOperators" = @{ RoleCapabilities = "DbAdmin" }
        "psaturday\WebOperator" = @{ RoleCapabilities = "WebAdmin" }
    }



New-PSSessionConfigurationFile -Path $PSSCPathFile -Author $Author -Description $Description -TranscriptDirectory $TranscriptPath -RunAsVirtualAccount  -SessionType $SessionType  -RoleDefinitions $Roles -Full


Register-PSSessionConfiguration -Path $PSSCPathFile -Name 'JeaDemo'


# Demo Luke (DB) Dorothy (Web)
Enter-PSSession -ComputerName satwebsql01 -ConfigurationName 'JeaDemo'

# Cleanup 
Get-PSSessionConfiguration -name JeaDemo | Unregister-PSSessionConfiguration
remove-item $PSSCPathFile -force
