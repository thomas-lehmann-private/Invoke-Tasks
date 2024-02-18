Describe "Running tasks by tags" {
    It "Execute task with tag 'first' only" {
        $taskData = @{Count = 0; Results = @()}
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/MatchingTags.ps1 `
            -Tags first `
            -TaskData $taskData `
            -Quiet

        $taskData.Results | Should -BeExactly @('hello world (first)!')
        $taskData.Count | Should -Be 1
    }

    It "Execute task with tag 'second' only" {
        $taskData = @{Count = 0; Results = @()}
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/MatchingTags.ps1 `
            -Tags second `
            -TaskData $taskData `
            -Quiet

        $taskData.Results | Should -BeExactly @('hello world (second)!')
        $taskData.Count | Should -Be 1
    }

    It "Execute task with tag 'first' and 'second'" {
        $taskData = @{Count = 0; Results = @()}
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/MatchingTags.ps1 `
            -Tags first, second `
            -TaskData $taskData `
            -Quiet

        $taskData.Results | Should -BeExactly @('hello world (first)!', 'hello world (second)!')
        $taskData.Count | Should -Be 2
    }

    It "Execute task with tag 'first' only with dependency" {
        $taskData = @{Count = 0; Results = @()}
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/MatchingTagsWithDependency.ps1 `
            -Tags first `
            -TaskData $taskData `
            -Quiet

        $taskData.Results | Should -BeExactly @('hello world (first)!')
        $taskData.Count | Should -Be 1
    }

    It "Execute task with tag that does not exist" {
        $taskData = @{Count = 0; Results = @()}
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/MatchingTags.ps1 `
            -Tags does-not-exist `
            -TaskData $taskData `
            -Quiet

        $taskData.Results | Should -BeExactly @()
        $taskData.Count | Should -Be 0
    }
}
