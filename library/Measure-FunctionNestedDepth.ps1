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
Register-AnalyseTask -Name "AnalyzeFunctionNestedDepth" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )

    # get configuration
    $maximumDepth = if ($TaskData.analyseConfiguration.AnalyzeFunctionNestedDepth) {
        $TaskData.analyseConfiguration.AnalyzeFunctionNestedDepth.MaximumDepth # custom value
    } else { 3 } # default value

    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)
    $functions | ForEach-Object {
        $function = $_ # function ast
        $blockPredicate = {$args[0] -is [System.Management.Automation.Language.StatementBlockAst]}
        $blocks = $function.FindAll($blockPredicate, $true)
        foreach ($block in $blocks) {
            $parent = $block.Parent # parent of this block
            $depth = 0 # initial depth
            while ($parent.Extent.StartLineNumber -ne $function.Extent.StartLineNumber) {
                if ($parent -is [System.Management.Automation.Language.StatementBlockAst]) {
                    $depth += 1 # one more depth found
                }
                $parent = $parent.Parent # walking up
            }

            if ($depth -gt $maximumDepth) {
                $TaskData.analyseResults += [PSCustomObject] @{
                    Type = 'AnalyzeFunctionNestedDepth'       # type of analyse
                    File = $PathAndFileName                   # file that has been analyzed
                    Line = $block.Extent.StartLineNumber      # line of the issue
                    Column = $block.Extent.StartColumnNumber  # column of the issue
                    Message = "Nested depth in function {0} ({1} exceeds {2}" `
                        -f $function.Name, $depth, $maximumDepth
                    Severity = 'warning'                      # severity of the issue
                    Code = ""                                 # code is not used here
                }
            }
        }
    }
}
