Describe "Running task that does throw an error" {
    It "Testing for an exception" {
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/TaskThatDoesThrowAnError.ps1 `
            -Quiet # hide tool output
        # exception should at least generate an exit code
        $LASTEXITCODE | Should -Be 1
    }
}
