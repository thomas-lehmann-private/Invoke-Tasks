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
Register-AnalyseTask -Name "AnalyzeFunctionNames" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )

    # get configuration
    $configuration = $TaskData.analyseConfiguration
    $functionNameRegex = if ($configuration.AnalyzeFunctionNames) {
        $configuration.AnalyzeFunctionNames.FunctionNameRegex # custom value
    } else { "^[A-Z][a-z]+([A-Z][a-z]+)*$" } # default value

    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)

    $functions | ForEach-Object {
        $function = $_ # function ast
        $tokens = $function.Name -Split '-' # tokenize of name

        $resultPrototyp = [PSCustomObject] @{ # template for an issue
            Type = 'AnalyzeFunctionName'; File = $PathAndFileName
            Line = $function.Extent.StartLineNumber
            Column = $function.Extent.StartColumnNumber
            Message = ""; Severity = 'warning'; Code = ""
        }
    
        if ($tokens.count -ne 2) { # name does not have exactly one dash?
            $result = $resultPrototyp.PSObject.Copy() # clone of prototype issue
            $result.Message = "'{0}': should have exactly one dash" -f $function.Name
            $TaskData.analyseResults += $result       # adding issue
            return
        }

        $verb = $tokens[0]
        $name = $tokens[1]

        if (-not $(Get-Verb | Where-Object { $_.Verb -eq $verb })) {
            $result = $resultPrototyp.PSObject.Copy()
            $result.Message = "'{0}': not using standard verbs (see Get-Verb)" -f $function.Name
            $TaskData.analyseResults += $result # adding issue
        }

        if (-not ($name -cmatch $functionNameRegex)) {
            $result = $resultPrototyp.PSObject.Copy() # clone of prototype issue
            $result.Message = "'{0}': not written in camel case after the dash!" -f $function.Name
            $TaskData.analyseResults += $result       # adding issue
        }
    }
}
