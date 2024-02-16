Describe "Running tasks by dependency" {
    It "First task depends on second" {
        $taskData = @{Count = 0; Results = @()}
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/FirstTaskDependsOnSecondOne.ps1 `
            -TaskData $taskData `
            -Quiet

        $taskData.Results | Should -BeExactly @('second task', 'first task')
        $taskData.Count | Should -Be 2
    }
}
