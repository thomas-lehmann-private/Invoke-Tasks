Register-AnalyseTask -Name "Analyze Line Length" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration or set default
    $maximumLineLength = if ($TaskData.analyseConfiguration.'Analyze Line Length') {
        $TaskData.analyseConfiguration.'Analyze Line Length'.MaximumLineLength
    } else {
        100
    }
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

Register-AnalyseTask -Name "Analyze Function Count" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration
    $maximumFunctionCount = if ($TaskData.analyseConfiguration.'Analyze Function Count') {
        $TaskData.analyseConfiguration.'Analyze Function Count'.MaximumFunctionCount
    } else {
        20
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)
    $results = @()

    if ($functions.Count -gt $maximumFunctionCount) {
        $results += [PSCustomObject] @{
            File = $PathAndFileName
            Line = 1
            Column = 1
            Message = "Too many functions ({0} exceeds {1})" `
                -f $functions.Count, $maximumFunctionCount
            Severity = 'information'
            Code = ""
        }
    }

    $TaskData.analyseResults += $results
}
