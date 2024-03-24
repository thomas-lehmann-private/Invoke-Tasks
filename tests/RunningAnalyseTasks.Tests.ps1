Describe "Running Analyse Tasks Tests" {
    It "Testing with no task initialization" -Tag analyse {
        $taskData = @{} # initial task data
        ./Invoke-Tasks.ps1  `
            -TaskData $taskData `
            -TaskFile tests/taskfiles/OneTask.ps1 `
            -TaskLibraryPath ./library/analyse-task-library-1.ps1 `
            -Quiet # hide tool output
        # no error found since there wasn't any initialize code
        $taskData.privateContext.errorFound | Should -Be $false
    }

    It "Testing with task initialization" -Tag analyse {
        $taskData = @{} # initialize task data
        ./Invoke-Tasks.ps1  `
            -TaskData $taskData `
            -TaskFile tests/taskfiles/OneTaskWithAnalyse.ps1 `
            -TaskLibraryPath ./library `
            -Quiet # hide tool output
        # normal error behavior when all initialize/register analyze is done correctly
        $taskData.privateContext.errorFound | Should -Be $true
        $TaskData.analyseResults.Count | Should -Be 1
        # the line that is too long
        $TaskData.analyseResults[0].Line | Should -Be 6
    }

    It "Testing with analyse task initialization twice" -Tag analyse {
        $taskData = @{} # initial task data
        ./Invoke-Tasks.ps1  `
            -TaskData $taskData `
            -TaskFile tests/taskfiles/OneTaskWithInitializeTwice.ps1 `
            -TaskLibraryPath ./library `
            -Quiet # hide tool output
        # tool should finish with an error
        $taskData.privateContext.errorFound | Should -Be $true
        $TaskData.analyseResults.Count | Should -Be 0
    }

    It "Testing with task registration twice" -Tag analyse {
        $taskData = @{} # initial task data
        ./Invoke-Tasks.ps1  `
            -TaskData $taskData `
            -TaskFile tests/taskfiles/OneTaskWithRegisterAnalyseTaskTwice.ps1 `
            -TaskLibraryPath ./library `
            -Quiet # hide tool output
        # tool should finiah with an error
        $taskData.privateContext.errorFound | Should -Be $true
        $taskData.analyseResults.Count | Should -Be 2
        $taskData.analyseResults[1].Message | Should -Be "Test message 1" # second one ignored
    }
}
