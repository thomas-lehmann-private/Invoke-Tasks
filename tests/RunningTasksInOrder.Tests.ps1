Describe "Running tasks in order" {
    It "Just one task" {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/OneTask.ps1 `
            -TaskData $taskData
        # running successful
        $taskData.Results | Should -BeExactly @('hello world!')
        $taskData.Count | Should -Be 1
    }

    It "Two tasks" {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/TwoTasks.ps1 `
            -TaskData $taskData `
            -Quiet # hide tool ouptu
        # running successful
        $taskData.Results | Should -BeExactly @('first task', 'second task')
        $taskData.Count | Should -Be 2
    }
}
