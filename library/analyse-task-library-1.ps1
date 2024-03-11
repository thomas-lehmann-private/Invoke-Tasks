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
    $maximumLineLength = if ($TaskData.analyseConfiguration.AnalyzeLineLength) {
        $TaskData.analyseConfiguration.AnalyzeLineLength.MaximumLineLength
    } else {
        100
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.StatementAst]}
    $results = $ScriptBlockAst.FindAll($predicate, $true) | ForEach-Object {
        if ($_.Extent.EndColumnNumber -gt $maximumLineLength) {
            [PSCustomObject] @{
                Type = 'AnalyzeLineLength'
                File = $PathAndFileName
                Line = $_.Extent.StartLineNumber
                Column = $_.Extent.StartColumnNumber
                Message = "Line too long (exceeds {0})" -f $maximumLineLength
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
    $maximumFunctionCount = if ($TaskData.analyseConfiguration.AnalyzeFunctionCount) {
        $TaskData.analyseConfiguration.AnalyzeFunctionCount.MaximumFunctionCount
    } else {
        20
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)

    if ($functions.Count -gt $maximumFunctionCount) {
        $TaskData.analyseResults += [PSCustomObject] @{
            Type = 'AnalyzeFunctionCount'
            File = $PathAndFileName
            Line = 1
            Column = 1
            Message = "Too many functions ({0} exceeds {1})" `
                -f $functions.Count, $maximumFunctionCount
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
    $maximumLineCount = if ($TaskData.analyseConfiguration.AnalyzeLineCount) {
        $TaskData.analyseConfiguration.AnalyzeLineCount.MaximumLineCount
    } else {
        1000
    }

    $lines = $ScriptBlockAst.Extent.EndLineNumber - $ScriptBlockAst.Extent.StartLineNumber

    if ($lines -gt $maximumLineCount) {
        $TaskData.analyseResults += [PSCustomObject] @{
            Type = 'AnalyzeLineCount'
            File = $PathAndFileName
            Line = 1
            Column = 1
            Message = "Too many lines in file ({0} exceeds {1})" `
                -f $lines, $maximumLineCount
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
    $maximumFunctionLineCount = if ($TaskData.analyseConfiguration.AnalyzeFunctionLineCount) {
        $TaskData.analyseConfiguration.AnalyzeFunctionLineCount.MaximumFunctionLineCount
    } else {
        50
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)

    $functions | ForEach-Object {
        $function = $_

        $lineCount = $function.Extent.EndLineNumber - $function.Extent.StartLineNumber

        if ($lineCount -gt $maximumFunctionLineCount) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeFunctionLineCount'
                File = $PathAndFileName
                Line = $function.Extent.StartLineNumber
                Column = $function.Extent.StartColumnNumber
                Message = "Too many lines in function '{0}' ({1} exceeds {2})" `
                    -f $function.Name, $lineCount, $maximumFunctionLineCount
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
    $maximumFunctionParameterCount = if ($configuration.AnalyzeFunctionParameterCount) {
            $configuration.AnalyzeFunctionParameterCount.MaximumFunctionParameterCount
    } else {
        5
    }

    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)

    $functions | ForEach-Object {
        $function = $_
        $parameters = $function.Body.ParamBlock.Parameters

        if ($parameters.Count -gt $maximumFunctionParameterCount) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeFunctionParameterCount'
                File = $PathAndFileName
                Line = $function.Extent.StartLineNumber
                Column = $function.Extent.StartColumnNumber
                Message = "Too many parameters for function '{0}' ({1} exceeds {2})" `
                    -f $function.Name, $parameters.Count, $maximumFunctionParameterCount
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

        if ($tokens.count -ne 2) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeFunctionName'
                File = $PathAndFileName
                Line = $function.Extent.StartLineNumber
                Column = $function.Extent.StartColumnNumber
                Message = "Function '{0}' should have exactly one dash" -f $function.Name
                Severity = 'warning'
                Code = ""
            }
        }

        $verb = $tokens[0]
        $name = $tokens[1]

        $foundVerb = Get-Verb | Where-Object { $_.Verb -eq $verb }
        if (-not $foundVerb) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeFunctionName'
                File = $PathAndFileName
                Line = $function.Extent.StartLineNumber
                Column = $function.Extent.StartColumnNumber
                Message = "Function '{0}' is not using standard verbs (see Get-Verb)" `
                    -f $function.Name
                Severity = 'warning'
                Code = ""
            }
        }

        if (-not ($name -cmatch $functionNameRegex)) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeFunctionName'
                File = $PathAndFileName
                Line = $function.Extent.StartLineNumber
                Column = $function.Extent.StartColumnNumber
                Message = "Function '{0}' is not written in camel case (after the dash)!" `
                    -f $function.Name
                Severity = 'warning'
                Code = ""
            }
        }
    }
}
