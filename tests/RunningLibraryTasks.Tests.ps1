Describe "Running library tasks" {
    It "Running tasks including dependencies inside library" {
        $taskData = @{Count = 0; Results = @()}
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/UsingLibraryTasks.ps1 `
            -TaskLibraryFile tests/taskfiles/TaskLibrary.ps1 `
            -TaskData $taskData `
            -Quiet

        $taskData.Results | Should -BeExactly @('hello world!', 'another hello world!', 'another hello world 2!')
        $taskData.Count | Should -Be 3
    }

    It "Missing dependency inside library" {
        $taskData = @{Count = 0; Results = @()}
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/UsingLibraryTasks.ps1 `
            -TaskLibraryFile tests/taskfiles/TaskLibraryWithMissingDependency.ps1 `
            -TaskData $taskData `
            -Quiet

        $LASTEXITCODE | Should -Be 1
        $taskData.Results | Should -BeExactly @()
        $taskData.Count | Should -Be 0
    }

    It "Unknown library task" {
        # TODO: funktioniert nicht wie gewünscht!
        $taskData = @{Count = 0; Results = @()}
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/UnknownLibraryTasks.ps1 `
            -TaskData $taskData `
            -Quiet

        $LASTEXITCODE | Should -Be 1
        $taskData.Results | Should -BeExactly @()
        $taskData.Count | Should -Be 0
    }
}
