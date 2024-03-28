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
    # here we have comments
    # first loop should be no issue
    # last loop should raise an issue
    @("a", "b") | ForEach-Object {
        Write-Message $_
    }
    @("c", "d") | ForEach-Object {
        Write-Message $_
        Write-Message $_
        Write-Message $_
        Write-Message $_
    }
}