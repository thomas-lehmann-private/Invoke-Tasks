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
Register-AnalyseTask -Name "AnalyzeFunctionCount" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration
    $maximumCount = if ($TaskData.analyseConfiguration.AnalyzeFunctionCount) {
        $TaskData.analyseConfiguration.AnalyzeFunctionCount.MaximumCount # custom value
    } else {
        20 # default value
    }
    $predicate = {$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}
    $functions = $ScriptBlockAst.FindAll($predicate, $true)

    if ($functions.Count -gt $maximumCount) {
        $TaskData.analyseResults += [PSCustomObject] @{
            Type = 'AnalyzeFunctionCount'  # type of analyse
            File = $PathAndFileName        # file file that has been analyzed
            Line = 1                       # for a file it always starts at line 1
            Column = 1                     # for a file it always starts at column 1
            Message = "Too many functions ({0} exceeds {1})" `
                -f $functions.Count, $maximumCount
            Severity = 'information'       # severity is information
            Code = ""                      # code is not used here
        }
    }
}
