Register-Task -Name "Static code analysis" -Tag "check-code" {
    
    $results = Invoke-ScriptAnalyzer ./Invoke-Tasks.ps1
    $results | Format-Table
    if ($results.Count -gt 0) {
        throw "ScriptAnalyzer has found issues!"
    }
}

Register-Task -Name "Pester Tests" {
    $options = @{
        Run = @{
            Throw = $true
        }
        CodeCoverage = @{
            Enabled = $true
            CoveragePercentTarget = 100
            Path = @('./Invoke-Tasks.ps1')
        }
        TestResult = @{
            Enabled = $true
            OutputFormat = 'JUnitXml'
        }
        Output = @{
            Verbosity = 'Detailed'
        }
        Filter = @{
            Tag = @()
        }
    }

    $configuration = New-PesterConfiguration -Hashtable $options
    Invoke-Pester -Configuration $configuration
    #reportgenerator -reports:./coverage.xml -targetdir:html
}
