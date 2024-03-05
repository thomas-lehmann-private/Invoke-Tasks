Register-AnalyseTask -Name "Analyze Line Length" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration
    $maximumLineLength = $TaskData.analyseConfiguration.'Analyze Line Length'.MaximumLineLength
    $predicate = {$args[0] -is [System.Management.Automation.Language.StatementAst]}
    $results = $ScriptBlockAst.FindAll($predicate, $true) | ForEach-Object {
        if ($_.Extent.EndColumnNumber -gt $maximumLineLength) {
            [PSCustomObject] @{
                File = $PathAndFileName
                Line = $_.Extent.StartLineNumber
                Column = $_.Extent.StartColumnNumber
                Message = "Line too long (exceeds {0})" -f $maximumLineLength
                Severity = 'information'
                Code = $_.Extent.Text
            }
        }
    }
    
    # for each line number take first reported problem only
    $results = $results | Group-Object Line | ForEach-Object {
        $_.Group | Select-Object -First 1
    }

    $TaskData.analyseResults += $results
}
