Describe "Checking for cyclic dependencies" {
    It "Two tasks depend on each other" {
        $taskData = @{Count = 0; Results = @()}
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/CyclicDependencies.ps1 `
            -TaskData $taskData `
            -Quiet
        $LASTEXITCODE | Should -Be 1
        $taskData.Results | Should -BeExactly @()
        $taskData.Count | Should -Be 0
    }
}
