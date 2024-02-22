Describe "Running task that does throw an error" {
    It "Running task that does throw an error" {
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/TaskThatDoesThrowAnError.ps1 `
            -Quiet
        $LASTEXITCODE | Should -Be 1
    }
}
