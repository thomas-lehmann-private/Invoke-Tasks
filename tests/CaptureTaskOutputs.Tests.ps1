Describe "Capture task outputs" {
    It "Capture one regex" {
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/GenerateTaskOutputs.ps1 `
            -CaptureRegexes "value1=value1=(\d+)" `
            -Quiet

        $captured = Get-Content captured.json | ConvertFrom-Json
        $captured.value1 | Should -Be 1234
        $captured.Count | Should -Be 1
    }

    It "Capture two regex" {
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/GenerateTaskOutputs.ps1 `
            -CaptureRegexes "value1=value1=(\d+)", "value2=value2=(\d+)" `
            -Quiet

        $captured = Get-Content captured.json | ConvertFrom-Json
        $captured[0].value1 | Should -Be 1234
        $captured[1].value2 | Should -Be 5678
        $captured.Count | Should -Be 2
    }
}
