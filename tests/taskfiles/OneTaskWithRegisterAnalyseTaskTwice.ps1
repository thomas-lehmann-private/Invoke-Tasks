Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    $TaskData.analyseConfiguration = @{
        Global = @{ # configure files to analyze
            AnalyzePathAndFileNames = @('./tests/taskfiles/OneTaskWithAnalyse.ps1')
        }
        AnalyzeLineLength = @{
            MaximumLength = 60 # overwrite default
        }
    }
}

Register-AnalyseTask -Name "Analyze Anything" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # adding one issue
    $TaskData.analyseResults += [PSCustomObject] @{
        File = $PathAndFileName    # file that has been analyzed
        Line = 1                   # line of the issue
        Column = 1                 # column of the issue
        Message = "Test message 1" # test message
        Severity = 'test'          # severity of the issue
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
        File = $PathAndFileName     # file that has been analyzed
        Line = 1                    # line of the issue
        Column = 1                  # column of the issue
        Message = "Test message 2"  # test message
        Severity = 'test'           # severity of the issue
        Code = "no code"
    }
}

Register-Task -Name "First Task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'hello world!'
    $TaskData.Count += 1
}
