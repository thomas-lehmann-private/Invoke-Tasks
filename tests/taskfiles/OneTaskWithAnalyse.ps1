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

Register-Task -Name "First Task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'hello world!'
    $TaskData.Count += 1
}
