Describe 'checking File Exists' {
    it 'Should resolve to C:\WinOps.txt' {
        { Resolve-Path C:\WinOps.txt -ErrorAction Stop } | should not Throw
    }
    it 'Should resolve to C:\gotit.txt' {
        { Resolve-Path C:\gotit.txt -ErrorAction Stop } | should not Throw
    }
}