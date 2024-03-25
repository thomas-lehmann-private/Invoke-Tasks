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
Register-AnalyseTask -Name "AnalyzeScriptBlockEmpty" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    $predicate = {$args[0] -is [System.Management.Automation.Language.ScriptBlockAst]}
    $scriptBlocks = $ScriptBlockAst.FindAll($predicate, $true)
    $scriptBlocks | ForEach-Object {
        $scriptBlock = $_ # script block ast
        $scriptBlockText = $scriptBlock.Extent.Text.Substring(
            1, $scriptBlock.Extent.Text.Length-2).Trim()

        if ($scriptBlockText.Length -eq 0) {
            $TaskData.analyseResults += [PSCustomObject] @{
                Type = 'AnalyzeScriptEmpty'                     # type of analyse
                File = $PathAndFileName                         # file that has been analyzed
                Line = $scriptBlock.Extent.StartLineNumber      # line of the issue
                Column = $scriptBlock.Extent.StartColumnNumber  # column of the issue
                Message = "Empty script block"
                Severity = 'warning'                            # severity of the issue
                Code = ""                                       # code is not used here
            }
        }
    }
}
