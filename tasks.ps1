<#
    The MIT License

    Copyright 2022 Thomas Lehmann.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
#>
Initialize-AnalyseTask {
    param ([hashtable] $TaskData)

    $files = @('./Invoke-Tasks.ps1')
    $files += Get-ChildItem -Path './library' -Filter *.ps1
    $files += Get-ChildItem -Path './tests' -Filter *.ps1

    $TaskData.analyseConfiguration = @{
        Global = @{
            AnalyzePathAndFileNames = $files
        }
        AnalyzeLineLength = @{
            MaximumLineLength = 100
        }
        AnalyzeFunctionCount = @{
            MaximumFunctionCount = 20
        }
    }
}

# Using library to run static code analysis for Invoke-Tasks.ps1
Use-Task -Name "Static code analysis" -LibraryTaskName "Static code analysis" {
    param([hashtable] $TaskData)
    $TaskData.Parameters.Paths = @('./Invoke-Tasks.ps1')
}

# Running unittest
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
            TestSuiteName = 'Invoke-Tasks'
        }
        Output = @{
            Verbosity = 'Detailed'
        }
        Debug = @{
            ShowNavigationMarkers = $false
        }
        Filter = @{
            Tag = @()
        }
    }

    $configuration = New-PesterConfiguration -Hashtable $options
    Invoke-Pester -Configuration $configuration
    #reportgenerator -reports:./coverage.xml -targetdir:html
}
