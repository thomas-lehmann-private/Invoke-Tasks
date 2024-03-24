Describe "Running tasks by tags" {
    It "Execute task with tag 'first' only" {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/MatchingTags.ps1 `
            -Tags first `
            -TaskData $taskData `
            -Quiet # hide tool output
        # running successful
        $taskData.Results | Should -BeExactly @('hello world (first)!')
        $taskData.Count | Should -Be 1
    }

    It "Execute task with tag 'second' only" {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/MatchingTags.ps1 `
            -Tags second `
            -TaskData $taskData `
            -Quiet # hide tool output
        # running successful
        $taskData.Results | Should -BeExactly @('hello world (second)!')
        $taskData.Count | Should -Be 1
    }

    It "Execute task with tag 'Simple' and 'Short'" {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/MatchingTags.ps1 `
            -Tags Simple, Short `
            -TaskData $taskData `
            -Quiet # hide tool output
        # running successful
        $expectedValues = @('hello world (first)!', 'hello world (second)!')
        $taskData.Results | Should -BeExactly $expectedValues
        $taskData.Count | Should -Be $expectedValues.Count
    }

    It "Execute task with tag 'first' with dependency" {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/MatchingTagsWithDependency.ps1 `
            -Tags first `
            -TaskData $taskData `
            -Quiet # hide tool output
        # running succcessful
        $expectedValues = @('hello world (second)!', 'hello world (first)!')
        $taskData.Results | Should -BeExactly $expectedValues
        $taskData.Count | Should -Be $expectedValues.Count
    }

    It "Execute task with tag that does not exist" {
        $taskData = @{Count = 0; Results = @()} # initial task data
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/MatchingTags.ps1 `
            -Tags does-not-exist `
            -TaskData $taskData `
            -Quiet # hide tool output
        # no result since no tag did match
        $taskData.Results | Should -BeExactly @()
        $taskData.Count | Should -Be 0
    }
}
