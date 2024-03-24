Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    # define configuration
    $TaskData.analyseConfiguration = @{
        Global = @{ # configure files to analyze
            AnalyzePathAndFileNames = @('./tests/taskfiles/OneTaskWithAnalyse.ps1')
        }
        AnalyzeLineLength = @{
            MaximumLength = 60 # overwrite value
        }
    }
}

Register-Task -Name "First Task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'hello world!' # test result
    $TaskData.Count += 1
}
