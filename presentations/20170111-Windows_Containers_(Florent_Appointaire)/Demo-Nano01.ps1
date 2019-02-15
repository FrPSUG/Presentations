#region Demo01: Install Nano Server
# Connection to the NanoServer
$cred = Get-Credential Administrator
Set-Item WSMan:\localhost\Client\TrustedHosts 10.0.2.29 -Force
Enter-PSSession -ComputerName 10.0.2.29 -Credential $cred
Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses 10.0.2.100

#Windows Updates
$sess = New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession
Invoke-CimMethod -InputObject $sess -MethodName ApplyApplicableUpdates
#After updates installed successfully
Restart-Computer
#endregion

#region Demo02: Install Docker on Nano Server
#Install Docker
Enter-PSSession -ComputerName 10.0.2.29 -Credential $cred
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider
Install-PackageProvider ContainerImage -Force
Restart-Computer -Force
#Check the docker service
Enter-PSSession -ComputerName 10.0.2.29 -Credential $cred
Get-Package
Get-Service -Name docker
Start-Service docker
#endregion

#region Demo03: Configure Docker
#Create rules to use docker remotely
netsh advfirewall firewall add rule name="Docker daemon " dir=in action=allow protocol=TCP localport=2375
#Configure docker to accept remote connections
new-item -Type File c:\ProgramData\docker\config\daemon.json
Add-Content 'c:\programdata\docker\config\daemon.json' '{ "hosts": ["tcp://0.0.0.0:2375", "npipe://"] }'
Restart-Service docker
Exit
#endregion

#region Demo04: Install Docker Client
#From the remote client
Invoke-WebRequest "https://download.docker.com/components/engine/windows-server/cs-1.12/docker.zip" -OutFile "$env:TEMP\docker.zip" -UseBasicParsing
Invoke-WebRequest "https://master.dockerproject.org/windows/amd64/docker-1.14.0-dev.zip" -OutFile "$env:TEMP\docker.zip" –UseBasicParsing
Expand-Archive -Path "$env:TEMP\docker.zip" -DestinationPath $env:ProgramFiles
# For quick use, does not require shell to be restarted.
$env:path += ";c:\program files\docker"
# For persistent use, will apply even after a reboot. 
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Docker", [EnvironmentVariableTarget]::Machine)
#endregion

#region Demo05: Connect to docker and create a container
#Connect to docker remotely
docker -H tcp://10.0.2.29:2375 run -it microsoft/nanoserver cmd
#Use docker host as environment variable
$env:DOCKER_HOST = "tcp://10.0.2.29:2375"
docker run -it microsoft/nanoserver cmd
#endregion