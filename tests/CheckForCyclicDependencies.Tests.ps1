Describe "Checking for cyclic dependencies" {
    It "Two tasks depend on each other" {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/CyclicDependencies.ps1 `
            -TaskData $taskData `
            -Quiet # hide task output
        $LASTEXITCODE | Should -Be 1
        $taskData.Results | Should -BeExactly @() # there should be no results
        $taskData.Count | Should -Be 0 # there should be no results
    }
}
