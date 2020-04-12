function Test-parametermissing
{
    [CmdletBinding()]
    param(
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScripBlockAST
    )
    Process{
        try{
            # Script Analyzer is launched against the full script, then each functions. Quit when looking at functions
            if($ScripBlockAST[0].Extent.Text[0] -eq '{')
            {
                Return
            }

            # Find all the commands in the script
            $CommandAST = $ScripBlockAST.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)

            foreach ($CurrentCommand in $CommandAST)
            {
                #Skip Dot Sourced commands
                if($CurrentCommand -notmatch '^\..+ps1|^\..+psm1|^&|^\.')
                {
                    # Retrieve all the parameters
                    $Parameters = [System.Management.Automation.Language.StaticParameterBinder]::BindCommand($CurrentCommand)

                    foreach ($CurrentParameter in ($Parameters.BoundParameters.Keys)){
                        if($CurrentCommand.tostring() -notmatch "\s-$CurrentParameter" -and
                        $CurrentCommand.tostring() -notmatch ' @' -and
                        "-$CurrentParameter" -notmatch "^-([0-9]{1})"){

                            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                            Message = "Missing Named parameter '-$CurrentParameter' on the following command '$CurrentCommand'"
                            Extent  = $CurrentCommand.Extent
                            RuleName = $PSCmdlet.MyInvocation.MyCommand.Name
                            Severity = "Warning"
                            }
                        }
                    } #foreach
                }#skip
            }# foreach
        }catch{
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}