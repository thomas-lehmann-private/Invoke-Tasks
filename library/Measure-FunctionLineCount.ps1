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
    # get configuration
    $maximumCount = if ($TaskData.analyseConfiguration.AnalyzeFunctionLineCount) {
        $TaskData.analyseConfiguration.AnalyzeFunctionLineCount.MaximumCount # custom value
    } else {
        50 # default value
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)

    $functions | ForEach-Object {
        $function = $_ # function ast

        $lineCount = $function.Extent.EndLineNumber - $function.Extent.StartLineNumber

        if ($lineCount -gt $maximumCount) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeFunctionLineCount'            # type of analyse
                File = $PathAndFileName                      # file that has been analyzed
                Line = $function.Extent.StartLineNumber      # line of issue
                Column = $function.Extent.StartColumnNumber  # column of issue
                Message = "Too many lines in function '{0}' ({1} exceeds {2})" `
                    -f $function.Name, $lineCount, $maximumCount
                Severity = 'warning'                         # severity is warning
                Code = ""                                    # code is not used here
            }
        }
    }
}