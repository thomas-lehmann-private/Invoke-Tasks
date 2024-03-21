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
Register-AnalyseTask -Name "AnalyzeFunctionReturnCount" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )

    # get configuration
    $maximumCount = if ($TaskData.analyseConfiguration.AnalyzeFunctionReturnCount) {
        $TaskData.analyseConfiguration.AnalyzeFunctionReturnCount.MaximumCount
    } else { 1 }

    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)
    $functions | ForEach-Object {
        $function = $_
        $tokens = @()
        [System.Management.Automation.Language.Parser]::ParseInput(`
            $function.Extent.Text, [ref]$tokens, [ref]$null) | Out-Null
    
        $returns = $tokens | Where-Object {
            $_.Kind -eq [System.Management.Automation.Language.TokenKind]::Return
        }

        if ($returns.Count -gt $maximumCount) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeFunctionReturnCount'
                File = $PathAndFileName
                Line = $function.Extent.StartLineNumber
                Column = $function.Extent.StartColumnNumber
                Message = "Too many returns in function '{0}' ({1} exceeds {2})" `
                    -f $function.Name, $returns.Count, $maximumCount
                Severity = 'warning'
                Code = ""
            }
        }
    }
}
