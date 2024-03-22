Initialize-AnalyseTask {
    param ([hashtable] $TaskData)

    $files = @($PSScriptRoot + '/TooManyLinesInBlockIgnored.ps1')
    $TaskData.analyseConfiguration = @{
        Global = @{
            AnalyzePathAndFileNames = $files
        }
    }
}

# ignore AnalyzeScriptBlockLineCount on line 13 because this is an acceptable exception
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
