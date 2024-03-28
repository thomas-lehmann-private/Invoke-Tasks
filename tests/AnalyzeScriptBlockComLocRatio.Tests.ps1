Describe "Checking for ScriptBlockComLocRation" {
    It "AnalyzeScriptBlockComLocRatio normal" -Tag comlocratio {
        $taskData = @{} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/static-code-analysis/TooLessCommentsInBlock.ps1 `
            -TaskData $taskData `
            -TaskLibraryPath ./library `
            -Quiet # hide tool output
        # should be one issue
        $taskData.analyseResults.Count | Should -Be 1
    }
}
