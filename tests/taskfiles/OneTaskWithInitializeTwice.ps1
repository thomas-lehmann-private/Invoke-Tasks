Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    $TaskData.analyseConfiguration = @{
        Global = @{ # define files to analyze
            AnalyzePathAndFileNames = @('./tests/taskfiles/OneTaskWithInitializeTwice.ps1')
        }
        AnalyzeLineLength = @{
            MaximumLength = 60 # overwrite default value
        }
    }
}

Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    $TaskData.analyseConfiguration = @{
        Global = @{ # define file to analyze
            AnalyzePathAndFileNames = @('./tests/taskfiles/OneTaskWithInitializeTwice.ps1')
        }
        AnalyzeLineLength = @{
            MaximumLength = 60 # overwrite default value
        }
    }
}

Register-Task -Name "First Task" {
    param ([hashtable] $TaskData)
    $TaskData.Results += 'hello world!' # a simple test code
    $TaskData.Count += 1
}
