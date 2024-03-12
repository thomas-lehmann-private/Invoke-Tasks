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
Register-AnalyseTask -Name "AnalyzeLineLength" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration or set default
    $maximumLength = if ($TaskData.analyseConfiguration.AnalyzeLineLength) {
        $TaskData.analyseConfiguration.AnalyzeLineLength.MaximumLength
    } else {
        100
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.StatementAst]}
    $results = $ScriptBlockAst.FindAll($predicate, $true) | ForEach-Object {
        if ($_.Extent.EndColumnNumber -gt $maximumLength) {
            [PSCustomObject] @{
                Type = 'AnalyzeLineLength'
                File = $PathAndFileName
                Line = $_.Extent.StartLineNumber
                Column = $_.Extent.StartColumnNumber
                Message = "Line too long (exceeds {0})" -f $maximumLength
                Severity = 'information'
                Code = $_.Extent.Text
            }
        }
    }

    # for each line number take first reported problem only
    $results = $results | Group-Object Line | ForEach-Object {
        $_.Group | Select-Object -First 1
    }

    $TaskData.analyseResults += $results
}

Register-AnalyseTask -Name "AnalyzeFunctionCount" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration
    $maximumCount = if ($TaskData.analyseConfiguration.AnalyzeFunctionCount) {
        $TaskData.analyseConfiguration.AnalyzeFunctionCount.MaximumCount
    } else {
        20
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)

    if ($functions.Count -gt $maximumCount) {
        $TaskData.analyseResults += [PSCustomObject] @{
            Type = 'AnalyzeFunctionCount'
            File = $PathAndFileName
            Line = 1
            Column = 1
            Message = "Too many functions ({0} exceeds {1})" `
                -f $functions.Count, $maximumCount
            Severity = 'information'
            Code = ""
        }
    }
}

Register-AnalyseTask -Name "AnalyzeLineCount" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration
    $maximumCount = if ($TaskData.analyseConfiguration.AnalyzeLineCount) {
        $TaskData.analyseConfiguration.AnalyzeLineCount.MaximumCount
    } else {
        1000
    }

    $lines = $ScriptBlockAst.Extent.EndLineNumber - $ScriptBlockAst.Extent.StartLineNumber

    if ($lines -gt $maximumCount) {
        $TaskData.analyseResults += [PSCustomObject] @{
            Type = 'AnalyzeLineCount'
            File = $PathAndFileName
            Line = 1
            Column = 1
            Message = "Too many lines in file ({0} exceeds {1})" `
                -f $lines, $maximumCount
            Severity = 'information'
            Code = ""
        }
    }
}

Register-AnalyseTask -Name "AnalyzeFunctionLineCount" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration
    $maximumCount = if ($TaskData.analyseConfiguration.AnalyzeFunctionLineCount) {
        $TaskData.analyseConfiguration.AnalyzeFunctionLineCount.MaximumCount
    } else {
        50
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)

    $functions | ForEach-Object {
        $function = $_

        $lineCount = $function.Extent.EndLineNumber - $function.Extent.StartLineNumber

        if ($lineCount -gt $maximumCount) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeFunctionLineCount'
                File = $PathAndFileName
                Line = $function.Extent.StartLineNumber
                Column = $function.Extent.StartColumnNumber
                Message = "Too many lines in function '{0}' ({1} exceeds {2})" `
                    -f $function.Name, $lineCount, $maximumCount
                Severity = 'warning'
                Code = ""
            }
        }
    }
}

Register-AnalyseTask -Name "AnalyzeFunctionParameterCount" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )

    # get configuration
    $configuration = $TaskData.analyseConfiguration
    $maximumCount = if ($configuration.AnalyzeFunctionParameterCount) {
            $configuration.AnalyzeFunctionParameterCount.MaximumCount
    } else {
        5
    }

    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)

    $functions | ForEach-Object {
        $function = $_
        $parameters = $function.Body.ParamBlock.Parameters

        if ($parameters.Count -gt $maximumCount) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeFunctionParameterCount'
                File = $PathAndFileName
                Line = $function.Extent.StartLineNumber
                Column = $function.Extent.StartColumnNumber
                Message = "Too many parameters for function '{0}' ({1} exceeds {2})" `
                    -f $function.Name, $parameters.Count, $maximumCount
                Severity = 'warning'
                Code = ""
            }
        }
    }
}

Register-AnalyseTask -Name "AnalyzeFunctionNames" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )

    # get configuration
    $configuration = $TaskData.analyseConfiguration
    $functionNameRegex = if ($configuration.AnalyzeFunctionNames) {
        $configuration.AnalyzeFunctionNames.FunctionNameRegex
    } else {
        "^[A-Z][a-z]+([A-Z][a-z]+)*$"
    }

    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)

    $functions | ForEach-Object {
        $function = $_
        $tokens = $function.Name -Split '-'

        $resultPrototyp = [PSCustomObject] @{
            Type = 'AnalyzeFunctionName'; File = $PathAndFileName
            Line = $function.Extent.StartLineNumber
            Column = $function.Extent.StartColumnNumber
            Message = ""; Severity = 'warning'; Code = ""
        }
    
        if ($tokens.count -ne 2) {
            $result = $resultPrototyp.Clone()
            $result.Message = "'{0}': should have exactly one dash" -f $function.Name
            $TaskData.analyseResults += $result
        }

        $verb = $tokens[0]
        $name = $tokens[1]

        if (-not $(Get-Verb | Where-Object { $_.Verb -eq $verb })) {
            $result = $resultPrototyp.Clone()
            $result.Message = "'{0}': not using standard verbs (see Get-Verb)" -f $function.Name
            $TaskData.analyseResults += $result
        }

        if (-not ($name -cmatch $functionNameRegex)) {
            $result = $resultPrototyp.Clone()
            $result.Message = "'{0}': not written in camel case after the dash!" -f $function.Name
            $TaskData.analyseResults += $result
        }
    }
}

Register-AnalyseTask -Name "AnalyzeScriptBlockLineCount" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration
    $maximumCount = if ($TaskData.analyseConfiguration.AnalyzeScriptBlockLineCount) {
        $TaskData.analyseConfiguration.AnalyzeScriptBlockLineCount.MaximumCount
    } else {
        50
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.ScriptBlockAst]}
    $scriptBlocks = $ScriptBlockAst.FindAll($predicate, $true)

    # we filter out the script blocks representing a file (start by line number 1)
    $scriptBlocks | Where-Object { $_.Extent.StartLineNumber -ne 1 } | ForEach-Object {
        $scriptBlock = $_
        $lineCount = $scriptBlock.Extent.EndLineNumber - $scriptBlock.Extent.StartLineNumber

        if ($lineCount -gt $maximumCount) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeScriptBlockLineCount'
                File = $PathAndFileName
                Line = $scriptBlock.Extent.StartLineNumber
                Column = $scriptBlock.Extent.StartColumnNumber
                Message = "Too many lines in script block ({0} exceeds {1})" `
                    -f $lineCount, $maximumCount
                Severity = 'warning'
                Code = ""
            }
        }
    }
}
