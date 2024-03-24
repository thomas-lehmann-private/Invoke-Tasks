Initialize-AnalyseTask {
    param ([hashtable] $TaskData)
    # define files to analyze
    $files = @($PSScriptRoot + '/TooManyLinesInBlockIgnored.ps1')
    $TaskData.analyseConfiguration = @{
        Global = @{ # adjust files to analyze
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
