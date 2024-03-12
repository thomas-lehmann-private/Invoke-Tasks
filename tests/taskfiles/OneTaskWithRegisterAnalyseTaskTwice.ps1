Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    $TaskData.analyseConfiguration = @{
        Global = @{
            AnalyzePathAndFileNames = @('./tests/taskfiles/OneTaskWithAnalyse.ps1')
        }
        AnalyzeLineLength = @{
            MaximumLength = 60
        }
    }
}

Register-AnalyseTask -Name "Analyze Anything" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )

    $TaskData.analyseResults += [PSCustomObject] @{
        File = $PathAndFileName
        Line = 1
        Column = 1
        Message = "Test message 1"
        Severity = 'test'
        Code = "no code"
    }
}

Register-AnalyseTask -Name "Analyze Anything" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )

    $TaskData.analyseResults += [PSCustomObject] @{
        File = $PathAndFileName
        Line = 1
        Column = 1
        Message = "Test message 2"
        Severity = 'test'
        Code = "no code"
    }
}

Register-Task -Name "First Task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'hello world!'
    $TaskData.Count += 1
}
