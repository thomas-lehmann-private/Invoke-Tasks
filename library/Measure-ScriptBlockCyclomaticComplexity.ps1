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
Register-AnalyseTask -Name "AnalyzeScriptBlockCyclomaticComplexity" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration
    $maximumComplexity = `
        if ($TaskData.analyseConfiguration.AnalyzeScriptBlockCyclomaticComplexity) {
            $TaskData.analyseConfiguration.AnalyzeScriptBlockCyclomaticComplexity.MaximumComplexity
        } else { 10 } # default value

    $logicalOperators = @(                                      # list of logical operators
        [System.Management.Automation.Language.TokenKind]::And, # 'and' operator
        [System.Management.Automation.Language.TokenKind]::Or,  # 'or' operator
        [System.Management.Automation.Language.TokenKind]::Xor  # 'xor' operator
    )

    $predicate = {$args[0] -is [System.Management.Automation.Language.ScriptBlockAst]}
    $scriptBlocks = $ScriptBlockAst.FindAll($predicate, $true)

    # we filter out the script blocks representing a file (start by line number 1)
    $scriptBlocks
        | Where-Object { # filter out blocks that refer to a function (seperate analyse)
            $_.Parent -and $($_.Parent.GetType() `
                -ne [System.Management.Automation.Language.FunctionDefinitionAst])
        }
        | Where-Object { $_.Extent.StartLineNumber -ne 1 } | ForEach-Object {
        $scriptBlock = $_ # script block ast
        $complexity = 1 # default complexity
        # searching for if/elseif statements
        $predicate = {$args[0] -is [System.Management.Automation.Language.IfStatementAst] }
        $complexity += $scriptBlock.FindAll($predicate, $true).Clauses.Count
        # searching for for statements
        $predicate = {$args[0] -is [System.Management.Automation.Language.ForStatementAst]}
        $complexity += $($scriptBlock.FindAll($predicate, $true) | Where-Object Condition).Count
        # searching for catch clauses
        $predicate = {$args[0] -is [System.Management.Automation.Language.CatchClauseAst]}
        $complexity += $scriptBlock.FindAll($predicate, $true).Count
        # searching for trap statements
        $predicate = {$args[0] -is [System.Management.Automation.Language.TrapStatementAst]}
        $complexity += $scriptBlock.FindAll($predicate, $true).Count
        # searching for while statements
        $predicate = {$args[0] -is [System.Management.Automation.Language.WhileStatementAst]}
        $complexity += $scriptBlock.FindAll($predicate, $true).Count
        # searching for logical operators
        $tokens = @()
        [System.Management.Automation.Language.Parser]::ParseInput(`
            $scriptBlock.Extent.Text, [ref]$tokens, [ref]$Null) | Out-Null
        $complexity += $($tokens | Where-Object { $_.Kind -in $logicalOperators }).Count
        # searching for switch statements
        $predicate = {$args[0] -is [System.Management.Automation.Language.WhileStatementAst]}
        $scriptBlock.FindAll($predicate, $true) | ForEach-Object {
            $complexity += $($_.Clauses | Where-Object { $_ -match "Break" })
        }

        if ($complexity -gt $maximumComplexity) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeScriptBlockCyclomaticComplexity' # type of analyse
                File = $PathAndFileName                         # file that has been analyzed
                Line = $scriptBlock.Extent.StartLineNumber
                Column = $scriptBlock.Extent.StartColumnNumber
                Message = "Too complex code block ({0} exceeds {1})" `
                    -f $complexity, $maximumComplexity
                Severity = 'warning'                            # severity is warning
                Code = ""                                       # code is not used here
            }
        }
    }
}