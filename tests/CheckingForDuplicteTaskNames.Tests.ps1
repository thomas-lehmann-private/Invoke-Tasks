Describe "Checking for duplicate task names" {
    It "Duplicate task names" {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/DuplicateTaskNames.ps1 `
            -TaskData $taskData `
            -Quiet # hide tool outut
        # tool should finish with exit code
        $LASTEXITCODE | Should -Be 1
        $taskData.Results | Should -BeExactly @() # there should be no result
        $taskData.Count | Should -Be 0
    }

}
