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
Register-AnalyseTask -Name "AnalyzeFunctionLineCount" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )

    $functions = $ScriptBlockAst.FindAll(
        {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true)
    $functions | ForEach-Object {
        $function = $_
        $template = [PSCustomObject] @{
            Type = 'AnalyzeFunctionDocumentation'; File = $PathAndFileName
            Line = $function.Extent.StartLineNumber
            Column = $function.Extent.StartColumnNumber
            Message = "Missing function documention"; Severity = 'warning'; Code = ""
        }

        $helpContent =  $function.GetHelpContent()
        $parameterNames = $function.Body.ParamBlock.Parameters `
            | ForEach-Object { $_.Name -replace "\$", "" }

        if (-not $helpContent) { $TaskData.analyseResults += $template.Clone() }

        if (-not $helpContent.SYNOPSIS) {
            $result = $template.PSObject.Copy()
            $result.Message = "Missing Synopsis"
            $TaskData.analyseResults += $result
        }

        $documentedParameterNames = $helpContent.Parameters.GetEnumerator() `
            | ForEach-Object { $_.Key }

        foreach ($documentedParamName in $documentedParameterNames) {
            if ($documentedParamName -notin $parameterNames) {
                $result = $template.PSObject.Copy()
                $result.Message = "Documented Parameter '{0}' not in parameter block" `
                    -f $documentedParamName
                $TaskData.analyseResults += $result
            }
        }

        foreach ($parameterName in $parameterNames) {
            if ($parameterName -notin $documentedParameterNames) {
                $result = $template.PSObject.Copy()
                $result.Message = "Parameter '{0}' not documented" -f $parameterName
                $TaskData.analyseResults += $result
            }
        }
    }
}