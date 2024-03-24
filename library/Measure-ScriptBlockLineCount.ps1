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
Register-AnalyseTask -Name "AnalyzeScriptBlockLineCount" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    $ignores = Search-AllIgnore $ScriptBlockAst

    # get configuration
    $maximumCount = if ($TaskData.analyseConfiguration.AnalyzeScriptBlockLineCount) {
        $TaskData.analyseConfiguration.AnalyzeScriptBlockLineCount.MaximumCount # custom value
    } else {
        50 # default value
    }
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

        $lineCount = $scriptBlock.Extent.EndLineNumber - $scriptBlock.Extent.StartLineNumber

        $ignorable = [PSCustomObject] @{
            Name = 'AnalyzeScriptBlockLineCount'; Line = $scriptBlock.Extent.StartLineNumber}
        $filteredIgnores = $ignores | Where-Object {`
                $($_.Name -eq $ignorable.Name) -and $($_.Line -eq $ignorable.Line)}

        if ($($lineCount -gt $maximumCount) -and $($filteredIgnores.Count -eq 0)) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeScriptBlockLineCount'            # type of analyse
                File = $PathAndFileName                         # file that has been analyzed
                Line = $scriptBlock.Extent.StartLineNumber      # line of the issue
                Column = $scriptBlock.Extent.StartColumnNumber  # column of the issue
                Message = "Too many lines in script block ({0} exceeds {1})" `
                    -f $lineCount, $maximumCount
                Severity = 'warning'                            # severity of the issue
                Code = ""                                       # code is not used here
            }
        }
    }
}
