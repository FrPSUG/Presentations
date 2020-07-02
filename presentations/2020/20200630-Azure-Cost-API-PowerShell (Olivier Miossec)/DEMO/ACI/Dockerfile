FROM mcr.microsoft.com/powershell:latest
LABEL description="Demo Azure ACI With PowerShell UD" 

RUN pwsh -c Install-module  UniversalDashboard.Community -AllowPrerelease -AcceptLicense -Force 
 

ENV UdPort=8000
ENV UdAPIPort=1001
ENV UdAPIURL=omcdemoaci-api

EXPOSE 8000

ADD entrypoint.ps1 /entrypoint.ps1

ENTRYPOINT ["pwsh", "/entrypoint.ps1"]