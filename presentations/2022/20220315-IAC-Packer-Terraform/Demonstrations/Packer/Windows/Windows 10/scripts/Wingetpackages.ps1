#Declare Winget Applications Id
Invoke-CommandAs -ScriptBlock { 

    $Applications =(
        "7zip.7zip",
        "Microsoft.WindowsTerminal",
        "Git.Git",
        "Microsoft.PowerShell"
    )
    
    $Parameters = "install -e --id "
    
  $EXE =  $(where.exe winget)
    
        foreach ($item in $Applications) {
            
            $Arguments = $Parameters + $item
            
            Start-Process "c:\Users\Administrator\AppData\Local\Microsoft\WindowsApps\winget.exe" -ArgumentList $Arguments -Wait
        }
 } -AsInteractive 'Administrator'

