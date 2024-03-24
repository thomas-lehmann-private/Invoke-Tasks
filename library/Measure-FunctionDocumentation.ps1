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
        $function = $_ # function ast
        $template = [PSCustomObject] @{ # template for a message
            Type = 'AnalyzeFunctionDocumentation'; File = $PathAndFileName
            Line = $function.Extent.StartLineNumber
            Column = $function.Extent.StartColumnNumber
            Message = "Missing function documention"; Severity = 'warning'; Code = ""
        }

        $helpContent =  $function.GetHelpContent() # help details of a function
        $parameterNames = $function.Body.ParamBlock.Parameters `
            | ForEach-Object { $_.Name -replace "\$", "" }
        # if there is not any help an issue will be added
        if (-not $helpContent) { $TaskData.analyseResults += $template.Clone() }
        # if .SYNOPSIS is missing an issue will be added
        if (-not $helpContent.SYNOPSIS) {
            $result = $template.PSObject.Copy() # clone defaults
            $result.Message = "Missing Synopsis"
            $TaskData.analyseResults += $result # adding issue
        }
        # get names of parameters in documentation
        $documentedParameterNames = $helpContent.Parameters.GetEnumerator() `
            | ForEach-Object { $_.Key }
        # add an issue for each documented parameter that does not exist
        foreach ($documentedParamName in $documentedParameterNames) {
            if ($documentedParamName -notin $parameterNames) {
                $result = $template.PSObject.Copy() # clone defaults
                $result.Message = "Documented Parameter '{0}' not in parameter block" `
                    -f $documentedParamName
                $TaskData.analyseResults += $result # adding issue
            }
        }
        # add an issue for each parameter that is not documented
        foreach ($parameterName in $parameterNames) {
            if ($parameterName -notin $documentedParameterNames) {
                $result = $template.PSObject.Copy() # clone defaults
                $result.Message = "Parameter '{0}' not documented" -f $parameterName
                $TaskData.analyseResults += $result # adding issue
            }
        }
    }
}