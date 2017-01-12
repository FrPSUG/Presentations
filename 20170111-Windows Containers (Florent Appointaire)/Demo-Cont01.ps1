#region Demo01: Deploy an IIS Server
#Check the hostname/ipconfig
docker run -d -p 8080:80 --name iis microsoft/iis
docker ps
docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" iis
#endregion

#region Demo02: Deploy a custom website
cd C:\Users\fappointaire\Desktop\floappwebsite
docker build -t floappwebsite .
docker images
docker run -d -p 8000:8080 --name PSUserGroupFR floappwebsite
docker ps
docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" PSUserGroupFR
#endregion

#region Demo03: Hyper-V Containers
#Container ephemeral with following parameters
docker run -it --rm images
#On the host, check th vm vmwp process CMD
powershell Get-Process -Name vmwp
docker run --rm -it --name nanohpv --isolation=hyperv microsoft/nanoserver:latest
#On the host, check th vm vmwp process CMD
powershell Get-Process -Name vmwp
docker run --rm -it --name nanohpv2 microsoft/nanoserver:latest
#On the host, check th vm vmwp process
powershell Get-Process -Name vmwp
#endregion

#region Demo04: Hyper-V Containers Isolation
#Same PID for the ping process
docker run -d --name pid1 microsoft/nanoserver:latest ping localhost -t
docker top pid1
powershell get-process -Name ping
#Due to isolation, impossible to get the process
docker stop pid1
docker run -d --name pid2 --isolation=hyperv microsoft/nanoserver:latest ping localhost -t
docker top pid2
powershell get-process -Name ping
powershell Get-Process -Name vmwp
docker stop pid2
powershell Get-Process -Name vmwp
#endregion

#region Demo05: Orchad multi containers
$password = Read-Host -Prompt "Enter password" -AsSecureString
$UserName = "flodu31"
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName, $password 
docker login -u $Credentials.GetNetworkCredential().UserName -p $Credentials.GetNetworkCredential().Password
#Change the name of the image
cd C:\Users\fappointaire\Desktop\orchad
docker build -t flodu31/orchardpsugfr:latest .
docker images
docker push flodu31/orchardpsugfr:latest
docker run -d -p 1433:1433 -v C:/temp/:C:/temp/ --env attach_dbs="[{'dbName':'Orchard','dbFiles':['C:\\Temp\\Orchard.mdf','C:\\Temp\\Orchard_log.ldf']}]" -e sa_password=Welcome123! -e ACCEPT_EULA=Y --name sqlserver microsoft/mssql-server-windows-express:latest 
docker run -d -p 80:80 --name orchardpsugfr --link sqlserver:sqlserver flodu31/orchardpsugfr
docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" orchardpsugfr
#Data Source=sqlserver;Initial Catalog=Orchard;User ID=sa;Password=Welcome123!;
docker exec -t -i orchardpsugfr cmd.exe
#endregion

#region Demo06: Docker-Compose
Invoke-WebRequest https://dl.bintray.com/docker-compose/master/docker-compose-Windows-x86_64.exe -UseBasicParsing -OutFile $env:ProgramFiles\docker\docker-compose.exe
cd C:\Users\fappointaire\Desktop\MusicStore
#Possible to build the docker-compose.yml if you have a dockerfile inside, build
docker-compose -f docker-compose.yml up
docker inspect -f "{{ .NetworkSettings.Networks.nat.IPAddress }}" musicstore_web_1
#endregion

#region Demo07: Test a linux image (doesn't work)
docker run --name wordpress --link mysql:mysql -d wordpress -p 81:80 -e WORDPRESS_DB_PASSWORD=Test123!
#endregion

#region Demo08: Image2Docker
Install-Module Image2Docker
ConvertTo-Dockerfile -ImagePath C:\Temp\FLOAPP-IIS01_OS.vhdx -OutputPath C:\Temp\GlobalIIS -Artifact IIS -Verbose
ConvertTo-Dockerfile -ImagePath C:\Temp\FLOAPP-IIS01_OS.vhdx -OutputPath C:\Temp\WebApiApp -Artifact IIS -ArtifactParam WebApiApp -Verbose
cd C:\Temp\WebApiApp
docker build -t florentapp/webapiapp .
docker run -d -p 8080:8080 --name webapiapp florentapp/webapiapp
docker logs webapiapp
docker inspect webapiapp
#endregion