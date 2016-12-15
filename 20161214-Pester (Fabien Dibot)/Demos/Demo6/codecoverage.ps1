Function Do-UnTruc {
    $output =@()

    $a = Get-WmiObject -Class Win32_OperatingSystem

    $output += [psobject]@{'Version'=$a.version
                    'BuildType'=$a.BuildType}

    Return $output
}

Function Do-Sometest {
    Return "Ok dude!"
}