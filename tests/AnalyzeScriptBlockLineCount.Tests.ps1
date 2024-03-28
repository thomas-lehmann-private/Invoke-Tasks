Describe "Checking for ScriptBlockLineCount" {
    It "AnalyzeScriptBlockLineCount normal" {
        $taskData = @{} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/static-code-analysis/TooManyLinesInBlock.ps1 `
            -TaskData $taskData `
            -TaskLibraryPath ./library `
            -Quiet # hide tool output
        # should be one issue
        $taskData.analyseResults.Count | Should -Be 1
    }

    It "AnalyzeScriptBlockLineCount ignored" {
        $taskData = @{} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/static-code-analysis/TooManyLinesInBlockIgnored.ps1 `
            -TaskData $taskData `
            -TaskLibraryPath ./library `
            -Quiet # hide tool output
        # should be no issue since ignored
        $taskData.analyseResults.Count | Should -Be 0
    }
}
