$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Fonction Do-Untruc" {
    It "Doit retourner un hashtable" {
        Do-UnTruc | should BeOfType System.Collections.Hashtable
    }

    It "Ne doit pas exploser en plein vol" {
        {Do-UnTruc} | Should Not Throw
    }

    It "La version doit être OK" {
        (Do-UnTruc).Version | Should be "10.0.14393"
    }
}
