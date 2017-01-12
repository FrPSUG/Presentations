#region Demo01: Install Containers on Windows Server
Install-WindowsFeature Containers
Restart-Computer
#endregion

#region Demo02: Install Docker on Windows Server 2016
#Download the last version of Docker (mandatory to use SQL Server image, etc.)
Invoke-WebRequest " https://master.dockerproject.org/windows/amd64/docker-1.14.0-dev.zip" -OutFile "$env:TEMP\docker.zip" –UseBasicParsing
#Extract the archive
Expand-Archive -Path "$env:TEMP\docker.zip" -DestinationPath $env:ProgramFiles
#Set an environment variable
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Docker", [EnvironmentVariableTarget]::Machine)
#Register the docker as a Windows Service
C:\ProgramFiles\docker\dockerd.exe --register-service
#Start the Docker Service
Start-Service Docker
#endregion

#region Demo03: Show DockerHub
#endregion

#region Demo04: Create your first container
#Create your first IIS container
Docker run -d -p 8080:80 --name iis microsoft/iis
#endregion