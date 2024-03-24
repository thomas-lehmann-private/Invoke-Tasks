Describe "Capture task outputs" {
    BeforeAll {
        $TEST_VALUE_1 = 1234
        $TEST_VALUE_2 = 5678
        $TEST_REGEX_1 = "value1=value1=(\d+)" # first value to capture
        $TEST_REGEX_2 = "value2=value2=(\d+)" # second value to capture
    }

    It "Capture one regex" {
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/GenerateTaskOutputs.ps1 `
            -CaptureRegexes $TEST_REGEX_1 `
            -Quiet # ignore tool output
        # evaluate captured details from JSON file
        $captured = Get-Content captured.json | ConvertFrom-Json
        $captured.value1 | Should -Be $TEST_VALUE_1
        $captured.Count | Should -Be 1
    }

    It "Capture two regex" {
        ./Invoke-Tasks.ps1 `
            -TaskFile tests/taskfiles/GenerateTaskOutputs.ps1 `
            -CaptureRegexes $TEST_REGEX_1, $TEST_REGEX_2 `
            -Quiet # ignore tool output
        # evaluate captured details from JSON file
        $captured = Get-Content captured.json | ConvertFrom-Json
        $captured[0].value1 | Should -Be $TEST_VALUE_1
        $captured[1].value2 | Should -Be $TEST_VALUE_2
        $captured.Count | Should -Be 2
    }
}
