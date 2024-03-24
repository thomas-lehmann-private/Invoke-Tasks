Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    # define files to analyze
    $files = @($PSScriptRoot + '/TooManyLinesInBlock.ps1')
    $TaskData.analyseConfiguration = @{
        Global = @{ # adjust files to analyze
            AnalyzePathAndFileNames = $files
        }
    }
}

Register-Task -Name "First Task" {
    param ([hashtable] $TaskData)
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
    # test
}
