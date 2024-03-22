Describe "Checking for ignores" {
    It "AnalyzeScriptBlockLineCount normal" {
        $taskData = @{}
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/TooManyLinesInBlock.ps1 `
            -TaskData $taskData `
            -TaskLibraryPath ./library `
            -Quiet

        $taskData.analyseResults.Count | Should -Be 1
    }

    It "AnalyzeScriptBlockLineCount ignored" {
        $taskData = @{}
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/TooManyLinesInBlockIgnored.ps1 `
            -TaskData $taskData `
            -TaskLibraryPath ./library `
            -Quiet

        $taskData.analyseResults.Count | Should -Be 0
    }
}
