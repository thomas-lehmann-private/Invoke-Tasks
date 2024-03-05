Describe "Running Analyse Tasks Tests" {
    It "Testing with no task initialization" -Tag analyse {
        $taskData = @{}
        ./Invoke-Tasks.ps1  `
            -TaskData $taskData `
            -TaskFile tests/taskfiles/OneTask.ps1 `
            -TaskLibraryPath ./library/analyse-task-library-1.ps1 `
            -Quiet

        $taskData.privateContext.errorFound | Should -Be $false
    }

    It "Testing with task initialization" -Tag analyse {
        $taskData = @{}
        ./Invoke-Tasks.ps1  `
            -TaskData $taskData `
            -TaskFile tests/taskfiles/OneTaskWithAnalyse.ps1 `
            -TaskLibraryPath ./library/analyse-task-library-1.ps1 `
            -Quiet

        $taskData.privateContext.errorFound | Should -Be $true
        $TaskData.analyseResults.Count | Should -Be 1
        # the line that is too long
        $TaskData.analyseResults[0].Line | Should -Be 5
    }

    It "Testing with analyse task initialization twice" -Tag analyse {
        $taskData = @{}
        ./Invoke-Tasks.ps1  `
            -TaskData $taskData `
            -TaskFile tests/taskfiles/OneTaskWithInitializeTwice.ps1 `
            -TaskLibraryPath ./library/analyse-task-library-1.ps1 `
            -Quiet

        $taskData.privateContext.errorFound | Should -Be $true
        $TaskData.analyseResults.Count | Should -Be 0
    }

    It "Testing with task registration twice" -Tag analyse {
        $taskData = @{}
        ./Invoke-Tasks.ps1  `
            -TaskData $taskData `
            -TaskFile tests/taskfiles/OneTaskWithRegisterAnalyseTaskTwice.ps1 `
            -TaskLibraryPath ./library/analyse-task-library-1.ps1 `
            -Quiet

        $taskData.privateContext.errorFound | Should -Be $true
        $TaskData.analyseResults.Count | Should -Be 2
        $TaskData.analyseResults[1].Message | Should -Be "Test message 1"
    }
}
