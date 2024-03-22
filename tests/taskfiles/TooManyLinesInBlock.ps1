Initialize-AnalyseTask {
    param ([hashtable] $TaskData)

    $files = @($PSScriptRoot + '/TooManyLinesInBlock.ps1')
    $TaskData.analyseConfiguration = @{
        Global = @{
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
