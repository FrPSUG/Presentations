$ModuleName = "<%= $PLASTER_PARAM_ModuleName %>"
$ModuleAuthor = "<%= $PLASTER_PARAM_AuthorName %>"

$PublicFunctions = @(Get-ChildItem -Path $PSScriptRoot\Sources\Public\*.ps1  -ErrorAction SilentlyContinue | Select-object -Expand FullName) 
$PrivateFunctions = @(Get-ChildItem -Path $PSScriptRoot\Sources\Private\*.ps1 -ErrorAction SilentlyContinue | Select-Object -Expand FullName) 
 
 #Dot source the files 
Foreach ($import in @($PublicFunctions + $PrivateFunctions )) { 
    TRY { 
        . $import
    } 
    CATCH { 
        Write-Error -Message "Failed to import function $($import): $_" 
    } 
} 