Configuration Default {
    Node 'localhost' {
        # don't do it this way, this is only an illustration of the concepts
        Script DoSomething
            {
                GetScript = { 
                    Write-verbose 'Entering Get Script'
                    return @{ 'IsFilePresent' = (Test-Path 'C:\WinOps.txt') }
                }
                
                TestScript = {
                    # For Idempotence
                    if (Test-Path 'C:\WinOps.txt')
                    {
                        Write-Verbose -Message ('WinOps File is Present')
                        return $true
                    }
                    Write-Verbose -Message ('WinOps File is Absent')
                    return $false
                }
                
                SetScript = {
                    Write-verbose 'entering Set Script'
                    New-Item -Path 'C:\' -Name 'WinOps.txt' -Value 'DSC + Test-Kitchen Rocks'
                }
            }
            Script gotit
            {
                GetScript = { 
                    return @{ 'IsFilePresent' = (Test-Path 'C:\gotit.txt') }
                }
                
                TestScript = {
                    if (Test-Path 'C:\gotit.txt') { return $true }
                    return $false
                }
                
                SetScript = { New-Item -Path 'C:\' -Name 'gotit.txt' -Value 'someContent' -ItemType file }
            }
    }
}
