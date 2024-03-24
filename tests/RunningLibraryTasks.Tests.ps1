Describe "Running library tasks" {
    It "Running tasks including dependencies inside library" -Tag library {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/UsingLibraryTasks.ps1 `
            -TaskLibraryPath tests/taskfiles/TaskLibrary.ps1 `
            -TaskData $taskData `
            -Quiet # hide tool output
        # running without problems
        $expected = @('hello world!', 'another hello world!', 'another hello world 2!')
        $taskData.Results | Should -BeExactly $expected
        $taskData.Count | Should -Be 3
    }

    It "Missing dependency inside library" -Tag library {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/UsingLibraryTasks.ps1 `
            -TaskLibraryPath tests/taskfiles/TaskLibraryWithMissingDependency.ps1 `
            -TaskData $taskData `
            -Quiet # hide task output
        # tool should finish with an error
        $LASTEXITCODE | Should -Be 1
        $taskData.Results | Should -BeExactly @()
        $taskData.Count | Should -Be 0
    }

    It "Unknown library task" -Tag library {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/UnknownLibraryTasks.ps1 `
            -TaskData $taskData `
            -Quiet # hide task output
        # tool should finish with an error
        $LASTEXITCODE | Should -Be 1
        $taskData.Results | Should -BeExactly @()
        $taskData.Count | Should -Be 0
    }

    It "Loading multiple task libraries from path" {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/UsingLibraryTasks.ps1 `
            -TaskLibraryPath tests/taskfiles/library `
            -TaskData $taskData `
            -Quiet # hide tool output
        # running fine using tasks from different library files
        $taskData.Results | Should -BeExactly @('hello world!', 'another hello world 2!')
        $taskData.Count | Should -Be 2
    }

    It "Bad Library Path" {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/UsingLibraryTasks.ps1 `
            -TaskLibraryPath tests/taskfiles/bad-library `
            -TaskData $taskData `
            -Quiet # hide tool output
        # tool should finish with an error
        $LASTEXITCODE | Should -Be 1
        $taskData.Results | Should -BeExactly @()
        $taskData.Count | Should -Be 0
    }
}
