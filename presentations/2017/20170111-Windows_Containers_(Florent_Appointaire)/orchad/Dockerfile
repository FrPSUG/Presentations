FROM microsoft/iis:latest
MAINTAINER Florent APPOINTAIRE <florent.appointaire@gmail.com>
RUN powershell -command \
  Install-WindowsFeature Web-Asp-Net45,Web-Net-Ext45; \
  New-Item -Path C:\Temp -ItemType Directory; \
  wget -Uri https://github.com/OrchardCMS/Orchard/releases/download/1.10.1/Orchard.Web.zip -OutFile C:\temp\Orchard.Web.zip; \
  Expand-Archive -Path C:\temp\Orchard.Web.zip -DestinationPath C:\inetpub\wwwroot; \
  Remove-Item -Path C:\temp\Orchard.Web.zip; \
  Remove-Website -Name 'Default Web Site' ; \
  New-Website -Name Orchard -Port 80 -PhysicalPath C:\inetpub\wwwroot\Orchard; \
  C:\Windows\System32\icacls.exe C:\inetpub\wwwroot\Orchard\App_Data /grant IIS_IUSRS:`(OI`)`(CI`)F /T; \
  C:\Windows\System32\icacls.exe C:\inetpub\wwwroot\Orchard\Modules /grant IIS_IUSRS:`(OI`)`(CI`)F /T; \
  C:\Windows\System32\icacls.exe C:\inetpub\wwwroot\Orchard\Media /grant IIS_IUSRS:`(OI`)`(CI`)F /T; \
  C:\Windows\System32\icacls.exe C:\inetpub\wwwroot\Orchard\Themes /grant IIS_IUSRS:`(OI`)`(CI`)F /T; \
  iisreset
EXPOSE 80