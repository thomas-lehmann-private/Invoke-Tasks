<#
    The MIT License

    Copyright 2024 Thomas Lehmann.

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
Register-AnalyseTask -Name "AnalyzeFunctionUnusedParameter" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )

    $functions = $ScriptBlockAst.FindAll(
        {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true)

    $functions | ForEach-Object {
        $function = $_
        $parameterNames = $function.Body.ParamBlock.Parameters `
            | ForEach-Object { $_.Name -replace "\$", "" }

        $variableExpressions = $function.FindAll(
            {$args[0] -is [System.Management.Automation.Language.VariableExpressionAst]}, $true)

        $parameterVariables = $variableExpressions `
            | Where-Object {$_.VariablePath -in $parameterNames} | Group-Object {$_.VariablePath}

        $parameterVariables | ForEach-Object {
            if ($_.Group.Count -eq 1) {
                $TaskData.analyseResults += [PSCustomObject] @{
                    Type = 'AnalyzeFunctionUnusedParameter'
                    File = $PathAndFileName
                    Line = $_.Group[0].Extent.StartLineNumber
                    Column = $_.Group[0].Extent.StartColumnNumber
                    Message = "Unused function parameter"
                    Severity = 'warning'
                    Code = ""
                }
            }
        }
    }
}
