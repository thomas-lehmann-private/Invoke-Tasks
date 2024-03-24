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
Register-AnalyseTask -Name "AnalyzeLineCount" {
    param(
        [hashtable] $TaskData,
        [String] $PathAndFileName,
        [System.Management.Automation.Language.ScriptBlockAst] $ScriptBlockAst
    )
    # get configuration
    $maximumCount = if ($TaskData.analyseConfiguration.AnalyzeLineCount) {
        $TaskData.analyseConfiguration.AnalyzeLineCount.MaximumCount # custom value
    } else {
        1000 # default value
    }

    $lines = $ScriptBlockAst.Extent.EndLineNumber - $ScriptBlockAst.Extent.StartLineNumber

    if ($lines -gt $maximumCount) {
        $TaskData.analyseResults += [PSCustomObject] @{
            Type = 'AnalyzeLineCount'      # type of analyse
            File = $PathAndFileName        # file that is analyzed
            Line = 1                       # for a file the start is always at line 1
            Column = 1                     # for a file the start is always at column 1
            Message = "Too many lines in file ({0} exceeds {1})" `
                -f $lines, $maximumCount
            Severity = 'information'       # severity is 'information'
            Code = ""                      # code is not used here
        }
    }
}
