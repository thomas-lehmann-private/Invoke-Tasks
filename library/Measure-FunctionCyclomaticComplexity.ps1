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
# ignore AnalyzeScriptBlockLineCount on line 25 because this is an acceptable exception
Register-AnalyseTask -Name "AnalyzeFunctionCyclomaticComplexity" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration
    $maximumComplexity = if ($TaskData.analyseConfiguration.AnalyzeFunctionCyclomaticComplexity) {
        $TaskData.analyseConfiguration.AnalyzeFunctionCyclomaticComplexity.MaximumComplexity
    } else { 10 }

    $logicalOperators = @(
        [System.Management.Automation.Language.TokenKind]::And,
        [System.Management.Automation.Language.TokenKind]::Or,
        [System.Management.Automation.Language.TokenKind]::Xor
    )

    $mainPredicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($mainPredicate, $true)
    $functions | ForEach-Object {
        $function = $_
        $complexity = 1 # default complexity
        # searching for if/elseif statements
        $predicate = {$args[0] -is [System.Management.Automation.Language.IfStatementAst] }
        $complexity += $function.FindAll($predicate, $true).Clauses.Count
        # searching for for statements
        $predicate = {$args[0] -is [System.Management.Automation.Language.ForStatementAst]}
        $complexity += $($function.FindAll($predicate, $true) | Where-Object Condition).Count
        # searching for catch clauses
        $predicate = {$args[0] -is [System.Management.Automation.Language.CatchClauseAst]}
        $complexity += $function.FindAll($predicate, $true).Count
        # searching for trap statements
        $predicate = {$args[0] -is [System.Management.Automation.Language.TrapStatementAst]}
        $complexity += $function.FindAll($predicate, $true).Count
        # searching for while statements
        $predicate = {$args[0] -is [System.Management.Automation.Language.WhileStatementAst]}
        $complexity += $function.FindAll($predicate, $true).Count
        # searching for logical operators
        $tokens = @()
        [System.Management.Automation.Language.Parser]::ParseInput(`
            $function.Extent.Text, [ref]$tokens, [ref]$Null) | Out-Null
        $complexity += $($tokens | Where-Object { $_.Kind -in $logicalOperators }).Count
        # searching for switch statements
        $predicate = {$args[0] -is [System.Management.Automation.Language.WhileStatementAst]}
        $function.FindAll($predicate, $true) | ForEach-Object {
            $complexity += $($_.Clauses | Where-Object { $_ -match "Break" })
        }

        if ($complexity -gt $maximumComplexity) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeFunctionCyclomaticComplexity'
                File = $PathAndFileName
                Line = $function.Extent.StartLineNumber
                Column = $function.Extent.StartColumnNumber
                Message = "Too complex function '{0}' ({1} exceeds {2})" `
                    -f $function.Name, $complexity, $maximumComplexity
                Severity = 'warning'
                Code = ""
            }
        }
    }
}