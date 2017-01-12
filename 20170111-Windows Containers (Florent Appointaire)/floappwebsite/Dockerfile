FROM microsoft/iis
MAINTAINER Florent APPOINTAIRE <florent.appointaire@gmail.com>
RUN mkdir C:\site
RUN powershell -NoProfile -Command \
    Import-module IISAdministration; \
    New-IISSite -Name "Site" -PhysicalPath C:\site -BindingInformation "*:8080:"
COPY index.html C:\site
EXPOSE 8080