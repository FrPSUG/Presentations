<#
    Creer vos regles customs PSSCriptAnalyzer
    French PowerShell Saturday Paris (15 Sept 2018)
#>

$DemoPath = ".\201809-French_PowerShell_User_Group\"

################################
# PSScriptAnalyzer ?
################################
# PSScriptAnalyzer fournit une analyse de script et
# vérifie les éventuels défauts de code dans les scripts
# en appliquant un groupe de règles intégrées ou
# personnalisées aux scripts analysés.

#######################
# Install/Usage
#######################
Install-Module -Name PSScriptAnalyzer -Force CurrentUser
Import-Module -Name PSScriptAnalyzer -PassThru
Get-Command -Module PSScriptAnalyzer


#Liste des builtin rules
Get-ScriptAnalyzerRule | select * | Out-GridView 


# Utiliser les regles de bases
ise $DemoPath\scripts\MyScript2.ps1
Invoke-ScriptAnalyzer -Path $DemoPath\scripts\MyScript2.ps1
Invoke-ScriptAnalyzer -Path $DemoPath\scripts\MyScript2.ps1 -Severity Warning
Invoke-ScriptAnalyzer -Path $DemoPath\scripts\MyScript2.ps1 -IncludeRule PSAvoidUsingCmdletAliases
Invoke-ScriptAnalyzer -Path $DemoPath\scripts\MyScript2.ps1 -IncludeRule PSAvoidUsingPlainTextForPassword
Invoke-ScriptAnalyzer -Path $DemoPath\scripts\MyScript2.ps1 -IncludeRule PSAvoidUsingPlainTextForPassword,PSAvoidUsingCmdletAliases

# Utiliser les settings
#  examples disponible ici:
# $home\Documents\WindowsPowerShell\Modules\PSScriptAnalyzer\1.17.1\Settings
gci "$home\Documents\WindowsPowerShell\Modules\PSScriptAnalyzer\1.17.1\Settings"
Invoke-ScriptAnalyzer -Path $DemoPath\scripts\MyScript2.ps1 -Settings CodeFormatting

$settings = @{
    IncludeRules = @(
        'PSPlaceOpenBrace',
        'PSPlaceCloseBrace',
        'PSUseConsistentWhitespace',
        'PSUseConsistentIndentation',
        'PSAlignAssignmentStatement'
    )

    Rules        = @{
        PSPlaceOpenBrace           = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }

        PSPlaceCloseBrace          = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }

        PSUseConsistentIndentation = @{
            Enable          = $true
            Kind            = 'space'
            IndentationSize = 4
        }

        PSUseConsistentWhitespace  = @{
            Enable         = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator  = $true
            CheckSeparator = $true
        }

        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $true
        }
    }
}
Invoke-ScriptAnalyzer -Path $DemoPath\scripts\MyScript2.ps1 -Settings $settings

# Rule documentations:
# https://github.com/PowerShell/PSScriptAnalyzer/tree/development/RuleDocumentation

#######################
# Invoke-Formatter
#######################
Get-Help invoke-formatter -ShowWindow

# Example of code
$Code = @'
<#
.SYNOPSIS
    Test script for PSScriptAnalyzer
#>
[CmdletBinding()]
param($File,$credential)
Try{
function QuickInventory{
param([string[]]$Computers)
$Computers|% -Proc {
if(Test-Connection $Comp -Quiet){
    gwmi `
    -class win32_ComputerSystem `
    -Credential $credential
}
}
}

QuickInventory -Comp (gc $File)
}catch{throw $_}
'@

# Check default formatting
Invoke-Formatter
invoke-formatter -ScriptDefinition $code

# Specify our settings
invoke-formatter -ScriptDefinition $code -Settings @{
        IncludeRules = @("PSPlaceOpenBrace", "PSUseConsistentIndentation")
        Rules = @{
            PSPlaceOpenBrace = @{
                Enable = $true
                OnSameLine = $false
            }
            PSUseConsistentIndentation = @{
                Enable = $true
            }
        }
    }

# Another example
$settings = @{
    IncludeRules = @(
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingEmptyCatchBlock',
        'PSAvoidUsingPositionalParameters',
        'PSAvoidUsingWMICmdlet',
        'PSAvoidUsingWriteHost',
        'PSMisleadingBacktick',
        'PSPlaceCloseBrace',
        'PSPlaceOpenBrace',
        'PSReservedCmdletChar',
        'PSReservedParams',
        'PSUseConsistentIndentation',
        'PSUseConsistentWhitespace'
    )

    Rules = @{
        PSAvoidUsingCmdletAliases = @{
            Enable = $true
            Whitelist = @('')
        }
        PSPlaceCloseBrace = @{
            Enable = $true
            NoEmptyLineBefore = $true
            IgnoreOneLineBlock = $false
            NewLineAfter = $false
        }
        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $false
            IgnoreOneLineBlock = $false
            NewLineAfter = $true
        }
        PSUseConsistentIndentation = @{
            Enable = $true
            IndentationSize = 10
        }
        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckSeparator = $true
        }
    }
}

Invoke-Formatter -ScriptDefinition $code -Settings $settings
Invoke-Formatter -ScriptDefinition $code -Settings CodeFormattingAllman



#####################################
# Comment PSScriptAnalyzer fonction #
#####################################
# Abstrax syntax tree (AST)

# Different approaches possible.

#AST
$ScriptBlock = {
Param($File)
$Computers = Get-Content $File
    Foreach ($Comp in $Computers)
    {
        Test-Connection -ComputerName $Comp -Quiet
    }
}

# FIND A SPECIFIC TYPE
# Find Scripts parameters
$ScriptBlock.Ast.FindAll({$args[0] -is [System.Management.Automation.Language.ParameterAst]}, $true)
# Commands
$ScriptBlock.Ast.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]}, $true)
# Commands parameters
$ScriptBlock.Ast.FindAll({$args[0] -is [System.Management.Automation.Language.CommandParameterAst]}, $true)
# All Commands elements
$ScriptBlock.Ast.FindAll({$args[0] -is [System.Management.Automation.Language.CommandElementAst]}, $true)
# Variables
$ScriptBlock.Ast.FindAll({$args[0] -is [System.Management.Automation.Language.VariableExpressionAst]}, $true)


# Show the different classes
[System.Management.Automation.Language.




# Using PSParser
# Retrieve the content of the scripts
$Code = Get-Content (Resolve-Path $demopath\scripts\MyScript2.ps1)
# Use AST to parse the code
[System.Management.Automation.PSParser]::Tokenize($code,[ref]$Null)|ft -auto

# Using Parser
<#
$Code = Resolve-Path .\scripts\MyScript2.ps1
$AST = [System.Management.Automation.Language.Parser]::ParseFile($Code,[ref]$Null,[ref]$Null)
# Exploring the object
[System.Management.Automation.Language.Ast]$AST|gm

# Look for backtick
[System.Management.Automation.Language.Ast]$ast.Extent -match [char]96
[System.Management.Automation.Language.Ast]$ast.FindAll()
#>


# Using Helpers from the community

## IDENTIFIER UNE VIOLATION
# AST Helpers disponible
# Module ShowPSAst (Jason Shirk) - GUI
Install-Module -name ShowPSAst -Scope CurrentUser
Import-Module ShowPSAst -PassThru
Get-Help Show-Ast -show
Show-Ast $ScriptBlock

# Module ASTHelper (Thomas Rayner)
Install-Module -name ASTHelper -Scope CurrentUser # From Thomas Rayner
Import-Module -name ASTHelper
Get-Command -module asthelper
Get-AstType -ScriptPath $DemoPath\scripts\MyScript2.ps1


# ASTExplorer (GUI) (Zachary Loeber)
#https://github.com/lazywinadmin/ASTExplorer
.$DemoPath\tools\ASTExplorer.ps1


################################
# PSScriptAnalyzer - Creer vos propres regles
################################
# SCENARIO:
#  Identifier une violation
#  Retourner le probleme a l'ecran

Invoke-ScriptAnalyzer -Path $DemoPath\scripts\MyScript.ps1 -CustomRulePath $DemoPath\customrules\LWACustomRules.psd1
ise $DemoPath\customrules\LWACustomRules.psm1
ise $DemoPath\customrules\public\test-parametermissing.ps1
ise $DemoPath\customrules\public\test-functionnondash.ps1

Invoke-ScriptAnalyzer -Path $DemoPath\scripts\MyScript2.ps1 -CustomRulePath $DemoPath\customrules\LWACustomRules.psd1


# Properties available
[Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new
<#
     
- string message,
- System.Management.Automation.Language.IScriptExtent extent,
- string ruleName,                                                       
- Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticSeverity severity,
- string scriptPath,
- string ruleId,
- System.Collections.Generic.IEnumerable[Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent] suggestedCorrections
 
#>



# GOTCHAS
<#
-Custom rules need to be stored inside a module (psm1 file)
-Custom rules need to be defined inside functions
-Each functions must have one single parameter that finish by AST or TOKEN
-The function parameter type needs to be from the class: [System.Management.Automation.Language.*]
-Output Object [PSCustomObject] or [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]
-Output properties should be at least : Message, Extent, Rulename, Severity
-When using somthing like $ScriptBlockAST.FindAll( {$arg[0] -is [System.Management.Automation.Language.VariableExpressionAst]}, $false)
 the $false at the end specified if the lookup need to be recursive or not.
#>


# VSCODE
$DemoPath\vscode



# REFERENCE
# Rule documentations:
# https://github.com/PowerShell/PSScriptAnalyzer/tree/development/RuleDocumentation
# Settings: $home\Documents\WindowsPowerShell\Modules\PSScriptAnalyzer\