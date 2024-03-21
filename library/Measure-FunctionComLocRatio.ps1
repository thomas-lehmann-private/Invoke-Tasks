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
Register-AnalyseTask -Name "AnalyzeFunctionComLocRatio" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration
    $comLocRatio = if ($TaskData.analyseConfiguration.AnalyzeFunctionComLocRatio) {
        $TaskData.analyseConfiguration.AnalyzeFunctionComLocRatio.Ratio
    } else {
        0.25
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)
    $functions | ForEach-Object {
        $function = $_
        $tokens = @()
        $linesFunction = 0
        $tokenCount = 0
        $linesComment = 0

        [System.Management.Automation.Language.Parser]::ParseInput(`
            $function.Extent.Text, [ref]$tokens, [ref]$null) | Out-Null
        foreach ($token in $tokens) {
            if ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment) {
                $linesComment += 1
            } elseif ($token.Kind -eq [System.Management.Automation.Language.TokenKind]::NewLine) {
                if ($tokenCount -gt 0) {
                    $linesFunction += 1
                }
                $tokenCount = 0
            } else {
                $tokenCount += 1
            }
        }
        $ratio = $linesComment / $linesFunction
        if ($ratio -lt $comLocRatio) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeFunctionComLocRatio'
                File = $PathAndFileName
                Line = $function.Extent.StartLineNumber
                Column = $function.Extent.StartColumnNumber
                Message = "Too less comments in function '{0}' ({1}/{2}={3:F2} is below {4})" `
                    -f $function.Name, $linesComment, $linesFunction, $ratio, $comLocRatio
                Severity = 'warning'
                Code = ""
            }
        }
    }
}