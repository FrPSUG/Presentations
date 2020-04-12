# PowerShell Lightning demos
# Autorest.PowerShell 
# Olivier Miossec (@omiossec_med)

Generate a PowerShell module from OpenAPI Specification File with [Autorest](https://github.com/Azure/autorest/blob/master/README.md) and [Autorest.PowerShell](https://github.com/Azure/autorest.powershell)

We will use the Near Earth Object API from [CNEOS-JPL](https://cneos.jpl.nasa.gov/)

The Api is located at this URI https://api.nasa.gov/neo/?api_key=DEMO_KEY



# Demo

## Run Autorest with powershell

autorest --powershell --input-file=neo\jpl-neo.yml --output-folder=module --namespace=frpsug


## Add  functions and costum c# files

copy-item -Path .\module.cs -Destination .\module\custom\module.cs
copy-item -Path .\find-armagedon.ps1 -Destination .\module\custom\find-armagedon.ps1




## Compile and run the module 

.\module\build-module.ps1 -Run 



get-module 

get-command -module jplneo

get-help 

Invoke-CurrentNeoStatistics

(Invoke-BrowseNeoObject -Page 0 -Size 2).NearEarthObjects

find-armagedon