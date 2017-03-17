$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root = Split-Path -Path $here -Parent
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
$script = Join-Path -Path $Root -ChildPath "script\$sut"
$scriptName = $sut.Split('.')[0]

$ErrorActionPreference = 'Stop'

$company = 'FRPSUG'

Describe 'Company rules' -Tags 'Company', 'QA' {
    Context 'Validation' {
        BeforeAll {
            $scriptinfo = Test-ScriptFileInfo -Path $script -ErrorAction SilentlyContinue
        }        
        It 'has a valid name' {
            $scriptinfo.Name | Should Be $scriptName
        }
        It 'has a valid version' {
            $scriptinfo.Version -as [Version] | Should Not BeNullOrEmpty
        }
        It 'has a valid description' {
            $scriptinfo.Description | Should Not BeNullOrEmpty
        }
        It 'has a valid author' {
            $scriptinfo.Author | Should Not BeNullOrEmpty
        }
        It 'has a valid company' {
            $scriptinfo.companyName | Should Not BeNullOrEmpty
        }
        It "has the company set to $company" {
            $scriptinfo.CompanyName | Should be $company
        }
        It 'has a valid guid' {
            { [guid]::Parse($scriptinfo.Guid) } | Should Not throw
        }
        It 'has a valid copyright' {
            $scriptinfo.CopyRight | Should Not BeNullOrEmpty
        }
        It 'has tags for PSGallery' {
            $scriptinfo.Tags.count | Should Not BeNullOrEmpty 
        }
    }#end context validation
    Context 'ScriptAnalyzer' {
        It 'Passes the PSScriptAnalyzer Rules' {
             $PSScriptAnalyzerErrors = Invoke-ScriptAnalyzer -path $script -Recurse -ErrorAction SilentlyContinue
            if ($PSScriptAnalyzerErrors -ne $null) {
                @($PSScriptAnalyzerErrors).Foreach( { Write-Warning -Message "$($_.Scriptname) (Line $($_.Line)): $($_.Message)" } )
                @($PSScriptAnalyzerErrors).Count | Should Be 0
            }
       }         
    } #end context scriptanalyzer
} #end describe

