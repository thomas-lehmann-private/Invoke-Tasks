Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    # define files to analyze
    $TaskData.analyseConfiguration = @{
        Global = @{ # adjust files to analyze
            AnalyzePathAndFileNames = @($PSCommandPath)
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
