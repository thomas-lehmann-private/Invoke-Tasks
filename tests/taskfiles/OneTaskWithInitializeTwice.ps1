Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    $TaskData.analyseConfiguration = @{
        Global = @{
            AnalyzePathAndFileNames = @('./tests/taskfiles/OneTaskWithInitializeTwice.ps1')
        }
        'Analyze Line Length' = @{
            MaximumLineLength = 60
        }
    }
}

Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    $TaskData.analyseConfiguration = @{
        Global = @{
            AnalyzePathAndFileNames = @('./tests/taskfiles/OneTaskWithInitializeTwice.ps1')
        }
        'Analyze Line Length' = @{
            MaximumLineLength = 60
        }
    }
}

Register-Task -Name "First Task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'hello world!'
    $TaskData.Count += 1
}
