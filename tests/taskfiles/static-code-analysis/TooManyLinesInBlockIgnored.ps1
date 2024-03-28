Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    # define files to analyze
    $TaskData.analyseConfiguration = @{
        Global = @{ # adjust files to analyze
            AnalyzePathAndFileNames = @($PSCommandPath)
        }
    }
}

# ignore AnalyzeScriptBlockLineCount on line 12 because this is an acceptable exception
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
