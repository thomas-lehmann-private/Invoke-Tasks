Describe "Checking for duplicate task names" {
    It "Duplicate task names" {
        $taskData = @{Count = 0; Results = @()}
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/DuplicateTaskNames.ps1 `
            -TaskData $taskData `
            -Quiet

        $LASTEXITCODE | Should -Be 1
        $taskData.Results | Should -BeExactly @()
        $taskData.Count | Should -Be 0
    }

}
