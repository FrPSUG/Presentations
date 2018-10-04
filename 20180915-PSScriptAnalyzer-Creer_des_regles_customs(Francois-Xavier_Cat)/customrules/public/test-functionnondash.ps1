function test-functionnondash
{
    [CmdletBinding()]
    Param($ScriptBlockAst)
    
    process {
        try{
            $functions = $ScriptBlockAst.FindAll(
                {
                    $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                    $args[0].name -notmatch '-'},$true)

            foreach ($Func in $functions){
                [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                    Message = "No Dash found in the function name '$($Func.name)'. Please follow the '<VERB>-<NOUN>' standard"
                    Extent  = $function.Extent
                    RuleName = $PSCmdlet.MyInvocation.MyCommand.Name
                    Severity = "Warning"
                }
            }
        }
        catch{$PSCmdlet.ThrowTerminatingError($_)}
    }
}