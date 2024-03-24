Describe "Test script file" {
    It "Checking for bad code" {
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/BadCode.ps1 `
            -Quiet # ignore tool output
        # tool should fail since not allowed task code
        $LASTEXITCODE | Should -Be 1
    }

    It "Script file does not exist" {
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/DoesNotExist.ps1 `
            -Quiet # ignore tool output
        # tool should fail since task file doesn't exist
        $LASTEXITCODE | Should -Be 1
    }
}
