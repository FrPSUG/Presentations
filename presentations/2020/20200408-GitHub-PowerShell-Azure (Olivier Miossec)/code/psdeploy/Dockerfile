FROM mcr.microsoft.com/azure-powershell:3.6.1-ubuntu-18.04

ENV PSModulePath /usr/local/share/powershell/Modules:/opt/microsoft/powershell/7/Modules:/root/.local/share/powershell/Modules

ADD entrypoint.ps1 /entrypoint.ps1

ENTRYPOINT ["pwsh", "/entrypoint.ps1"]

